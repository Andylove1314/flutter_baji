import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../slider_normal_parameter.dart';
import 'align_widget.dart';

class FontAlignPanel extends StatefulWidget {
  /// 初始化参数
  TextAlign? textAlign;
  double? worldSpace;
  double? lineSpace;
  double? curveRadius;

  final Function(double? worldSpace) onWorldSpaceChanged;
  final Function(double? lineSpace) onLineSpaceChanged;
  final Function(TextAlign? align) onAlignChanged;
  final Function(double? curveRadius) onCurveRadiusChanged;

  FontAlignPanel(
      {super.key,
      required this.onWorldSpaceChanged,
      required this.onLineSpaceChanged,
      required this.onAlignChanged,
      required this.onCurveRadiusChanged,
      this.textAlign,
      this.worldSpace,
      this.lineSpace,
      this.curveRadius});

  @override
  State<StatefulWidget> createState() => _FontAlignPanelState();
}

class _FontAlignPanelState extends State<FontAlignPanel>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                '字弯曲',
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
                  initValue: widget.curveRadius ?? 0.0,
                  max: 30.0,
                  min: -30,
                  onChanged: (double value) {
                    debugPrint('curveRadius: $value');
                    widget.onCurveRadiusChanged.call(value);
                  },
                ),
              ),
            ],
          ).paddingOnly(top: 33, bottom: 20, left: 22, right: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '字间距',
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
                  initValue: widget.worldSpace ?? 0.0,
                  max: 6.0,
                  min: 0.0,
                  onChanged: (double value) {
                    debugPrint('worldspace: $value');
                    widget.onWorldSpaceChanged.call(value);
                  },
                ),
              ),
            ],
          ).paddingOnly(bottom: 20, left: 22, right: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '行间距',
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
                  initValue: widget.lineSpace ?? 0.0,
                  max: 6.0,
                  min: 0.0,
                  onChanged: (double value) {
                    debugPrint('linespace: $value');
                    widget.onLineSpaceChanged.call(value);
                  },
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 22),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: AlignWidget(
              textAlign: widget.textAlign,
              onAlign: (align) {
                debugPrint('alignttype: $align');
                widget.onAlignChanged.call(align);
              },
            ),
          ))
        ],
      ),
    );
  }
}
