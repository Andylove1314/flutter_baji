import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/change_bg/color_gradient_picker_panel.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../widgets/change_bg/change_bg_panel.dart';

mixin ImageChangeBackgroundController on GetxController {
  final bgType = BgColorType.solid.obs;

  ///颜色
  final type = GradientType.linear.obs;
  final colors = <Color>[Colors.transparent, Colors.transparent].obs;
  final stops = [0.0, 1.0].obs;
  final gradientStart = Offset.zero.obs;
  final gradientEnd = Offset.zero.obs;
  final isGradientAction = false.obs;

  BjTextureDetail? currentTextureData;


  bool isVipData() {
    return currentTextureData?.vip == 1;
  }
}
