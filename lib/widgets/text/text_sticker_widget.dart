import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sticker_added_controller.dart';
import '../../painters/text_sticker_painter.dart';
import 'dart:math' as math;

class TextStickerWidget extends StatelessWidget {
  final StickerAddedController controller;
  final double fontSize;

  const TextStickerWidget({
    Key? key,
    required this.controller,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final screenWidth = MediaQuery.of(context).size.width;

      // 根据弯曲程度计算字体缩放比例
      final curveRadius = controller.curveRadius.value;
      final curvatureRatio = math.min(1.0, curveRadius.abs() / 100);
      final scaleFactor = math.max(
          0.5, 1.0 - (controller.text.value.length / 20) * curvatureRatio);

      // 创建一个临时的 TextPainter 来计算文本尺寸
      final textPainter = TextPainter(
        text: TextSpan(
          text: controller.text.value,
          style: TextStyle(
            fontFamily:
                controller.font.value.isNotEmpty ? controller.font.value : null,
            fontSize: fontSize * scaleFactor, // 应用缩放比例
            fontWeight:
                controller.bold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                controller.italic.value ? FontStyle.italic : FontStyle.normal,
            decoration: controller.underline.value
                ? TextDecoration.underline
                : TextDecoration.none,
            letterSpacing:
                controller.worldSpace.value * scaleFactor, // 字间距也需要缩放
            height: 1 + controller.lineSpace.value,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: controller.textAlign.value,
      );

      // 计算文本尺寸，限制最大宽度为屏幕宽度
      textPainter.layout(minWidth: 0, maxWidth: screenWidth * 0.9);
      final textSize = textPainter.size;

      // 根据弯曲程度和文本长度动态计算额外的高度空间
      final extraHeightRatio = math.max(
          curvatureRatio, (controller.text.value.length / 10) * curvatureRatio);
      final extraHeight =
          curveRadius != 0 ? textSize.height * extraHeightRatio : 0.0;

      // 使用计算出的尺寸创建 CustomPaint
      return CustomPaint(
        size: Size(
            textSize.width, textSize.height + extraHeight * 2), // 添加动态计算的额外高度空间
        painter: TextStickerPainter(
            fontSize: fontSize,
            opacity: controller.opacity.value,
            text: controller.text.value,
            font: controller.font.value,
            color: controller.color.value,
            bold: controller.bold.value,
            italic: controller.italic.value,
            underline: controller.underline.value,
            textAlign: controller.textAlign.value,
            worldSpace: controller.worldSpace.value * scaleFactor, // 应用缩放
            lineSpace: controller.lineSpace.value,
            strokeColor: controller.strokeColor.value,
            curveRadius: controller.curveRadius.value,
            strokeWidth: controller.strokeWidth.value),
      );
    });
  }
}
