import 'dart:math';
import 'package:flutter/material.dart';

class TextStickerPainter extends CustomPainter {
  final double opacity;
  final String text;
  final String font;
  final String color;
  final bool bold;
  final bool italic;
  final bool underline;
  final TextAlign textAlign;
  final double worldSpace;
  final double lineSpace;
  final String strokeColor;
  final double curveRadius;
  final double strokeWidth;
  final double fontSize;

  TextStickerPainter(
      {required this.fontSize,
      this.opacity = 1.0,
      this.text = '',
      this.font = '',
      this.color = '',
      this.bold = false,
      this.italic = false,
      this.underline = false,
      this.textAlign = TextAlign.left,
      this.worldSpace = 0.0,
      this.lineSpace = 0.0,
      this.strokeColor = '',
      this.curveRadius = 0.0,
      this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (curveRadius == 0) {
      _paintNormalText(canvas, size);
    } else {
      _paintCurvedText(canvas, size);
    }
  }

  Color _parseColor(String colorString) {
    if (colorString.isEmpty) return Colors.transparent;
    if (colorString == '0x00000000') return Colors.transparent;

    try {
      final colorValue = int.parse(colorString);
      if (colorValue == 0) return Colors.transparent;
      return Color(colorValue).withOpacity(opacity);
    } catch (e) {
      return Colors.transparent;
    }
  }

  void _paintNormalText(Canvas canvas, Size size) {
    final baseStyle = TextStyle(
      fontFamily: font.isNotEmpty ? font : null,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      letterSpacing: worldSpace,
      height: 1 + lineSpace,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(
          color: _parseColor(color),
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;
    final dx = (size.width - textWidth) / 2;
    final dy = (size.height - textHeight) / 2;

    if (strokeColor.isNotEmpty) {
      final strokePaint = Paint()
        ..color = _parseColor(strokeColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final strokeTextPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: baseStyle.copyWith(foreground: strokePaint),
        ),
        textAlign: textAlign,
        textDirection: TextDirection.ltr,
      );

      strokeTextPainter.layout(minWidth: 0, maxWidth: size.width);
      strokeTextPainter.paint(canvas, Offset(dx, dy));
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant TextStickerPainter oldDelegate) {
    return opacity != oldDelegate.opacity ||
        text != oldDelegate.text ||
        font != oldDelegate.font ||
        color != oldDelegate.color ||
        bold != oldDelegate.bold ||
        italic != oldDelegate.italic ||
        underline != oldDelegate.underline ||
        textAlign != oldDelegate.textAlign ||
        worldSpace != oldDelegate.worldSpace ||
        lineSpace != oldDelegate.lineSpace ||
        strokeColor != oldDelegate.strokeColor ||
        curveRadius != oldDelegate.curveRadius ||
        strokeWidth != oldDelegate.strokeWidth ||
        fontSize != oldDelegate.fontSize;
  }

  void _paintCurvedText(Canvas canvas, Size size) {
    final baseStyle = TextStyle(
      fontFamily: font.isNotEmpty ? font : null,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      letterSpacing: worldSpace,
      height: 1 + lineSpace,
    );

    List<TextPainter> charPainters = [];
    double totalWidth = 0;
    double maxCharWidth = 0;

    for (int i = 0; i < text.length; i++) {
      final charPainter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: baseStyle.copyWith(color: _parseColor(color)),
        ),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();
      charPainters.add(charPainter);
      totalWidth += charPainter.width;
      maxCharWidth = max(maxCharWidth, charPainter.width);
    }

    final totalSpacing = (text.length - 1) * worldSpace;
    final adjustedTotalWidth = totalWidth + totalSpacing;
    final radius = adjustedTotalWidth * 0.5;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    double currentX = -adjustedTotalWidth / 2;
    for (int i = 0; i < charPainters.length; i++) {
      final charPainter = charPainters[i];
      final charWidth = charPainter.width;
      final charCenter = currentX + charWidth / 2;

      final progress = (charCenter + adjustedTotalWidth / 2) / adjustedTotalWidth;
      final normalizedX = (progress - 0.5) * 2;
      final curve = pow(1 - normalizedX * normalizedX, 1.5);
      final y = -curve * radius * (curveRadius / 50.0);

      canvas.save();
      canvas.translate(charCenter, y);

      // 计算平滑的旋转角度
      final rotationAngle = -normalizedX * curve * (curveRadius / 25.0);
      canvas.rotate(rotationAngle);

      if (strokeColor.isNotEmpty) {
        final strokePaint = Paint()
          ..color = _parseColor(strokeColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

        final strokeCharPainter = TextPainter(
          text: TextSpan(
            text: text[i],
            style: baseStyle.copyWith(foreground: strokePaint),
          ),
          textDirection: TextDirection.ltr,
        );
        strokeCharPainter.layout();
        strokeCharPainter.paint(
            canvas, Offset(-charWidth / 2, -charPainter.height / 2));
      }

      charPainter.paint(
          canvas, Offset(-charWidth / 2, -charPainter.height / 2));
      canvas.restore();

      currentX += charWidth + worldSpace;
    }

    canvas.restore();
  }
}
