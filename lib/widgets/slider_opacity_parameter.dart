import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

import 'custom_thumb_shape.dart';
import 'custom_track_shape.dart';

///透明度调节（100）
class SliderOpacityParameterWidget extends StatelessWidget {
  final Function(double value) onChanged;
  final double value;
  final int showNumber;

  final _thumbSize = 22.0;

  SliderOpacityParameterWidget(
      {super.key,
      required this.onChanged,
      required this.value,
      this.showNumber = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '透明度',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xff656566), blurRadius: 30)]),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
              child: SliderTheme(
                  data: SliderThemeData(
                    trackShape: CustomTrackShape(thumbSize: _thumbSize),
                    thumbShape:
                        CustomThumbShape(thumbSize: _thumbSize, text: ''),
                    // (_value * (showNumber/1.0)).toStringAsFixed(0)
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.8),
                    inactiveTrackColor: Colors.white.withOpacity(0.8),
                    secondaryActiveTrackColor: Colors.white.withOpacity(0.8),
                    valueIndicatorTextStyle: const TextStyle(
                        color: Color(0xff656566), // 设置标签的文字颜色
                        fontSize: 12, // 设置文字大小
                        fontWeight: FontWeight.w600),
                    valueIndicatorColor: Colors.white,
                  ),
                  child: Slider(
                    divisions: showNumber,
                    value: value,
                    max: 1.0,
                    min: 0.0,
                    onChanged: (value) {
                      onChanged.call(value);
                    },
                  ))),
          IconButton(
              onPressed: () {
                onChanged.call(1.0);
              },
              icon: Image.asset(
                'icon_cancel_edit'.imageEditorPng,
                width: 21,
              ))
        ],
      ),
    );
  }
}
