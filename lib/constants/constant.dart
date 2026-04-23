import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

import '../models/action_data.dart';

final fontActions = [
  ActionData(type: 0, name: '字体', icon: ''),
  ActionData(type: 1, name: '样式', icon: '', subActions: fontStyleActions),
  ActionData(type: 2, name: '对齐', icon: '', subActions: fontAlignActions),
];

final fontStyleActions = [
  ActionData(
      type: 0,
      name: '粗体',
      icon: 'icon_coarse_n@3x'.imageFontsPng,
      selectedIcon: 'icon_coarse_s@3x'.imageFontsPng),
  ActionData(
      type: 1,
      name: '斜体',
      icon: 'icon_inclined_n@3x'.imageFontsPng,
      selectedIcon: 'icon_inclined_s@3x'.imageFontsPng),
  ActionData(
      type: 2,
      name: '下划线',
      icon: 'icon_underline_n@3x'.imageFontsPng,
      selectedIcon: 'icon_underline_s@3x'.imageFontsPng),
];

final fontAlignActions = [
  ActionData(
      type: 0,
      name: '居左',
      icon: 'icon_leftalignment_n@3x'.imageFontsPng,
      selectedIcon: 'icon_leftalignment_s@3x'.imageFontsPng),
  ActionData(
      type: 1,
      name: '居中',
      icon: 'icon_midst_n@3x'.imageFontsPng,
      selectedIcon: 'icon_midst_s@3x'.imageFontsPng),
  ActionData(
      type: 2,
      name: '居右',
      icon: 'icon_rightalignment_n@3x'.imageFontsPng,
      selectedIcon: 'icon_rightalignment_s@3x'.imageFontsPng),
];

/// 帖字字体颜色
final List<String> colorStrs = [
  '0x00000000',
  '0xffffffff',
  '0xff000000',
  '0xff646466',
  '0xffC8C9CC',
  '0xffFFB2B2',
  '0xffFF8080',
  '0xffFF4D4D',
  '0xffFF0000',
  '0xffCB1514',
  '0xffFFE680',
  '0xffFFDB4D',
  '0xffFFCA00',
  '0xffCCA714',
  '0xffB6FFB2',
  '0xff9AE883',
  '0xffACE249',
  '0xff20D82A',
  '0xff14CC95',
  '0xffB2BBFF',
  '0xff838EE8',
  '0xff495BE2',
  '0xff0B26F0',
  '0xff142ACC',
  '0xffE7B2FF',
  '0xffD083E8',
  '0xffB149E2',
  '0xffCA00FF',
  '0xffC514CC',
  '0xffFFB2DB',
  '0xffF389C1',
  '0xffE2499B',
  '0xffFF0089',
  '0xffCC1476',
  '0xff800D0D',
  '0xff897629',
  '0xff2E8929',
  '0xff293489',
  '0xff792989',
  '0xff89295C',
  '0xff330505',
  '0xff332E05',
  '0xff083305',
  '0xff050B33',
  '0xff2C0533',
  '0xff33051E'
];

/// 修改背景颜色
const List<Color> presetColors = [
  Colors.transparent,
  Colors.black,
  Colors.white,
  const Color(0xffFF4D4D),
  const Color(0xffFF8A36),
  const Color(0xffFFE100),
  const Color(0xff00B30D),
  const Color(0xff239EFF),
  const Color(0xffB266FF),
  const Color(0xffFF53B1),
  const Color(0xffFFCFD9),
  const Color(0xffFFC297),
  const Color(0xffFFF4A4),
  const Color(0xffB6FFC1),
  const Color(0xffBBEDFF),
  const Color(0xffE3C8FF),
  const Color(0xffFFD8FD),
];

/// 修改背景颜色
const List<Color> presetColors2 = [
  Colors.black,
  Colors.white,
  const Color(0xffFF4D4D),
  const Color(0xffFF8A36),
  const Color(0xffFFE100),
  const Color(0xff00B30D),
  const Color(0xff239EFF),
  const Color(0xffB266FF),
  const Color(0xffFF53B1),
  const Color(0xffFFCFD9),
  const Color(0xffFFC297),
  const Color(0xffFFF4A4),
  const Color(0xffB6FFC1),
  const Color(0xffBBEDFF),
  const Color(0xffE3C8FF),
  const Color(0xffFFD8FD),
];

/// 颜色渐变
const List<Color> sliderColors = [
  Color(0xffFF0000),
  Color(0xffFFFA04),
  Color(0xff00FF1D),
  Color(0xff0CFFF1),
  Color(0xff3200FF),
  Color(0xffF902FE),
  Color(0xffFF0000),
];
