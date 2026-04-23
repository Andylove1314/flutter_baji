import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

const textStickerInitText = '点击输入文案';

class StickerAddedController extends GetxController {
  /// 公用
  final opacity = 1.0.obs;
  bool isVip = false;

  /// 文字专用
  final text = textStickerInitText.obs;
  final font = ''.obs;
  final color = '0xFFFFFFFF'.obs;
  final bold = false.obs;
  final italic = false.obs;
  final underline = false.obs;
  final textAlign = TextAlign.left.obs;
  final worldSpace = 0.0.obs;
  final lineSpace = 0.0.obs;
  final strokeColor = '0xFF000000'.obs;
  final curveRadius = 0.0.obs;
  final strokeWidth = 1.0.obs;

  /// 图片专用
  final hue = 0.0.obs; // 色相
  final saturation = 0.0.obs; // 饱和度
  final brightness = 0.0.obs; // 亮度
  final contrast = 0.0.obs; // 对比度
  final imgColor = Colors.transparent.obs; // 图片颜色
  final stickerGongyiType = 'none'.obs;
}
