import 'dart:ui';

import 'package:flutter/material.dart';

class TargetContainerPainter extends CustomPainter {
  final bool isCircle;
  final double marginTop;
  final double marginLeft;
  final double marginRight;
  final double bjRatio;
  final double radius;
  Color? maskColor;

  TargetContainerPainter({
    required this.isCircle,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.bjRatio = 1.0,
    this.radius = 10.0,
    this.maskColor,
  }) {
    maskColor ??= Colors.black.withOpacity(0.3);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final adjustedWidth = size.width - marginLeft - marginRight;
    final adjustedCenter = Offset(
      marginLeft + adjustedWidth / 2,
      size.height / 2,
    );

    // 创建一个遮罩层路径，并设置填充规则
    Path maskPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (isCircle) {
      _drawCircle(canvas, adjustedCenter, adjustedWidth, maskPath);
    } else {
      _drawRect(canvas, adjustedCenter, adjustedWidth, maskPath);
    }

    // 绘制遮罩层
    final paint = Paint()
      ..color = maskColor!
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, paint);
  }

  void _drawRect(Canvas canvas, Offset center, double width, Path maskPath) {
    final innerRect = Rect.fromCenter(
      center: center,
      width: width,
      height: width / bjRatio,
    );

    // 从遮罩层中减去内部区域
    maskPath
        .addRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(radius)));
  }

  void _drawCircle(Canvas canvas, Offset center, double width, Path maskPath) {
    // 从遮罩层中减去内部圆形
    maskPath.addOval(Rect.fromCircle(
      center: center,
      radius: width / 2,
    ));
  }

  @override
  bool shouldRepaint(TargetContainerPainter oldDelegate) {
    return oldDelegate.isCircle != isCircle ||
        oldDelegate.marginTop != marginTop ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.bjRatio != bjRatio ||
        oldDelegate.radius != radius;
  }
}
