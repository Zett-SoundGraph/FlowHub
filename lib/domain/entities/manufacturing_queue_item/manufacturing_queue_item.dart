class ManufacturingQueueItem {
  final String machineIp;
  final String productKey;
  final String machineOrderNo; // "1001.01" — Caye 전송용
  final String orderNo;        // "1001" — KDS 리스트 탐색용
  final int subItemIndex;      // Order.items 내 인덱스
  final bool isExtraShot;
  final String qrData;         // 라벨 인쇄용 QR 페이로드

  const ManufacturingQueueItem({
    required this.machineIp,
    required this.productKey,
    required this.machineOrderNo,
    required this.orderNo,
    required this.subItemIndex,
    this.isExtraShot = false,
    this.qrData = '',
  });
}
