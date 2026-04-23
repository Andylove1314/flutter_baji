import 'package:flutter/material.dart';

class BubbleContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final bool showArrow; // 添加箭头显示控制
  final double? height;
  final double arrowOffsetRatio;

  const BubbleContainer({
    Key? key,
    required this.child,
    this.padding,
    this.arrowWidth = 10.0,
    this.arrowHeight = 6.0,
    this.borderRadius = 8.0,
    this.showArrow = true, // 默认显示箭头
    this.height,
    this.arrowOffsetRatio = 0.25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(
        arrowWidth: arrowWidth,
        arrowHeight: arrowHeight,
        borderRadius: borderRadius,
        showArrow: showArrow,
        arrowOffsetRatio: arrowOffsetRatio,
      ),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.fromLTRB(30, 15, 30, 20),
        child: child,
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final bool showArrow;
  final double arrowOffsetRatio;

  BubblePainter({
    required this.arrowWidth,
    required this.arrowHeight,
    required this.borderRadius,
    required this.showArrow,
    required this.arrowOffsetRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF323233)
      ..style = PaintingStyle.fill;

    final path = Path();

    if (showArrow) {
      // 计算箭头位置（左侧arrowOffsetRatio处）
      final arrowCenter = size.width * arrowOffsetRatio;

      // 绘制箭头
      path.moveTo(arrowCenter - arrowWidth / 2, size.height - arrowHeight);
      path.lineTo(arrowCenter, size.height);
      path.lineTo(arrowCenter + arrowWidth / 2, size.height - arrowHeight);
    }

    // 绘制圆角矩形主体
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
          0, 0, size.width, size.height - (showArrow ? arrowHeight : 0)),
      Radius.circular(borderRadius),
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.showArrow != showArrow ||
        oldDelegate.arrowWidth != arrowWidth ||
        oldDelegate.arrowHeight != arrowHeight ||
        oldDelegate.borderRadius != borderRadius;
  }
}
