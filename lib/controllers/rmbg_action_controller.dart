import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/base_util.dart';
import '../utils/ui_utils.dart';
import '../widgets/remove_bg/erase_canvas.dart';

class RmbgActionController extends GetxController {
  final GlobalKey rmKey = GlobalKey();

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
    final maxWidth = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;;
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

  Future<void> exportImage(
      BuildContext context, Function(String? np) saved) async {
    BaseUtil.showLoadingdialog(context);
    Uint8List? bytes = await clearKey.currentState?.exportAsPngBytes();
    if (bytes != null) {
      final imageSrc = await BaseUtil.uint8ListToImage(bytes);
      final path = await BaseUtil.image2File(imageSrc, ext: '.png');
      saved.call(path);
    }
    BaseUtil.hideLoadingdialog();
  }

  Future<void> exportImage2(
      BuildContext context, Function(String? np) saved) async {
    BaseUtil.showLoadingdialog(context);
    ui.Image image = await BaseUtil.captureImageWithKey(rmKey, Get.pixelRatio);

    String? path = await BaseUtil.image2File(image, ext: '.png');
    saved.call(path);
    BaseUtil.hideLoadingdialog();
  }
}
