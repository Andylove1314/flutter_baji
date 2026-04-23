import 'package:flutter/material.dart';
import 'package:flutter_baji/constants/constant_bj.dart';
import 'package:get/get.dart';

import '../../../constants/constant.dart';
import '../../slider_normal_parameter.dart';
import '../color/color_widget.dart';
import 'style_widget.dart';

class FontStylePanel extends StatefulWidget {
  /// 初始化参数
  String? color;
  double? opacity;
  bool? bold;
  bool? italic;
  bool? underline;
  String? strokeColor;
  double strokeWidth;

  final Function(String? color) onColorChanged;
  final Function(String? color) onStrokeColorChanged;
  final Function(double? opacity) onOpacityChanged;
  final Function(double? strokeWidth) onStrokeWidthChanged;

  final Function(bool? bold) onBold;
  final Function(bool? italic) onItalic;
  final Function(bool? underline) onUnderline;

  FontStylePanel(
      {super.key,
      required this.onColorChanged,
      required this.onOpacityChanged,
      required this.onBold,
      required this.onItalic,
      required this.onUnderline,
      required this.onStrokeColorChanged,
      required this.onStrokeWidthChanged,
      this.color,
      this.opacity,
      this.bold,
      this.italic,
      this.underline,
      this.strokeColor,
      this.strokeWidth = 1.0});

  @override
  State<StatefulWidget> createState() => _FontStylePanelState();
}

class _FontStylePanelState extends State<FontStylePanel>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '填充',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff19191A)),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                  child: ColorWidget(
                colorHex: widget.color,
                initColorHex: colorStrs[1],
                onSelect: (color) {
                  debugPrint('color: $color');
                  widget.onColorChanged.call(color);
                },
              ))
            ],
          ).paddingOnly(left: 22, right: 22, bottom: 15, top: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '描边',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff19191A)),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                  child: ColorWidget(
                colorHex: widget.strokeColor,
                initColorHex: colorStrs[2],
                onSelect: (color) {
                  debugPrint('strokeColor: $color');
                  widget.onStrokeColorChanged.call(color);
                },
              ))
            ],
          ).paddingOnly(left: 22, right: 22, bottom: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '描边粗细',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff19191A)),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: SliderNormalParameterWidget(
                  initValue: widget.strokeWidth,
                  max: 10.0,
                  min: 1.0,
                  onChanged: (double value) {
                    debugPrint('strokeWidth: $value');
                    widget.onStrokeWidthChanged.call(value);
                  },
                ),
              ),
            ],
          ).paddingOnly(left: 22, right: 22, bottom: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '透明',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff19191A)),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: SliderNormalParameterWidget(
                  initValue: widget.opacity ?? 1.0,
                  max: 1.0,
                  min: 0.0,
                  onChanged: (double value) {
                    debugPrint('alpha: $value');
                    widget.onOpacityChanged.call(value);
                  },
                ),
              ),
            ],
          ).paddingOnly(left: 22, right: 22, bottom: 15),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: StyleWidget(
              bold: widget.bold,
              italic: widget.italic,
              underline: widget.underline,
              onBold: (bool bold) {
                widget.onBold.call(bold);
              },
              onItalic: (bool italic) {
                widget.onItalic.call(italic);
              },
              onUnderline: (bool underline) {
                widget.onUnderline.call(underline);
              },
            ),
          ))
        ],
      ),
    );
  }
}
