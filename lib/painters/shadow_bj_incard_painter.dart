import 'package:flutter/material.dart';

class ShadowBjIncardPainter extends CustomPainter {
  final double radius;
  final bool isCircle;

  ShadowBjIncardPainter({
    required this.radius,
    this.isCircle = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff080E22).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final path = Path();
    if (isCircle) {
      path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShadowBjIncardPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.isCircle != isCircle;
  }
}
