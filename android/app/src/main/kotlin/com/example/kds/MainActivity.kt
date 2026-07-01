package com.example.kds

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
import com.bixolon.commonlib.connectivity.NetworkService
import java.lang.Exception
import android.util.Log
import android.view.KeyEvent

class MainActivity : FlutterActivity() {
    private val SENSOR_CHANNEL = "com.sg.kds/printer_status"
    private val ACTION_CHANNEL = "com.sg.kds/printer_action"
    private val SCANNER_CHANNEL = "com.sg.kds/scanner"

    private var scannerChannel: MethodChannel? = null
    private var barcodeBuffer = StringBuilder()
    private var statusSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    private var networkService: NetworkService? = null
    private var isMonitoring = false
    private val printerIp = "192.168.10.197"
    private var lastStatus: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        try {
            System.loadLibrary("bxl_common")
            Log.d("KDS_DEBUG", "✅ 엔진 파일(bxl_common) 로드 성공!")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("KDS_DEBUG", "❌ 엔진 파일 로드 실패: ${e.message}")
        }
        super.configureFlutterEngine(flutterEngine)
        Log.d("KDS_DEBUG", "🚀 채널 설정 완료!")

        scannerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCANNER_CHANNEL)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("KDS_DEBUG", "📢 Flutter에서 신호 감지 시작!")
                    statusSink = events
                    startMonitoring()
                }

                override fun onCancel(arguments: Any?) {
                    stopMonitoring()
                    statusSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACTION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "printTestLabel" -> {
                        val menus = call.arguments as? List<String>
                        val startTime = System.currentTimeMillis()
                        val isSuccess = if (menus != null) sendTestPrint(menus) else false
                        if (isSuccess) {
                            Log.d("KDS_SPEED", "⏱️ [텍스트] 전송 완료: ${System.currentTimeMillis() - startTime}ms")
                            result.success(true)
                        } else {
                            result.error("ERROR", "인쇄 실패", null)
                        }
                    }
                    "printImageLabel" -> {
                        val imageBytes = call.arguments as? ByteArray
                        if (imageBytes == null) {
                            result.error("ARG_ERR", "이미지 데이터가 없습니다.", null)
                            return@setMethodCallHandler
                        }
                        val startTime = System.currentTimeMillis()
                        Log.d("KDS_SPEED", "⏱️ [이미지] 출력 시작 (데이터 크기: ${imageBytes.size} bytes)")
                        val isSuccess = sendImagePrint(imageBytes)
                        if (isSuccess) {
                            Log.d("KDS_SPEED", "⏱️ [이미지] 데이터 전송 완료: ${System.currentTimeMillis() - startTime}ms")
                            result.success(true)
                        } else {
                            result.error("ERROR", "이미지 인쇄 실패", null)
                        }
                    }
                    "checkHardware" -> {
                        checkPrinterHardware()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private val clearBufferRunnable = Runnable {
        if (barcodeBuffer.isNotEmpty()) {
            Log.w("KDS_DEBUG", "⚠️ 1.5초간 입력이 없어 버퍼 초기화됨 (버려진 데이터: $barcodeBuffer)")
            barcodeBuffer.clear()
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
            handler.removeCallbacks(clearBufferRunnable)
            val keyCode = event.keyCode
            if (keyCode == KeyEvent.KEYCODE_ENTER || keyCode == KeyEvent.KEYCODE_NUMPAD_ENTER) {
                if (barcodeBuffer.isNotEmpty()) {
                    val finalBarcode = barcodeBuffer.toString().trim()
                    barcodeBuffer.clear()
                    Log.d("KDS_DEBUG", "🎯 [Native Scanner] 스캔 완료: $finalBarcode")
                    handler.post {
                        scannerChannel?.invokeMethod("onScan", finalBarcode)
                    }
                }
                return true
            } else {
                val unicodeChar = event.unicodeChar
                if (unicodeChar >= 32) {
                    barcodeBuffer.append(unicodeChar.toChar())
                }
                handler.postDelayed(clearBufferRunnable, 1500)
                if (unicodeChar > 0) return true
            }
        }
        return super.dispatchKeyEvent(event)
    }

    private fun sendImagePrint(imageBytes: ByteArray): Boolean {
        if (networkService == null || !isMonitoring) return false
        return try {
            Thread {
                val combined = mutableListOf<Byte>()
                // 초기화
                combined.addAll(byteArrayOf(0x1B, 0x40).toList())
                // 인쇄 영역 너비 설정 (384 dots)
                combined.addAll(byteArrayOf(0x1D, 0x57, 0x80.toByte(), 0x01.toByte()).toList())
                // 왼쪽 정렬
                combined.addAll(byteArrayOf(0x1B, 0x61, 0x00).toList())
                // 왼쪽 마진 0 설정
                val nL: Byte = 0x00
                val nH: Byte = 0x00
                combined.addAll(byteArrayOf(0x1D, 0x4C, nL, nH).toList())
                // 이미지 데이터
                combined.addAll(imageBytes.toList())
                // 피딩 4줄 + 즉시 커팅
                combined.addAll(byteArrayOf(0x1B, 0x64, 0x04).toList())
                combined.addAll(byteArrayOf(0x1D, 0x56, 0x01).toList())
                networkService?.write(combined.toByteArray())
            }.start()
            true
        } catch (e: Exception) {
            Log.e("KDS_DEBUG", "❌ 이미지 전송 오류: ${e.message}")
            false
        }
    }

    private fun sendTestPrint(menus: List<String>): Boolean {
        if (networkService == null || !isMonitoring) return false
        return try {
            Thread {
                val output = mutableListOf<Byte>()
                val charset = java.nio.charset.Charset.forName("KSC5601")
                val orderNo = "105"

                output.addAll(byteArrayOf(0x1B, 0x40).toList())
                output.addAll(byteArrayOf(0x1C, 0x26).toList())
                output.addAll(byteArrayOf(0x1B, 0x61, 0x01).toList())

                val dataLen = orderNo.length + 3
                output.addAll(byteArrayOf(0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x08).toList())
                output.addAll(byteArrayOf(0x1D, 0x28, 0x6B, dataLen.toByte(), 0x00, 0x31, 0x50, 0x30).toList())
                output.addAll(orderNo.toByteArray().toList())
                output.addAll(byteArrayOf(0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30).toList())
                output.addAll("\n".toByteArray().toList())

                output.addAll(byteArrayOf(0x1B, 0x45, 0x01).toList())
                output.addAll(byteArrayOf(0x1D, 0x21, 0x22).toList())
                output.addAll("No. $orderNo\n\n".toByteArray(charset).toList())
                output.addAll(byteArrayOf(0x1B, 0x45, 0x00).toList())
                output.addAll(byteArrayOf(0x1D, 0x21, 0x00).toList())
                output.addAll(byteArrayOf(0x1B, 0x61, 0x00).toList())

                for (menu in menus) {
                    output.addAll("    $menu\n".toByteArray(charset).toList())
                }

                output.addAll(byteArrayOf(0x1B, 0x64, 0x08).toList())
                output.addAll(byteArrayOf(0x1D, 0x56, 0x42, 0x00).toList())
                networkService?.write(output.toByteArray())
            }.start()
            true
        } catch (e: Exception) { false }
    }

    private fun checkPrinterHardware() {
        if (networkService == null || !isMonitoring) {
            Log.e("PRINTER_INFO", "❌ 프린터가 연결되어 있지 않습니다.")
            return
        }
        Thread {
            try {
                Log.d("PRINTER_INFO", "🔍 하드웨어 정보 요청 중...")
                networkService?.write(byteArrayOf(0x1D, 0x49, 0x02))
                Thread.sleep(200)
                val res2 = networkService?.read(500)
                Log.d("PRINTER_INFO", "📊 Multi-byte Support (n=2): ${res2?.contentToString()}")
                networkService?.write(byteArrayOf(0x1D, 0x49, 0x45))
                Thread.sleep(200)
                val res69 = networkService?.read(500)
                Log.d("PRINTER_INFO", "📊 Current Language (n=69): ${res69?.contentToString()}")
            } catch (e: Exception) {
                Log.e("PRINTER_INFO", "❌ 정보 요청 중 에러: ${e.message}")
            }
        }.start()
    }

    private fun startMonitoring() {
        Log.d("KDS_DEBUG", "🔗 프린터 연결 시도 중... IP: $printerIp")
        if (isMonitoring) return
        isMonitoring = true

        Thread {
            val maxRetries = 3
            val retryDelayMs = 2000L
            var connected = false

            for (attempt in 1..maxRetries) {
                try {
                    if (attempt > 1) {
                        networkService?.disconnect()
                        networkService = null
                        Thread.sleep(retryDelayMs)
                    }
                    if (networkService == null) {
                        networkService = NetworkService(context)
                    }
                    Log.d("KDS_DEBUG", "🔌 프린터 연결 시도 $attempt/$maxRetries (IP: $printerIp)")
                    val result = networkService?.connect(printerIp, 9100, 3000, false)
                    Log.d("KDS_DEBUG", "📡 연결 결과 코드: $result (시도 $attempt/$maxRetries)")
                    if (result == 0) {
                        Log.d("KDS_DEBUG", "✅ 프린터 연결 성공! (시도 $attempt/$maxRetries)")
                        connected = true
                        break
                    } else {
                        Log.w("KDS_DEBUG", "⚠️ 연결 실패 (시도 $attempt/$maxRetries, result=$result)")
                    }
                } catch (e: Exception) {
                    Log.e("KDS_DEBUG", "❌ 연결 예외 발생 (시도 $attempt/$maxRetries): ${e.message}")
                }
            }

            if (connected) {
                checkPrinterStatusLoop()
            } else {
                Log.e("KDS_DEBUG", "❌ 프린터 연결 최종 실패 (총 ${maxRetries}회 시도)")
                handler.post {
                    statusSink?.error("CONN_FAIL", "프린터 연결 실패 (${maxRetries}회 시도 후 포기)", null)
                }
                isMonitoring = false
            }
        }.start()
    }

    private fun stopMonitoring() {
        isMonitoring = false
        Thread { networkService?.disconnect() }.start()
    }

    private fun checkPrinterStatusLoop() {
        if (!isMonitoring) return

        val asbr = byteArrayOf(0x08.toByte(), 0x1c.toByte(), 0x1d.toByte(), 0x61.toByte(), 0xff.toByte())

        try {
            networkService?.write(asbr)
            val response = networkService?.read(200)
            if (response != null && response.size >= 3) {
                // 3번째 바이트(index 2)의 0x80 비트: 1 = 라벨 있음, 0 = 라벨 없음
                val isPaperPresent = (response[2].toInt() and 0x80) == 0x80
                val currentStatus = if (isPaperPresent) "ATTACHED" else "DETACHED"
                if (currentStatus != lastStatus) {
                    lastStatus = currentStatus
                    handler.post {
                        Log.d("KDS_DEBUG", "🔔 상태 변경 감지: $currentStatus")
                        statusSink?.success(currentStatus)
                    }
                }
            }
        } catch (e: Exception) {
            // 통신 에러는 무시하고 루프 계속
        }

        handler.postDelayed({ checkPrinterStatusLoop() }, 500)
    }
}
