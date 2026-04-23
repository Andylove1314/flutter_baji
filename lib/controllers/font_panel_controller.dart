import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';

class FontPanelController extends GetxController
    with GetTickerProviderStateMixin {
  List<FontsData> fonts = [];
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

  void updateVipFont(bool value) {
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
    BaseUtil.fetchFonts(0).then((value) {
      fonts = value ?? [];
      initTabController(fonts.length, position);
      update();
    });
    super.onInit();
  }
}
