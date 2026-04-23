import 'package:flutter/material.dart';

class BadgetCompassPainter extends CustomPainter {
  final bool isCircle;
  final double marginLeft;
  final double marginRight;
  final double bjRatio;
  final double radius;
  final double bloodRatio;

  BadgetCompassPainter({
    required this.isCircle,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.bjRatio = 1.0,
    this.radius = 10.0,
    this.bloodRatio = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trianglePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final adjustedWidth = size.width - marginLeft - marginRight;
    double lineWidth = bloodRatio * adjustedWidth / 2;
    final double offset = -lineWidth / 2;
    final adjustedHeight = adjustedWidth / bjRatio;
    final adjustedCenter = Offset(
      marginLeft + adjustedWidth / 2,
      size.height / 2, // 修改为使用整体高度的中心点
    );

    // 绘制三角形
    final trianglePath = Path();
    var triangleHeight = lineWidth / 3;  // 修改为 1/3
    var triangleWidth = triangleHeight * 2 * 0.866;  // 等边三角形的宽度计算
    var halfStrokeWidth = triangleHeight / 2;

    // 三角形路径
    trianglePath.moveTo(
        adjustedCenter.dx - triangleWidth / 2,
        adjustedCenter.dy -
            adjustedHeight / 2 -
            offset +
            halfStrokeWidth -
            lineWidth / 4);
    trianglePath.lineTo(
        adjustedCenter.dx + triangleWidth / 2,
        adjustedCenter.dy -
            adjustedHeight / 2 -
            offset +
            halfStrokeWidth -
            lineWidth / 4);
    trianglePath.lineTo(
        adjustedCenter.dx,
        adjustedCenter.dy -
            adjustedHeight / 2 -
            offset -
            triangleHeight +
            halfStrokeWidth -
            lineWidth / 4);
    trianglePath.close();

    // 绘制三角形描边
    final Paint triangleStrokePaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 先绘制描边，再绘制填充
    canvas.drawPath(trianglePath, triangleStrokePaint);
    canvas.drawPath(trianglePath, trianglePaint);
  }

  @override
  bool shouldRepaint(BadgetCompassPainter oldDelegate) {
    return oldDelegate.isCircle != isCircle ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.bjRatio != bjRatio ||
        oldDelegate.radius != radius ||
        oldDelegate.bloodRatio != bloodRatio;
  }
}
