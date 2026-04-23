import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../../constants/constant.dart';
import 'color_slider_picker.dart';

class ColorSolidPickerPanel extends StatefulWidget {
  final Function(Color) onColorChanged;

  const ColorSolidPickerPanel({Key? key, required this.onColorChanged})
      : super(key: key);

  @override
  State<ColorSolidPickerPanel> createState() => _ColorSolidPickerPanelState();
}

class _ColorSolidPickerPanelState extends State<ColorSolidPickerPanel> {
  late Color _currentPreColor;

  @override
  void initState() {
    super.initState();
    _currentPreColor = presetColors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              //todo
            },
            icon: Image.asset(
              'icon_cancel_shadow'.imageBjPng,
              width: 20,
            ),
          ),
          // 预设颜色
          SizedBox(
            height: 24,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: presetColors.map((color) {
                  final isSelected = _currentPreColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentPreColor = color;
                      });
                      widget.onColorChanged(color);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        color == Colors.transparent
                            ? Image.asset(
                                'icon_tm_color'.imageBjPng,
                                width: 24,
                                height: 24,
                                fit: BoxFit.fill,
                              ).marginSymmetric(horizontal: 6)
                            : Container(
                                width: 24,
                                height: 24,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                )),
                        if (isSelected)
                          Image.asset(
                            'icon_choose_color'.imageBjPng,
                            width: 12,
                            height: 12,
                          )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Container(
            height: 1,
            color: const Color(0xffF1F1F1),
            margin: const EdgeInsets.symmetric(vertical: 15),
          ),

          SliderColorPicker(
            onColorChanged: widget.onColorChanged,
          )
        ],
      ),
    );
  }
}
