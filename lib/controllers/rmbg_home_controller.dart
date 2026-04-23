import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/change_bg/change_bg_panel.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../models/rmbg_layer_data.dart';
import '../utils/rmbg_type.dart';
import '../utils/ui_utils.dart';
import '../widgets/change_bg/color_gradient_picker_panel.dart';
import '../widgets/layer_order_list_widget_rmbg.dart';
import '../widgets/lindi/lindi_controller_2.dart';
import '../widgets/lindi/lindi_sticker_icon_2.dart';
import 'dart:ui' as ui;

class RmbgHomeController extends GetxController {
  final panHeight = 100.0;
  final _titleHeight = kToolbarHeight + Get.statusBarHeight / Get.pixelRatio;

  final actionIndex = 0.obs;

  final cardWidth = 0.0.obs;
  final cardHeight = 0.0.obs;

  final bgType = Rx<BgColorType>(BgColorType.solid);
  final grantType = Rx<GradientType>(GradientType.linear);
  final colors = RxList<Color>([Colors.transparent, Colors.transparent]);
  final stops = [0.0, 1.0].obs;
  final gradientStart = Offset.zero.obs;
  final gradientEnd = Offset.zero.obs;
  final isGradientAction = false.obs;

  final currentBgImagePath = ''.obs;
  final currentBgImageUrl = ''.obs;

  bool saved = false;
  final basePath = ''.obs;

  final currentLayer = Rx<RmbgLayerData?>(null);

  ///当妾贴纸数组
  List<RmbgLayerData> _stickerLayers = [];

  final LindiController2 lindiController = LindiController2(
    borderColor: Colors.white,
    globalKey: GlobalKey(),
    insidePadding: 0,
    maxScale: 1000,
    minScale: 0.1,
  );

  final GlobalKey cardKey = GlobalKey();

  Future<void> save(BuildContext context) async {
    if (lindiController.widgets.isEmpty &&
        currentBgImagePath.value.isEmpty &&
        colors.value == [Colors.transparent, Colors.transparent]) {
      return;
    }

    lindiController.selectedWidget?.done();
    100.milliseconds.delay(() {
      _saveCardZhoubianImage(context).then((np) {
        if (np != null) {
          saved = true;
          RmbgUtil.saveImage(context, np);
        }
      });
    });
  }

  @override
  void onInit() {
    lindiController.onPositionChange((index) {
      currentLayer.value = lindiController.selectedFlagData;
    });
    lindiController.addListener(() {
      currentLayer.value = lindiController.selectedFlagData;
    });
    super.onInit();
  }

  Future<String?> _saveCardZhoubianImage(BuildContext context) async {
    BaseUtil.showLoadingdialog(context);
    ui.Image image =
        await BaseUtil.captureImageWithKey(cardKey, Get.pixelRatio);

    String? imagePath = await BaseUtil.image2File(image, ext: '.png');
    BaseUtil.hideLoadingdialog();

    return imagePath;
  }

  /// 获取car尺寸
  Future<void> fetchCardWh(RxString imagePath) async {
    final maxWidth = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    final maxHeight = Get.height - _titleHeight * 2 - panHeight;
    final size = await BaseUtil.getImageSize(File(imagePath.value));
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
    WidgetsBinding.instance.addPostFrameCallback((c) {
      _addSticker(imagePath, ratio, true, '柄图');
    });
  }

