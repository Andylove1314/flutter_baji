import 'dart:ui';

import 'package:flutter/material.dart';

class SolidBorderPainter extends CustomPainter {
  final bool isCircle;
  final double marginTop;
  final double marginLeft;
  final double marginRight;
  final double bjRatio;
  final double radius;
  final double bloodRatio;

  SolidBorderPainter({
    required this.isCircle,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.bjRatio = 1.0,
    this.radius = 10.0,
    this.bloodRatio = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final adjustedWidth = size.width - marginLeft - marginRight;
    double lineWidth = bloodRatio * adjustedWidth / 2;
    final adjustedCenter = Offset(
      marginLeft + adjustedWidth / 2,
      size.height / 2,
    );

    if (isCircle) {
      _drawCircle(canvas, adjustedCenter, adjustedWidth, lineWidth);
    } else {
      _drawRect(canvas, adjustedCenter, adjustedWidth, lineWidth);
    }
  }

  void _drawRect(Canvas canvas, Offset center, double width, double lineWidth) {
    // 创建外矩形路径
    final outerPath = Path();
    final outerRect = Rect.fromCenter(
      center: center,
      width: width,
      height: width / bjRatio,
    );
    outerPath
        .addRRect(RRect.fromRectAndRadius(outerRect, Radius.circular(radius)));

    // 创建内矩形路径
    final innerPath = Path();
    final innerRect = Rect.fromCenter(
      center: center,
      width: width - lineWidth * 2,
      height: (width / bjRatio) - lineWidth * 2,
    );
    innerPath
        .addRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(radius)));

    // 使用路径差集创建边框
    final borderPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);

    // 绘制边框
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(borderPath, paint);

    // 添加白色外边框
    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius)),
        whiteBorderPaint);

    // 添加虚线边框
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dashRect = Rect.fromCenter(
      center: center,
      width: width - lineWidth * 2 + 2, // 移除外延
      height: (width / bjRatio) - lineWidth * 2 + 2, // 移除外延
    );

    final Path dashPath = Path();
    dashPath
        .addRRect(RRect.fromRectAndRadius(dashRect, Radius.circular(radius)));

    final Path dashedPath = Path();
    const double dashWidth = 5;
    const double dashSpace = 5;

    for (PathMetric metric in dashPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, dashPaint);
  }

  void _drawCircle(
      Canvas canvas, Offset center, double width, double lineWidth) {
    // 创建外圆路径
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: width / 2));

    // 创建内圆路径
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: width / 2 - lineWidth));

    // 使用路径差集创建边框
    final borderPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);

    // 绘制边框
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(borderPath, paint);

    // 添加白色外边框
    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, width / 2, whiteBorderPaint);

    // 添加虚线边框
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 在 _drawCircle 方法中
    final Path dashPath = Path()
      ..addOval(Rect.fromCircle(
        center: center,
        radius: width / 2 - lineWidth + 2, // 移除外延
      ));

    final Path dashedPath = Path();
    const double dashWidth = 5;
    const double dashSpace = 5;

    for (PathMetric metric in dashPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, dashPaint);
  }

  @override
  bool shouldRepaint(SolidBorderPainter oldDelegate) {
    return oldDelegate.isCircle != isCircle ||
        oldDelegate.marginTop != marginTop ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.bjRatio != bjRatio ||
        oldDelegate.radius != radius ||
        oldDelegate.bloodRatio != bloodRatio;
  }
}
