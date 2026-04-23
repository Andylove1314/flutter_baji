import 'package:flutter/material.dart';

class ShadowBjPrePainter extends CustomPainter {
  final bool isCircle;
  final double marginLeft;
  final double marginRight;
  final double bjRatio;
  final double radius;

  ShadowBjPrePainter({
    required this.isCircle,
    required this.marginLeft,
    required this.marginRight,
    this.bjRatio = 1.0,
    this.radius = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final adjustedWidth = size.width - marginLeft - marginRight;
    final adjustedHeight = adjustedWidth / bjRatio;
    final path = Path();

    final center = Offset(
      marginLeft + adjustedWidth / 2,
      size.height / 2, // 修改为使用整体高度的中心点
    );

    if (isCircle) {
      path.addOval(Rect.fromCircle(
        center: center,
        radius: adjustedWidth / 2,
      ));
    } else {
      final rect = Rect.fromCenter(
        center: center,
        width: adjustedWidth,
        height: adjustedHeight,
      );
      path.addRRect(RRect.fromRectAndRadius(
        rect,
        Radius.circular(radius),
      ));
    }

    final paint = Paint()
      ..color = const Color(0xffCBCFDD)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShadowBjPrePainter oldDelegate) {
    return oldDelegate.isCircle != isCircle ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.bjRatio != bjRatio ||
        oldDelegate.radius != radius;
  }
}