  void _addSticker(
      RxString imagePath, double ratio, bool isTarget, String name) {
    double bjWidth = cardWidth.value;
    double bjHeight = isTarget ? (bjWidth / ratio) : bjWidth;

    RmbgLayerData layer = RmbgLayerData(
        stickerPath: imagePath,
        locked: false.obs,
        isTarget: isTarget,
        ratio: ratio,
        name: name);

    Widget content = Obx(() => SizedBox(
          width: bjWidth,
          height: bjHeight,
          child: Image.file(
            File(imagePath.value),
            fit: BoxFit.contain,
          ),
        ));

    lindiController.add(
        Container(
          child: content,
        ),
        [
          LindiStickerIcon2(
              icon: Icons.close,
              alignment: Alignment.topLeft,
              onTap: () {
                _stickerLayers.removeAt(lindiController.widgets
                    .indexOf(lindiController.selectedWidget!));
                lindiController.selectedWidget?.delete();
              }),
          LindiStickerIcon2(
              icon: Icons.flip,
              alignment: Alignment.bottomLeft,
              onTap: () {
                lindiController.selectedWidget!.flip();
              }),
          LindiStickerIcon2(
              icon: Icons.cached,
              alignment: Alignment.bottomRight,
              type: IconType2.resize),
          LindiStickerIcon2(
              icon: Icons.copy,
              alignment: Alignment.topRight,
              onTap: () {
                _addSticker(imagePath, ratio, isTarget, '图层');
              }),
        ],
        initialRlPosition: _fetchInitRlPosition(
            Size(bjWidth, bjHeight), Size(cardWidth.value, cardHeight.value)),
        parentSize: Size(cardWidth.value, cardHeight.value),
        flagData: layer);
    _stickerLayers.add(layer);
  }

  /// add sticker init position
  Offset _fetchInitRlPosition(Size stickerSize, Size parentSize) {
    Offset offset = Offset(
      ((parentSize.width - stickerSize.width) / 2) / parentSize.width,
      ((parentSize.height - stickerSize.height) / 2) / parentSize.height,
    );
    debugPrint('offset = $offset');
    return offset;
  }

  @override
  onClose() {
    RmbgUtil.clearTmpObject();
    super.onClose();
  }

  /// 展示图层
  void showRmbgLayer() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    '图层排序',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 确认排序 todo
                      Get.back();
                    },
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayerOrderListRmbgWidget(
                stickerPreDatas: _stickerLayers,
                onDelete: (item) {
                  _stickerLayers.remove(item);
                  lindiController.deleteByFlagData(item);
                },
                onReorder: (items) {
                  _stickerLayers = items;
                  lindiController.reorderByFlagDataList(_stickerLayers);
                },
                onLock: (lock, index) {
                  _stickerLayers[index].locked.value = lock;
                  if (lock) {
                    lindiController.widgets[index].lock();
                  } else {
                    lindiController.widgets[index].unlock();
                  }
                },
                onTap: (index) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> toEditor(BuildContext context, RmbgType type) async {
    if (RmbgType.rmbg == type) {
      if (currentLayer.value == null) {
        BaseUtil.showToast('请选择要抠图的图层');
        return;
      }
      RmbgUtil.goRmActionPage(
          context, currentLayer.value?.stickerPath.value ?? '');
    } else if (RmbgType.idphoto == type) {
      _showTip(context, action: () {
        RmbgUtil.goIdphoto(context, basePath.value);
      });
    } else if (RmbgType.color == type) {
      if (currentLayer.value == null) {
        BaseUtil.showToast('请选择要抠图的图层');
        return;
      }
      BaseUtil.goColorsPage(
          context, currentLayer.value?.stickerPath.value ?? '', 1);
    } else if (RmbgType.bgColor == type) {
      actionIndex.value = 4;
    } else if (RmbgType.bgImage == type) {
      actionIndex.value = 5;
    } else if (RmbgType.addImage == type) {
      String? path = await BaseUtil.pickImage();

      if (path == null) {
        return;
      }

      String? np = await RmbgUtil.goSurepage(path);
      if (np != null) {
        _addSticker(RxString(np), 1.0, false, '图层');
      }
    }
  }

  void _showTip(BuildContext context, {required Function() action}) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '你要使用证件照功能吗？',
              style: const TextStyle(
                  color: Color(0xff19191A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 9, horizontal: 60)),
                        side: WidgetStateProperty.all(
                          const BorderSide(
                              color: Color(0xff979797), width: 1), // 设置边框颜色和宽度
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), // 设置圆角
                          ),
                        )),
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      '取消',
                      style: TextStyle(
                          color: Color(0xff19191A),
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    )),
                const SizedBox(
                  width: 20,
                ),
                FilledButton(
                    onPressed: () async {
                      Get.back();
                      action.call();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all( Color(0xffFF1A5A)),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 9, horizontal: 30)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), // 设置圆角
                          ),
                        )),
                    child: const Text(
                      '使用证件照',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
