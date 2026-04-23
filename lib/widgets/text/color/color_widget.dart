import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

import '../../../constants/constant.dart';
import '../../../constants/constant_bj.dart';

class ColorWidget extends StatefulWidget {
  String? colorHex;
  String initColorHex;

  ColorWidget(
      {super.key,
      required this.onSelect,
      this.colorHex,
      required this.initColorHex});

  final Function(String colorStr) onSelect;

  @override
  State<ColorWidget> createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<ColorWidget> {
  late String _color;
  @override
  void initState() {
    _color = widget.colorHex ?? widget.initColorHex;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ColorWidget oldWidget) {
    if (widget.colorHex == null) {
      setState(() {
        _color = colorStrs[1];
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: _item,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          width: 15,
        ),
        itemCount: colorStrs.length,
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    bool selected = _color == colorStrs[index];
    String colorStr = colorStrs[index];

    if (colorStr == '0x00000000') {
      return GestureDetector(
          onTap: () {
            setState(() {
              _color = colorStr;
            });
            widget.onSelect.call(colorStr);
          },
          child: Container(
            width: 24,
            height: 24,
            child: Image.asset(
              'icon_nocolor_white'.imageBjPng,
              fit: BoxFit.fill,
            ),
          ));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _color = colorStr;
        });
        widget.onSelect.call(colorStr);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                border: colorStr == '0xffffffff'
                    ? Border.all(color: const Color(0xffE1E2E6), width: 2)
                    : null,
                color: Color(int.parse(colorStr)),
                borderRadius: BorderRadius.circular(25)),
          ),
          if (selected)
            Container(
              width: 12,
              height: 12,
              child: Image.asset(
                'icon_choose_color_2'.imageBjPng,
                fit: BoxFit.fill,
              ),
            )
        ],
      ),
    );
  }
}
