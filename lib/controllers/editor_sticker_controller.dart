import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/lindi/lindi_controller_2.dart';
import 'package:get/get.dart';

import '../widgets/lindi/lindi_sticker_icon_2.dart';
import 'sticker_added_controller.dart';

class EditorStickerController extends GetxController {
  final LindiController2 stickerController = LindiController2(
    borderColor: Colors.white,
    globalKey: GlobalKey(),
    insidePadding: 0,
    maxScale: 10,
    minScale: 0.3,
    borderWidth: 1.5,
  );

  final contentW = 0.0.obs;
  final contentH = 0.0.obs;

  final GlobalKey imageKey = GlobalKey();

  StickerAddedController? currentAddedController;

  final currentOpacity = 1.0.obs;

  @override
  onInit() {
    stickerController.onPositionChange((index) {
      currentAddedController = stickerController.selectedFlagData;
      debugPrint(
          'currentAddedController = ${currentAddedController?.text.value}');
      currentOpacity.value = currentAddedController?.opacity.value ?? 1.0;
      debugPrint('currentOpacity = ${currentOpacity.value}');
    });
    stickerController.addListener(() {
      currentAddedController = stickerController.selectedFlagData;
      debugPrint(
          'currentAddedController = ${currentAddedController?.text.value}');
      currentOpacity.value = currentAddedController?.opacity.value ?? 1.0;
      debugPrint('currentOpacity = ${currentOpacity.value}');
    });
    super.onInit();
  }

  /// 贴纸操作按钮
  List<LindiStickerIcon2> getIcons({VoidCallback? onCopy}) {
    List<LindiStickerIcon2> icons = [
      LindiStickerIcon2(
          icon: Icons.close,
          iconSize: 14,
          alignment: Alignment.topLeft,
          onTap: () {
            stickerController.selectedWidget?.delete();
          }),
      LindiStickerIcon2(
          icon: Icons.flip,
          iconSize: 14,
          alignment: Alignment.bottomLeft,
          onTap: () {
            stickerController.selectedWidget!.flip();
          }),
      LindiStickerIcon2(
          icon: Icons.cached,
          iconSize: 14,
          alignment: Alignment.bottomRight,
          type: IconType2.resize),
      LindiStickerIcon2(
          icon: Icons.copy,
          iconSize: 14,
          alignment: Alignment.topRight,
          onTap: onCopy),
    ];

    return icons;
  }
}
