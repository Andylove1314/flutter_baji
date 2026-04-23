import 'package:flutter/material.dart';

import '../widgets/change_bg/color_gradient_picker_panel.dart';
import 'dart:math' as math;

class BgPainter extends CustomPainter {
  final GradientType? type;
  final List<Color> colors;
  final List<double> stops;
  final ImageInfo? bjBgImage;
  final bool isCircle;
  final double marginLeft;
  final double marginRight;
  final bool paintTexture;
  final Offset gradientStart;
  final Offset gradientEnd;
  final double bjRatio;
  final double radius;

  BgPainter({
    required this.isCircle,
    required this.marginLeft,
    required this.marginRight,
    this.type,
    this.colors = const [],
    this.stops = const [],
    this.bjBgImage,
    this.paintTexture = false,
    this.gradientStart = const Offset(0, 0),
    this.gradientEnd = const Offset(0, 0),
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
      size.height / 2,
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

    if (paintTexture && bjBgImage != null) {
      final paint = Paint();
      canvas.clipPath(path);

      final targetRect = isCircle
          ? Rect.fromCircle(
              center: center,
              radius: adjustedWidth / 2,
            )
          : Rect.fromCenter(
              center: center,
              width: adjustedWidth,
              height: adjustedHeight,
            );

      final imageRatio = bjBgImage!.image.width / bjBgImage!.image.height;
      final targetRatio = targetRect.width / targetRect.height;

      double srcWidth, srcHeight, srcX, srcY;
      if (imageRatio > targetRatio) {
        srcHeight = bjBgImage!.image.height.toDouble();
        srcWidth = srcHeight * targetRatio;
        srcX = (bjBgImage!.image.width - srcWidth) / 2;
        srcY = 0;
      } else {
        srcWidth = bjBgImage!.image.width.toDouble();
        srcHeight = srcWidth / targetRatio;
        srcX = 0;
        srcY = (bjBgImage!.image.height - srcHeight) / 2;
      }

      // 调整绘制区域以确保完全覆盖
      final adjustedTargetRect = Rect.fromLTWH(
        targetRect.left - 1,
        targetRect.top - 1,
        targetRect.width + 2,
        targetRect.height + 2,
      );

      canvas.drawImageRect(
        bjBgImage!.image,
        Rect.fromLTWH(srcX, srcY, srcWidth, srcHeight),
        adjustedTargetRect,
        paint,
      );
    } else {
      final paint = Paint();
      final rect = isCircle
          ? Rect.fromCircle(
              center: center,
              radius: adjustedWidth / 2,
            )
          : Rect.fromCenter(
              center: center,
              width: adjustedWidth,
              height: adjustedHeight,
            );
      // 计算渐变角度，如果起点和终点相同则使用0度
      final angle = (gradientStart == gradientEnd)
          ? math.pi / 2
          : math.atan2(gradientEnd.dy - gradientStart.dy,
              gradientEnd.dx - gradientStart.dx);
      if (type == GradientType.linear) {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          transform: GradientRotation(angle - math.pi / 2),
          colors: colors!,
          stops: stops,
        ).createShader(rect);
      } else {
        paint.shader = RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          transform: GradientRotation(angle - math.pi / 2),
          colors: colors!,
          stops: stops,
        ).createShader(rect);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BgPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.colors != colors ||
        oldDelegate.stops != stops ||
        oldDelegate.bjBgImage != bjBgImage ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.gradientStart != gradientStart ||
        oldDelegate.gradientEnd != gradientEnd ||
        oldDelegate.bjRatio != bjRatio ||
        oldDelegate.radius != radius;
  }
}
