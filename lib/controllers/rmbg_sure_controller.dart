import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/base_util.dart';
import '../utils/ui_utils.dart';
import '../widgets/remove_bg/erase_canvas.dart';

class RmbgSureController extends GetxController {
  final GlobalKey<EraseCanvasState> clearKey = GlobalKey<EraseCanvasState>();
  final GlobalKey<EraseCanvasState> clearKey2 = GlobalKey<EraseCanvasState>();
  final afterPath = ''.obs;
  final eraseClearOffset = Offset.zero.obs;
  final cardWidth = 0.0.obs;
  final cardHeight = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// 获取car尺寸
  Future<void> fetchCardWh(String imagePath) async {
    final maxWidth = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    final maxHeight = Get.height;
    final size = await BaseUtil.getImageSize(File(imagePath));
    final ratio = size.width / size.height;
    double w, h;
    if (ratio > 1) {
      // 宽度大于高度的情况
      w = maxWidth;
      h = w / ratio;
      if (h > maxHeight) {
        // 如果高度超出限制，则按高度计算
        h = maxHeight;
        w = h * ratio;
      }
    } else {
      // 高度大于宽度的情况
      h = maxHeight;
      w = h * ratio;
      if (w > maxWidth) {
        // 如果宽度超出限制，则按宽度计算
        w = maxWidth;
        h = w / ratio;
      }
    }
    cardWidth.value = w;
    cardHeight.value = h;
  }
}
