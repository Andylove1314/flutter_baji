import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  final double aspectRatio;
  final ui.Image? maskImage;
  final bool isCircle;

  const CustomEditorCropLayerPainter({
    this.aspectRatio = 1.0,
    this.maskImage,
    this.isCircle = true,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
    Rect rect,
  ) {
    paintMask(canvas, rect, painter);
    paintCropBorder(canvas, painter);
  }

  void paintMask(
    Canvas canvas,
    Rect rect,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Rect cropRect = painter.cropRect;
    final Rect shapeRect =
        isCircle ? _getOvalRect(cropRect) : _getShapeRect(cropRect);

    // 保存图层
    canvas.saveLayer(rect, Paint());

    // 背景图或纯色遮罩
    if (maskImage != null) {
      final srcRect = Rect.fromLTWH(
        0,
        0,
        maskImage!.width.toDouble(),
        maskImage!.height.toDouble(),
      );
      canvas.drawImageRect(maskImage!, srcRect, rect, Paint());
    } else {
      canvas.drawRect(rect, Paint()..color = painter.maskColor);
    }

    // 镂空区域
    final Paint clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    if (isCircle) {
      canvas.drawOval(shapeRect, clearPaint);
    } else {
      canvas.drawRect(shapeRect, clearPaint);
    }

    canvas.restore();
  }

  void paintCropBorder(Canvas canvas, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    final Rect shapeRect =
        isCircle ? _getOvalRect(cropRect) : _getShapeRect(cropRect);

    final Paint borderPaint = Paint()
      ..color = painter.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = painter.lineHeight;

    if (isCircle) {
      canvas.drawOval(shapeRect, borderPaint);
    } else {
      canvas.drawRect(shapeRect, borderPaint);
    }
  }

  /// 矩形
  Rect _getShapeRect(Rect cropRect) {
    final Offset center = cropRect.center;
    double width, height;

    if (aspectRatio >= 1.0) {
      width = cropRect.shortestSide;
      height = width / aspectRatio;
    } else {
      height = cropRect.shortestSide;
      width = height * aspectRatio;
    }

    return Rect.fromCenter(center: center, width: width, height: height);
  }

  /// 圆形
  Rect _getOvalRect(Rect cropRect) {
    // 根据宽高比生成椭圆
    final double centerX = cropRect.center.dx;
    final double centerY = cropRect.center.dy;
    double width, height;

    if (aspectRatio >= 1.0) {
      width = cropRect.shortestSide;
      height = width / aspectRatio;
    } else {
      height = cropRect.shortestSide;
      width = height * aspectRatio;
    }

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
  }

  @override
  void paintLines(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    // 可选：绘制辅助线
  }

  @override
  void paintCorners(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    // 不绘制四角锚点
  }
}
