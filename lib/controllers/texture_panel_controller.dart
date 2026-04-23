import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

class TexturePanelController extends GetxController
    with GetTickerProviderStateMixin {
  List<BjTextureData> fonts = [];
  bool tabInited = false;

  int position = 0;
  bool showVipbar = false;

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

  void updateVipBg(bool value) {
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
    fetchData();
    super.onInit();
  }

  void fetchData() {
    BajiUtil.fetchTextures().then((value) {
      fonts = value ?? [];
      // if (fonts.isNotEmpty && fonts[0].list != null) {
      //   fonts[0].list!.insert(0, BjTextureDetail(id: -1));
      // }
      initTabController(fonts.length, position);
      update();
    });
  }
}
