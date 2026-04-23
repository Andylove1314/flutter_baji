import 'package:flutter/material.dart';
import 'package:flutter_baji/models/action_data.dart';

import '../../constants/constant.dart';
import '../../constants/constant_bj.dart';
import '../../flutter_baji.dart';
import '../confirm_bar.dart';
import 'align/font_align_panel.dart';
import 'font/font_font_panel.dart';
import 'style/font_style_panel.dart';

class TextPanel extends StatefulWidget {
  /// 初始化参数
  FontDetail? fontDetail;
  String? color;
  double? opacity;
  bool? bold;
  bool? italic;
  bool? underline;
  TextAlign? textAlign;
  double? worldSpace;
  double? lineSpace;
  double? curveRadius;
  String? strokeColor;
  double strokeWidth;

  final VoidCallback? onClose;
  final VoidCallback? onConfirm;

  /// 字体
  final Function({FontDetail? item, String? ttfPath, String? imgPath})
      onFontChanged;

  ///样式
  final Function(String? color) onColorChanged;
  final Function(double? opacity) onOpacityChanged;

  final Function(bool? bold) onBold;
  final Function(bool? italic) onItalic;
  final Function(bool? underline) onUnderline;

  /// 对齐
  final Function(double? worldSpace) onWorldSpaceChanged;
  final Function(double? lineSpace) onLineSpaceChanged;
  final Function(TextAlign? align) onAlignChanged;
  final Function(double? curveRadius) onCurveRadiusChanged;
  final Function(String? color) onStrokeColorChanged;
  final Function(double? strokeWidth) onStrokeWidthChanged;

  /// 保存
  final Function() onEffectSave;

  final int? initialIndex;

  final int type;

  TextPanel(
      {super.key,
      required this.type,
      required this.onFontChanged,
      required this.onColorChanged,
      required this.onOpacityChanged,
      required this.onBold,
      required this.onItalic,
      required this.onUnderline,
      required this.onWorldSpaceChanged,
      required this.onLineSpaceChanged,
      required this.onAlignChanged,
      required this.onEffectSave,
      required this.onCurveRadiusChanged,
      required this.onStrokeColorChanged,
      required this.onStrokeWidthChanged,
      this.onClose,
      this.onConfirm,
      this.fontDetail,
      this.color,
      this.opacity,
      this.bold,
      this.italic,
      this.underline,
      this.textAlign,
      this.worldSpace,
      this.lineSpace,
      this.initialIndex,
      this.curveRadius,
      this.strokeColor,
      this.strokeWidth = 1.0});

  @override
  State<StatefulWidget> createState() {
    return _TextPanelState();
  }
}

class _TextPanelState extends State<TextPanel> {
  int _position = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 240,
        child: IndexedStack(
          index: _position,
          children: [
            FontFontPanel(
              onChanged: (
                  {FontDetail? item,
                  String? ttfPath,
                  String? imgPath,
                  bool? showVipPop}) {
                widget.onFontChanged
                    .call(item: item, ttfPath: ttfPath, imgPath: imgPath);
              },
              fontDetail: widget.fontDetail,
            ),
            FontStylePanel(
              onColorChanged: (color) {
                widget.onColorChanged(color);
              },
              onOpacityChanged: (opacity) {
                widget.onOpacityChanged.call(opacity);
              },
              onBold: (bold) {
                widget.onBold.call(bold);
              },
              onItalic: (italic) {
                widget.onItalic.call(italic);
              },
              onUnderline: (underline) {
                widget.onUnderline.call(underline);
              },
              onStrokeColorChanged: (strokeColor) {
                widget.onStrokeColorChanged.call(strokeColor);
              },
              onStrokeWidthChanged: (double? strokeWidth) {
                widget.onStrokeWidthChanged.call(strokeWidth);
              },
              color: widget.color,
              strokeColor: widget.strokeColor,
              opacity: widget.opacity,
              bold: widget.bold,
              italic: widget.italic,
              underline: widget.underline,
              strokeWidth: widget.strokeWidth,
            ),
            FontAlignPanel(
              onWorldSpaceChanged: (ws) {
                widget.onWorldSpaceChanged.call(ws);
              },
              onLineSpaceChanged: (ls) {
                widget.onLineSpaceChanged.call(ls);
              },
              onAlignChanged: (align) {
                widget.onAlignChanged.call(align);
              },
              onCurveRadiusChanged: (curveRadius) {
                widget.onCurveRadiusChanged.call(curveRadius);
              },
              textAlign: widget.textAlign,
              worldSpace: widget.worldSpace,
              lineSpace: widget.lineSpace,
              curveRadius: widget.curveRadius,
            )
          ],
        ),
      ),
      ConfirmBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton(fontActions[0]),
            _buildTabButton(fontActions[1]),
            _buildTabButton(fontActions[2]),
          ],
        ),
        cancel: widget.onClose,
        confirm: widget.onConfirm,
      )
    ]));
  }

  Widget _buildTabButton(ActionData action) {
    final isSelected = _position == fontActions.indexOf(action);
    return GestureDetector(
      onTap: () {
        setState(() {
          _position = fontActions.indexOf(action);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action.name,
              style: TextStyle(
                color: isSelected ?  Color(0xffFF1A5A) : Color(0xff969799),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xffFF1A5A) : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
