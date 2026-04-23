import 'package:flutter/material.dart';
import 'package:flutter_baji/models/craftsmanship_data.dart';
import 'package:get/get.dart';
import '../controllers/sticker_added_controller.dart';
import '../widgets/lindi/lindi_controller_2.dart';
import '../widgets/remove_bg/erase_canvas.dart';
import 'sticker_color_item.dart';

class LayerData {
  bool isFont = false;
  bool isTarget;
  GlobalKey preKey;
  GlobalKey captureKey;
  bool isVipData;
  RxString name;
  RxString? fontPath;
  String? fontUrl;
  String? stickerPath;
  String? stickerUrl;
  CraftsmanshipData? craftsmanshipData;
  bool shouldShow;
  LindiController2 lindiController;
  bool blackLayer;
  StickerAddedController stickerWidgetController;
  GlobalKey<EraseCanvasState>? clearKey1;
  GlobalKey<EraseCanvasState>? clearKey2;
  RxString? stickerRmbgPath;
  Rx<Offset>? eraseClearOffset;
  List<StickerColorItem>? gongyi; // 添加工艺列表参数
  bool rmBg;
  bool isBig;
  bool localImgLayer;

  /// stciker 位置大小相关
  double stickerScale;
  Offset? stickerOffset;
  double stickerRadian;

  bool isLocked;

  RxBool clearEnable;

  Size stickerSize;

  String? initImageUrl;

  LayerData(this.isFont, this.name, this.preKey, this.captureKey,
      this.lindiController,
      {required this.stickerWidgetController,
      required this.stickerSize,
      required this.isLocked,
      required this.clearEnable,
      this.isTarget = false,
      this.isVipData = false,
      this.shouldShow = true,
      this.blackLayer = false,
      this.fontPath,
      this.fontUrl,
      this.stickerPath,
      this.stickerUrl,
      this.craftsmanshipData,
      this.clearKey1,
      this.clearKey2,
      this.stickerRmbgPath,
      this.eraseClearOffset,
      this.gongyi,
      this.rmBg = false,
      this.isBig = false,
      this.stickerScale = 1.0,
      this.stickerOffset,
      this.stickerRadian = 0.0,
      this.initImageUrl,
      this.localImgLayer = false}) {
    // 在构造函数中添加参数
    craftsmanshipData ??= CraftsmanshipData.craftsmanshipDatas[0];
  }
}
