import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../utils/base_util.dart';

class StickerPanelController extends GetxController
    with GetTickerProviderStateMixin {
  List<StickerData> stickers = [];
  bool tabInited = false;
  bool showVipbar = false;

  int position = 0;

  TabController? tabController;

  void initTabController(int length, int initialIndex) {
    if (!tabInited) {
      tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: initialIndex,
      )..addListener(() {
          position = tabController!.index;
        });
      tabInited = true;
    }
  }

  void updateVipSticker(bool value) {
    showVipbar = value;
    update();
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
  }

  fetchData(int type) {
    BaseUtil.fetchStickers(type).then((value) {
      stickers = value ?? [];
      // if (stickers.isNotEmpty && stickers[0].list != null) {
      //   stickers[0].list!.insert(0, BjStickDetail(id: -1));
      // }
      initTabController(stickers.length, position);
      update();
    });
  }
}
