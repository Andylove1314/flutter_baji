// 添加自定义画板
import 'package:flutter/material.dart';

// 自定义颜色画板
class ColorPanelPainter extends CustomPainter {
  final Color baseColor;

  ColorPanelPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect roundedRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );

    // 创建水平渐变（饱和度）
    final horizontalGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        HSVColor.fromColor(baseColor).withSaturation(0.0).toColor(),
        HSVColor.fromColor(baseColor).withSaturation(1.0).toColor(),
      ],
    );

    // 创建垂直渐变（明度）
    final verticalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.black,
      ],
    );

    // 使用圆角矩形绘制渐变
    canvas.drawRRect(
      roundedRect,
      Paint()..shader = horizontalGradient.createShader(roundedRect.outerRect),
    );

    canvas.drawRRect(
      roundedRect,
      Paint()..shader = verticalGradient.createShader(roundedRect.outerRect),
    );
  }

  @override
  bool shouldRepaint(ColorPanelPainter oldDelegate) =>
      baseColor != oldDelegate.baseColor;
}
