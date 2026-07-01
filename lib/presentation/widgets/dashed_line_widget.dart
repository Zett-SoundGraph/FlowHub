import 'package:flutter/material.dart';

/// A vertical dashed line widget for use as a visual divider.
/// Reusable across the app wherever a dashed separator is needed.
class DashedLineWidget extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  const DashedLineWidget({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.dashHeight = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashHeight: dashHeight,
        dashSpace: dashSpace,
      ),
      size: const Size(2, double.infinity),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashHeight,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashHeight != dashHeight ||
      oldDelegate.dashSpace != dashSpace;
}
