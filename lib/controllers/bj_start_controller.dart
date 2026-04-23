import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../models/layer_data.dart';
import '../utils/ui_utils.dart';
import '../widgets/lindi/lindi_controller_2.dart';
import '../widgets/remove_bg/erase_canvas.dart';
import '../widgets/sticker_pre_view.dart';
import 'sticker_added_controller.dart';

class BjStartController extends GetxController {
  final badgeIndex = 0.obs;
  final sizeIndex = 0.obs;

  ImageInfo? customBgImage;
  final refreshBjBg = false.obs;

  ///用于更新图层，所以存起来
  List<Widget> stickerPres = [];

  /// 用于操作层属性
  final stickerPreDatas = RxList<LayerData>().obs;

  @override
  void onInit() {
    loadBgTexture("staff_1024".imageBjPng);
    super.onInit();
  }

  void loadBgTexture(String asset) {
    final image = Image.asset(asset).image;
    image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      customBgImage = info;
      refreshBjBg.value = !refreshBjBg.value;
    }));
  }

  @override
  void onClose() {
    BajiUtil.closeCallbacks();
    super.onClose();
  }

  /// 添加图片sticker
  void addSticker({required String name, String? stickerPath}) {
    /// predata
    LindiController2 lindiController = LindiController2(
      borderColor: Colors.transparent,
      globalKey: GlobalKey(),
      insidePadding: 0,
      maxScale: 5,
      minScale: 0.3,
    );

    final String uniqueTag = DateTime.now().microsecondsSinceEpoch.toString();
    StickerAddedController stickerController =
        Get.put(StickerAddedController(), tag: uniqueTag);

    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    LayerData preData = LayerData(
      false,
      RxString(name),
      GlobalKey(),
      GlobalKey(),
      lindiController,
      stickerPath: stickerPath,
      stickerRmbgPath: RxString(stickerPath ?? ''),
      stickerWidgetController: stickerController,
      stickerSize: Size(w, Get.height),
      isLocked: false,
      clearEnable: false.obs,
    );

    /// preview
    Widget stickerPre = RepaintBoundary(
      key: preData.captureKey,
      child: StickerPreView(
        stickerController: lindiController,
        isLocked: preData.isLocked.obs,
      ),
    );

    _addSticker(preData);
    stickerPres.add(stickerPre);
    stickerPreDatas.value = stickerPreDatas.value..add(preData);
  }

  /// add sticker
  void _addSticker(LayerData preData) {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    Widget newChild = Container(
        width: w,
        height: Get.height,
        child: EraseCanvas(
          key: GlobalKey(),
          enable: false,
          imagePath: preData.stickerPath ?? '',
          clearMode: true,
          imageOpacity: 1.0,
        ));

    preData.lindiController
        .add(newChild, [], parentSize: Size(w, Get.height));
  }
}
