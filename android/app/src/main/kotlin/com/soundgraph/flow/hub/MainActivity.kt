package com.soundgraph.flow.hub

import android.content.Intent
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
    private val SENSOR_CHANNEL = "com.sg.flowhub/printer_status"
    private val ACTION_CHANNEL = "com.sg.flowhub/printer_action"
    private val SCANNER_CHANNEL = "com.sg.flowhub/scanner"

    private var scannerChannel: MethodChannel? = null
    private var barcodeBuffer = StringBuilder()
    private var statusSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    private var networkService: NetworkService? = null
    private var isMonitoring = false
    // Set by Flutter (setPrinterIp) before it ever starts listening for
    // status — see PrinterDataSource._initAndListen, which waits for
    // LocalSubnetResolver to confirm this site's real subnet first. This
    // default only matters if that call is somehow never made.
    private var printerIp = "192.168.81.203"
    private var lastStatus: String? = null
    private var consecutiveStatusFailures = 0
    private val maxConsecutiveStatusFailures = 3

    // Set by Flutter (setAwaitingDetach) while a printed label is sitting in
    // KdsCubit's _awaitingDetachQueue waiting to be peeled off. Only while
    // this is true do we forward every poll tick's raw status instead of
    // just edge changes — see checkPrinterStatusLoop. Idle the rest of the
    // time (no order pending), so this doesn't spam the platform channel or
    // logs all day for no reason.
    private var awaitingDetach = false

    // SRP-350plus receipt printer — a second, independent Bixolon device
    // from the SRP-S200 label printer above. Deliberately its own
    // connect-per-print NetworkService (no persistent connection/status
    // polling yet, unlike the label printer's networkService/isMonitoring):
    // this is a first pass to prove out network printing end-to-end before
    // building out the same connection-tracking plumbing.
    private val receiptPrinterIp = "192.168.81.204"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        try {
            System.loadLibrary("bxl_common")
            Log.d("FLOWHUB_DEBUG", "✅ 엔진 파일(bxl_common) 로드 성공!")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("FLOWHUB_DEBUG", "❌ 엔진 파일 로드 실패: ${e.message}")
        }
        super.configureFlutterEngine(flutterEngine)
        Log.d("FLOWHUB_DEBUG", "🚀 채널 설정 완료!")

        scannerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCANNER_CHANNEL)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("FLOWHUB_DEBUG", "📢 Flutter에서 신호 감지 시작!")
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
                            Log.d("FLOWHUB_SPEED", "⏱️ [텍스트] 전송 완료: ${System.currentTimeMillis() - startTime}ms")
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
                        Log.d("FLOWHUB_SPEED", "⏱️ [이미지] 출력 시작 (데이터 크기: ${imageBytes.size} bytes)")
                        sendImagePrint(imageBytes) { success, error ->
                            if (success) {
                                Log.d("FLOWHUB_SPEED", "⏱️ [이미지] 데이터 전송 완료: ${System.currentTimeMillis() - startTime}ms")
                                result.success(true)
                            } else {
                                result.error("ERROR", error ?: "이미지 인쇄 실패", null)
                            }
                        }
                    }
                    "checkHardware" -> {
                        checkPrinterHardware()
                        result.success(true)
                    }
                    "reconnectPrinter" -> {
                        Log.d("FLOWHUB_DEBUG", "🔁 수동 재연결 요청")
                        startMonitoring()
                        result.success(true)
                    }
                    "setAwaitingDetach" -> {
                        awaitingDetach = call.arguments as? Boolean ?: false
                        result.success(true)
                    }
                    "setPrinterIp" -> {
                        val ip = call.arguments as? String
                        if (ip != null) {
                            printerIp = ip
                            Log.d("FLOWHUB_DEBUG", "🌐 프린터 IP 설정: $printerIp")
                        }
                        result.success(true)
                    }
                    "printReceipt" -> {
                        val args = call.arguments as? Map<*, *>
                        val orderNo = args?.get("orderNo") as? String ?: ""
                        @Suppress("UNCHECKED_CAST")
                        val menus = args?.get("menus") as? List<String> ?: emptyList()
                        sendReceiptPrint(orderNo, menus) { success, error ->
                            if (success) {
                                result.success(true)
                            } else {
                                result.error("ERROR", error ?: "영수증 인쇄 실패", null)
                            }
                        }
                    }
                    "restartApp" -> {
                        // Dart's own orders-snapshot save (if any) has already
                        // completed by the time this is called — see
                        // KdsCubit's reboot methods, which await the save
                        // before invoking this. Standard Android kill+
                        // relaunch pattern: schedule a fresh launch of this
                        // same Activity, then kill this process outright —
                        // Flutter/Dart state is NOT preserved across this
                        // (that's the whole point; anything that needs to
                        // survive must already be on disk before this runs).
                        result.success(true)
                        val restartIntent = packageManager.getLaunchIntentForPackage(packageName)
                        val componentName = restartIntent!!.component
                        val mainIntent = Intent.makeRestartActivityTask(componentName)
                        startActivity(mainIntent)
                        Runtime.getRuntime().exit(0)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private val clearBufferRunnable = Runnable {
        if (barcodeBuffer.isNotEmpty()) {
            Log.w("FLOWHUB_DEBUG", "⚠️ 1.5초간 입력이 없어 버퍼 초기화됨 (버려진 데이터: $barcodeBuffer)")
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
                    Log.d("FLOWHUB_DEBUG", "🎯 [Native Scanner] 스캔 완료: $finalBarcode")
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

    // NetworkService.write(ByteArray) returns an Int result code (0 = success,
    // matching the same convention already used for connect()'s result above)
    // — previously this wasn't checked at all, so a write that silently
    // failed (printer asleep/disconnected mid-job) still reported "success"
    // back to Flutter, which then queued that sub-item onto
    // _awaitingDetachQueue waiting for a DETACHED signal that would never
    // come (no label was ever physically printed), permanently stuck at the
    // front of that FIFO queue and misattributing every later label's real
    // DETACHED event to it.
    private fun sendImagePrint(imageBytes: ByteArray, callback: (Boolean, String?) -> Unit) {
        if (networkService == null || !isMonitoring) {
            callback(false, "프린터가 연결되어 있지 않습니다.")
            return
        }
        Thread {
            try {
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
                val writeResult = networkService?.write(combined.toByteArray()) ?: -1
                handler.post {
                    if (writeResult == 0) {
                        callback(true, null)
                    } else {
                        Log.e("FLOWHUB_DEBUG", "❌ 이미지 전송 실패 (결과 코드: $writeResult)")
                        callback(false, "프린터 쓰기 실패 (코드: $writeResult)")
                    }
                }
            } catch (e: Exception) {
                Log.e("FLOWHUB_DEBUG", "❌ 이미지 전송 오류: ${e.message}")
                handler.post { callback(false, e.message) }
            }
        }.start()
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

    // Connects fresh to the SRP-350plus, prints a simple receipt (order no
    // + item names), then disconnects — separate NetworkService instance
    // from the label printer's, since these are two different physical
    // printers at two different IPs.
    private fun sendReceiptPrint(
        orderNo: String,
        menus: List<String>,
        callback: (Boolean, String?) -> Unit,
    ) {
        Thread {
            var service: NetworkService? = null
            try {
                service = NetworkService(context)
                val connectResult = service.connect(receiptPrinterIp, 9100, 3000, false)
                if (connectResult != 0) {
                    Log.e("FLOWHUB_DEBUG", "❌ 영수증 프린터 연결 실패 (코드: $connectResult, IP: $receiptPrinterIp)")
                    handler.post { callback(false, "영수증 프린터 연결 실패 (코드: $connectResult)") }
                    return@Thread
                }

                val charset = java.nio.charset.Charset.forName("KSC5601")
                val output = mutableListOf<Byte>()
                output.addAll(byteArrayOf(0x1B, 0x40).toList()) // 초기화
                output.addAll(byteArrayOf(0x1B, 0x61, 0x01).toList()) // 가운데 정렬

                output.addAll(byteArrayOf(0x1D, 0x21, 0x11).toList()) // 2배 확대
                output.addAll("Order No. $orderNo\n\n".toByteArray(charset).toList())
                output.addAll(byteArrayOf(0x1D, 0x21, 0x00).toList()) // 원래 크기로 복원

                output.addAll(byteArrayOf(0x1B, 0x61, 0x00).toList()) // 왼쪽 정렬
                for (menu in menus) {
                    output.addAll("- $menu\n".toByteArray(charset).toList())
                }

                // 프린트헤드~커터 사이 물리적 거리를 다 못 채우고 자르면 이미
                // 인쇄된 뒷부분(메뉴명 등)이 커터를 지나기 전에 잘려나가
                // 눈에 안 보이게 된다 — 8줄이 딱 맞는 값이었고, 아래 여백을
                // 더 주기 위해 16줄로 늘림.
                output.addAll(byteArrayOf(0x1B, 0x64, 0x10).toList()) // 16줄 피드
                output.addAll(byteArrayOf(0x1D, 0x56, 0x42, 0x00).toList()) // 완전 컷팅

                val writeResult = service.write(output.toByteArray())
                if (writeResult == 0) {
                    handler.post { callback(true, null) }
                } else {
                    Log.e("FLOWHUB_DEBUG", "❌ 영수증 전송 실패 (결과 코드: $writeResult)")
                    handler.post { callback(false, "영수증 프린터 쓰기 실패 (코드: $writeResult)") }
                }
            } catch (e: Exception) {
                Log.e("FLOWHUB_DEBUG", "❌ 영수증 출력 오류: ${e.message}")
                handler.post { callback(false, e.message) }
            } finally {
                try {
                    service?.disconnect()
                } catch (e: Exception) {
                    // 연결 정리 중 예외는 무시 — 이미 출력 결과는 위에서 콜백으로 전달됨
                }
            }
        }.start()
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
        Log.d("FLOWHUB_DEBUG", "🔗 프린터 연결 시도 중... IP: $printerIp")
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
                    Log.d("FLOWHUB_DEBUG", "🔌 프린터 연결 시도 $attempt/$maxRetries (IP: $printerIp)")
                    val result = networkService?.connect(printerIp, 9100, 3000, false)
                    Log.d("FLOWHUB_DEBUG", "📡 연결 결과 코드: $result (시도 $attempt/$maxRetries)")
                    if (result == 0) {
                        Log.d("FLOWHUB_DEBUG", "✅ 프린터 연결 성공! (시도 $attempt/$maxRetries)")
                        connected = true
                        break
                    } else {
                        Log.w("FLOWHUB_DEBUG", "⚠️ 연결 실패 (시도 $attempt/$maxRetries, result=$result)")
                    }
                } catch (e: Exception) {
                    Log.e("FLOWHUB_DEBUG", "❌ 연결 예외 발생 (시도 $attempt/$maxRetries): ${e.message}")
                }
            }

            if (connected) {
                handler.post { statusSink?.success("CONNECTED") }
                checkPrinterStatusLoop()
            } else {
                Log.e("FLOWHUB_DEBUG", "❌ 프린터 연결 최종 실패 (총 ${maxRetries}회 시도)")
                handler.post { statusSink?.success("DISCONNECTED") }
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
        var succeeded = false

        try {
            networkService?.write(asbr)
            val response = networkService?.read(200)
            if (response != null && response.size >= 3) {
                succeeded = true
                // 3번째 바이트(index 2)의 0x80 비트: 1 = 라벨 있음, 0 = 라벨 없음
                val isPaperPresent = (response[2].toInt() and 0x80) == 0x80
                val currentStatus = if (isPaperPresent) "ATTACHED" else "DETACHED"
                val changed = currentStatus != lastStatus
                if (changed) {
                    Log.d("FLOWHUB_DEBUG", "🔔 상태 변경 감지: $currentStatus")
                }
                lastStatus = currentStatus
                // 평소(awaitingDetach=false)엔 예전처럼 값이 바뀔 때만 전송 —
                // 큐에 아무 것도 안 걸려있는데 매 폴링마다 보내면 하루종일
                // 채널/로그만 스팸이 된다. 라벨 하나가 실제로 탈부착 대기 중일
                // 때(awaitingDetach=true)만 매 폴링 결과를 그대로 흘려보내서,
                // edge를 놓쳐도 바로 다음 폴링에서 실제 현재 상태로 자체 복구되게
                // 한다 — Flutter 쪽에서 대기 중인 job이 있을 때만 이 플래그를 켠다.
                if (changed || awaitingDetach) {
                    handler.post {
                        statusSink?.success(currentStatus)
                    }
                }
            } else {
                Log.w("FLOWHUB_DEBUG", "⚠️ 프린터 상태 응답 없음/짧음")
            }
        } catch (e: Exception) {
            Log.w("FLOWHUB_DEBUG", "⚠️ 프린터 상태 조회 실패: ${e.message}")
        }

        if (succeeded) {
            consecutiveStatusFailures = 0
        } else {
            consecutiveStatusFailures++
            if (consecutiveStatusFailures >= maxConsecutiveStatusFailures) {
                // 절전모드/전원 차단 등으로 프린터가 더 이상 실제 상태 조회에
                // 응답하지 않는 것으로 판단 — 연속 3회(약 1.5초)까지는 일시적
                // 통신 지연으로 보고 넘기지만, 그 이상은 연결이 끊긴 것으로
                // 취급해 Flutter 쪽에 DISCONNECTED를 알려준다 (그동안은 최초
                // 연결 성공 시 보낸 CONNECTED 신호가 끊김 여부와 무관하게
                // 화면에 그대로 남아있었다).
                Log.e("FLOWHUB_DEBUG", "❌ 프린터 응답 없음 ${consecutiveStatusFailures}회 연속 — 연결 끊김으로 판단")
                isMonitoring = false
                lastStatus = null
                consecutiveStatusFailures = 0
                networkService?.disconnect()
                networkService = null
                handler.post { statusSink?.success("DISCONNECTED") }
                return
            }
        }

        handler.postDelayed({ checkPrinterStatusLoop() }, 500)
    }
}
