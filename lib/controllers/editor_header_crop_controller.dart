import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baji/utils/base_util.dart';

import '../flutter_baji.dart';
import 'package:image/image.dart' as img;

import 'package:get/get.dart';
import 'dart:ui' as ui;

class EditorHeaderCropController extends GetxController {
  img.Image? cutImage;

  final cutImageByte = Rx<Uint8List?>(null);
  ui.Image? maskImage;

  final ImageEditorController imageCroperController = ImageEditorController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  onClose() {
    imageCroperController.dispose();
    super.onClose();
  }

  Future<void> fetchCutImage(String afterPath, {String? maskImageAsset}) async {
    if (maskImageAsset != null) {
      maskImage = await BaseUtil.loadAssetImage(maskImageAsset);
    }
    List datas = await EditorUtil.fileToUint8ListAndImage(afterPath);
    cutImage = datas[0];
    cutImageByte.value = datas[1];
  }
}
