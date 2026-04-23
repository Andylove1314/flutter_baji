import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';

import '../flutter_baji.dart';
import 'package:image/image.dart' as img;

import 'package:get/get.dart';

class EditorCropController extends GetxController {
  final showSli = false.obs;
  final showfw = false.obs;

  img.Image? cutImage;

  final cutImageByte = Rx<Uint8List?>(null);

  final ImageEditorController imageCroperController = ImageEditorController();

  final currentAddDegree = 0.0.obs;
  final currentCropIndex = 1.obs;

  @override
  void onInit() {
    imageCroperController.addListener(() {
      bool changed = imageCroperController.rotateDegrees != 0 ||
          imageCroperController.cropAspectRatio != null ||
          (imageCroperController.editActionDetails?.flipY ?? false);
      showStatus(showSli.value, changed);
    });
    super.onInit();
  }

  @override
  onClose() {
    imageCroperController.dispose();
    super.onClose();
  }

  void showStatus(bool showRs, bool showFw) {
    showSli.value = showRs;
    showfw.value = showFw;
  }

  Future<void> fetchCutImage(String afterPath) async {
    List datas = await EditorUtil.fileToUint8ListAndImage(afterPath);
    cutImage = datas[0];
    cutImageByte.value = datas[1];
  }
}
