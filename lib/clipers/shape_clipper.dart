import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ShapeClipper extends CustomClipper<Path> {
  final bool isCircle;
  final double marginLeft;
  final double marginRight;
  final double bjRatio;
  final double radius;

  ShapeClipper({
    required this.isCircle,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.bjRatio = 1.0,
    this.radius = 10.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final adjustedWidth = size.width - marginLeft - marginRight;
    final height = adjustedWidth / bjRatio;
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
        height: height,
      );
      path.addRRect(RRect.fromRectAndRadius(
        rect,
        Radius.circular(radius),
      ));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant ShapeClipper oldClipper) {
    return oldClipper.isCircle != isCircle ||
        oldClipper.marginLeft != marginLeft ||
        oldClipper.marginRight != marginRight ||
        oldClipper.bjRatio != bjRatio ||
        oldClipper.radius != radius;
  }
}
