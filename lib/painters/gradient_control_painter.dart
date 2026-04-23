import 'package:flutter/material.dart';

class GradientControlPainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final double lineSize;

  GradientControlPainter({
    required this.startPoint,
    required this.endPoint,
    this.lineSize = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制连接线描边
    final strokePaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = lineSize + 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startPoint, endPoint, strokePaint);

    // 绘制连接线
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = lineSize
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startPoint, endPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant GradientControlPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.lineSize != lineSize;
  }
}
