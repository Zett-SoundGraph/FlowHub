import 'package:flutter/material.dart';
import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderLabelWidget extends StatelessWidget {
  final String orderNo;
  final String sequence;
  final String totalSequence;
  final List<String> menus;
  final String qrData;
  final MenuRecipe? recipe;
  final String dispenserData;

  const OrderLabelWidget({
    super.key,
    required this.orderNo,
    this.sequence = '01',
    this.totalSequence = '01',
    required this.menus,
    required this.qrData,
    this.recipe,
    this.dispenserData = 'N:0',
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle productStyle = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontWeight: FontWeight.w400,
      fontSize: 24.0,
      height: 1.1,
      letterSpacing: -0.5,
      color: Colors.black,
    );
    const TextStyle footerStyle = TextStyle(
      fontFamily: 'JetBrainsMono',
      fontWeight: FontWeight.w400,
      fontSize: 20.0,
      height: 1.1,
      letterSpacing: -0.5,
      color: Colors.black,
    );

    final String currentTime = DateTime.now().toString().substring(0, 19);

    return Container(
      width: 384,
      color: Colors.white,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 좌측: 회전된 주문번호
            Container(
              padding: const EdgeInsets.only(left: 4.0, top: 12.0, right: 12.0),
              alignment: Alignment.topCenter,
              child: RotatedBox(
                quarterTurns: 3,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.w700,
                      fontSize: 50.0,
                      height: 1.0,
                      letterSpacing: -1.5,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: orderNo),
                      TextSpan(
                        text: '.$sequence/$totalSequence',
                        style: const TextStyle(fontSize: 50.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 중간: 수직 점선
            CustomPaint(
              painter: _DashedLinePainter(),
              size: const Size(2, double.infinity),
            ),

            const SizedBox(width: 12),

            // 우측: QR + 메뉴 정보
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  SizedBox(
                    width: 120.0,
                    height: 120.0,
                    child: QrImageView(
                      data: qrData.isNotEmpty ? qrData : orderNo,
                      size: 120.0,
                      padding: EdgeInsets.zero,
                      gapless: false,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '[PRODUCT]',
                    style: productStyle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    menus.isNotEmpty ? menus.first : '-',
                    style: productStyle.copyWith(fontSize: 20),
                  ),
                  Text(
                    'Version: 0.94.0506.02',
                    style: productStyle.copyWith(fontSize: 20),
                  ),

                  const SizedBox(height: 12),

                  // 레시피 옵션 (있을 때만 표시)
                  if (recipe != null) ...[
                    Text('[OPTION]', style: productStyle.copyWith(fontWeight: FontWeight.w700)),
                    ...recipe!.optionLines.map(
                      (line) => Text(line, style: productStyle.copyWith(fontSize: 20)),
                    ),
                    // 디스펜서 추가 재료
                    if (dispenserData.isNotEmpty && dispenserData != 'N:0') ...[
                      () {
                        final parts = dispenserData.split(':');
                        if (parts.length == 2) {
                          final name = parts[0].replaceAll('_', ' ').toUpperCase();
                          return Text('- $name: ${parts[1]}g', style: productStyle.copyWith(fontSize: 20));
                        }
                        return const SizedBox.shrink();
                      }(),
                    ],
                  ],

                  const SizedBox(height: 36),

                  Text('ORDER TIME: $currentTime', style: footerStyle),
                  const Text('BUILD BY CAFE.BETA OS', style: footerStyle),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashHeight = 5.0;
    const double dashSpace = 4.0;
    double startY = 0.0;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
