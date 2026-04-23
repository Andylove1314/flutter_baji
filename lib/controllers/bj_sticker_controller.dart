import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/sticker_added_controller.dart';
import 'package:flutter_baji/widgets/text/text_sticker_widget.dart';
import 'package:get/get.dart';

import '../models/layer_data.dart';
import '../models/sticker_color_item.dart';
import '../utils/base_util.dart';
import '../utils/ui_utils.dart';
import '../widgets/lindi/lindi_controller_2.dart';
import '../widgets/lindi/lindi_sticker_icon_2.dart';
import '../widgets/remove_bg/erase_canvas.dart';
import '../widgets/sticker_edit_list_widget.dart';
import '../widgets/sticker_pre_view.dart';
import '../widgets/text/font/input_pop_widget.dart';

mixin BjStickerController on GetxController {
  final stickerIconSize = 14.0;
  final borderWidth = 1.5;
  final textStickerFontSize = 20.0;

  final isClearing = false.obs;

  ///用于更新图层，所以存起来
  List<Widget> stickerPres = [];
  List<Widget> stickerMagnifiers = [];

  /// 用于操作层属性
  final stickerPreDatas = RxList<LayerData>().obs;

  /// 当前贴纸
  final stickerIndex = (-1).obs;
  LayerData? get currentLayerData =>
      stickerIndex.value < 0 ? null : stickerPreDatas.value[stickerIndex.value];

  final currentStickerOffset = Offset.zero.obs;
  final currentStickerRadian = 0.0.obs;
  final currentStickerScale = 1.0.obs;
  final currentStickerFlip = false.obs;

  /// 放大镜，主要是坐标对应问题
  Widget _magnifierWidget(
    bool isFont,
    RxString magnifierImagePath,
    RxDouble magnifierImageOpacity,
    Rx<Color> magnifierImageColor,
    double erasePanelWidth,
    double erasePanelHeight,
    Rx<Offset> clearPoint,
    GlobalKey<EraseCanvasState> key2,
  ) {
    const magnifierSize = 90.0;
    const magnifieScale = 1.5;

    if (isFont) {
      return const SizedBox();
    }

    return Obx(() => Opacity(
          opacity: clearPoint.value != Offset.zero ? 1.0 : 0.0,
          child: SizedBox(
            width: magnifierSize,
            height: magnifierSize,
            child: ClipRRect(
              child: Transform.scale(
                scale: magnifieScale,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Positioned(
                      left: -clearPoint.value.dx + (magnifierSize / 2) - 2.5,
                      // 修改定位计算
                      top: -clearPoint.value.dy + (magnifierSize / 2) - 2.5,
                      child: SizedBox(
                        width: erasePanelWidth,
                        height: erasePanelHeight,
                        child: IgnorePointer(
                          ignoring: true,
                          child: _clearWidget(
                            key2,
                            currentLayerData?.clearEnable.value ?? false,
                            magnifierImagePath.value,
                            magnifierImageOpacity.value,
                            magnifierImageColor.value,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  /// 清除widget
  Widget _clearWidget(Key key, bool enable, String imagePath,
      double imageOpacity, Color imgColor,
      {Function(Offset? offset)? onEraseStart, VoidCallback? onEraseEnd}) {
    return EraseCanvas(
        key: key,
        enable: enable,
        imagePath: imagePath,
        imageOpacity: imageOpacity,
        imgColor: imgColor,
        onEraseStart: onEraseStart,
        onEraseEnd: onEraseEnd,
        clearMode: true);
  }

  /// 添加字体文字或者图片sticker
  void addSticker(
    bool isFont,
    StickerAddedController stickerController, {
    required String name,
    required Size stickerSize,
    required GlobalKey<EraseCanvasState> magnifierKey1,
    required GlobalKey<EraseCanvasState> magnifierKey2,
    required Size magnifierSize,
    required Rx<Offset> eraseClearOffset,
    bool vipData = false,
    bool isTarget = false,
    bool isBig = false,
    String? ttfPath,
    String? fontUrl,
    String? stickerPath,
    String? stickerUrl,
    String? initImageUrl,
    VoidCallback? onCopy,
    List<StickerColorItem>? gongyi,
    double stickerScale = 1.0,
    Offset? stickerOffset,
    double stickerRadian = 0.0,
    bool isFlip = false,
    bool local = false,
  }) {
    /// predata
    LindiController2 lindiController = LindiController2(
      borderColor: Colors.white,
      globalKey: GlobalKey(),
      insidePadding: isFont ? 13 : 0,
      maxScale: 10,
      minScale: 0.3,
      borderWidth: borderWidth,
    );

    LayerData preData = LayerData(
        isFont, RxString(name), GlobalKey(), GlobalKey(), lindiController,
        isVipData: vipData,
        fontPath: RxString(ttfPath ?? ''),
        fontUrl: fontUrl,
        stickerPath: stickerPath,
        stickerUrl: stickerUrl,
        initImageUrl: initImageUrl,
        stickerRmbgPath: RxString(stickerPath ?? ''),
        isTarget: isTarget,
        clearKey1: magnifierKey1,
        clearKey2: magnifierKey2,
        eraseClearOffset: eraseClearOffset,
        gongyi: gongyi,
        isBig: isBig,
        stickerWidgetController: stickerController,
        stickerSize: stickerSize,
        isLocked: false,
        clearEnable: false.obs,
        stickerOffset: stickerOffset,
        stickerRadian: stickerRadian,
        stickerScale: stickerScale,
        localImgLayer: local);

    /// preview
    Widget stickerPre = RepaintBoundary(
      key: preData.captureKey,
      child: StickerPreView(
        stickerController: lindiController,
        isLocked: preData.isLocked.obs,
      ),
    );

    _addSticker(preData, stickerSize, onCopy: onCopy, isFlip: isFlip);

    /// magnifier
    Widget magnifier = _magnifierWidget(
        isFont,
        preData.stickerRmbgPath ?? RxString(''),
        preData.stickerWidgetController?.opacity ?? RxDouble(1.0),
        preData.stickerWidgetController?.imgColor ??
            Rx<Color>(Colors.transparent),
        magnifierSize.width,
        magnifierSize.height,
        eraseClearOffset,
        magnifierKey2);

    /// sticker删除 监听
    lindiController.onPositionChange((index) {
      if (lindiController.deleted) {
        stickerPres.remove(stickerPre);
        stickerMagnifiers.remove(magnifier);
        stickerPreDatas.value = stickerPreDatas.value..remove(preData);
        stickerIndex.value = -1;
      }
    });

    /// sticker位置索引 监听
    lindiController.addListener(() {
      // 当前 sticker 被选中时，隐藏其他 sticker 的边框
      for (var predata in stickerPreDatas.value) {
        if (predata.lindiController != lindiController) {
          predata.lindiController.selectedWidget?.done();
        }
      }
      stickerIndex.value = stickerPreDatas.value.indexOf(preData);
      debugPrint('当前贴纸索引: ${stickerIndex.value}');

      /// 更新当前贴纸位置信息
      currentStickerOffset.value =
          currentLayerData!.stickerOffset ?? Offset.zero;
      currentStickerRadian.value = currentLayerData!.stickerRadian;
      currentStickerScale.value = currentLayerData!.stickerScale;
      currentStickerFlip.value = lindiController.selectedWidget!.isFlip();
    });

    stickerPres.add(stickerPre);
    stickerMagnifiers.add(magnifier);
    stickerPreDatas.value = stickerPreDatas.value..add(preData);

    stickerIndex.value = stickerPreDatas.value.length - 1;

    /// 选中当前贴纸
    for (var predata in stickerPreDatas.value) {
      if (predata.lindiController != lindiController) {
        predata.lindiController.selectedWidget?.done();
      }
    }

    /// 更新当前贴纸位置信息
    currentStickerOffset.value = preData.stickerOffset ?? Offset.zero;
    currentStickerRadian.value = preData.stickerRadian;
    currentStickerScale.value = preData.stickerScale;
    currentStickerFlip.value = isFlip;
  }

  /// 锁定贴纸
  void lockStickerPres() {
    // 设置当前贴纸的边框可见，其他贴纸的边框不可见
    for (var i = 0; i < stickerPres.length; i++) {
      var stickerPre = stickerPres[i] as RepaintBoundary;
      var stickerPreView = stickerPre.child as StickerPreView;
      var layerData = stickerPreDatas.value[i];

      stickerPreView.isLocked.value = (layerData != currentLayerData);
    }
  }

  /// 解锁贴纸
  void unlockStickerPres() {
    // 解锁所有贴纸
    for (var i = 0; i < stickerPres.length; i++) {
      var stickerPre = stickerPres[i] as RepaintBoundary;
      var stickerPreView = stickerPre.child as StickerPreView;
      var layerData = stickerPreDatas.value[i];

      // 恢复所有贴纸的可见性和可编辑状态
      stickerPreView.isLocked.value = layerData.isLocked;
      layerData.lindiController.selectedWidget?.done();
    }
  }

  /// add sticker
  void _addSticker(
    LayerData preData,
    Size stickerSize, {
    VoidCallback? onCopy,
    bool isFlip = false,
  }) {
    debugPrint('贴纸内容size = $stickerSize');
    Widget newChild = Container(
        // 移除固定宽度和高度约束
        constraints: preData.isFont
            ? null // 文字贴纸不设置约束，让它自适应内容大小
            : BoxConstraints(
                maxWidth: stickerSize.width, maxHeight: stickerSize.height),
        child: preData.isFont
            ? TextStickerWidget(
                fontSize: textStickerFontSize,
                controller: preData.stickerWidgetController) // 移除size参数
            : Obx(() => _clearWidget(
                    preData.clearKey1!,
                    preData.clearEnable.value,
                    preData.stickerRmbgPath?.value ?? '',
                    preData.stickerWidgetController.opacity.value,
                    preData.stickerWidgetController.imgColor.value,
                    onEraseStart: (Offset? position) {
                  debugPrint('开始擦除 : ${position?.dx}, ${position?.dy}');
                  isClearing.value = true;
                  currentLayerData?.eraseClearOffset?.value = position!;
                  currentLayerData?.clearKey2?.currentState
                      ?.autoErase(position!);
                }, onEraseEnd: () {
                  debugPrint('结束擦除');
                  isClearing.value = false;
                  currentLayerData?.eraseClearOffset?.value = Offset.zero;
                  currentLayerData?.clearKey2?.currentState?.stopErase();
                })));

    preData.stickerOffset ??=
        _fetchInitRlPosition(stickerSize, isTarget: preData.isTarget);
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    preData.lindiController.add(
      newChild,
      _getIcons(preData.isFont, preData.lindiController, onCopy: onCopy),
      initialRlPosition: preData.stickerOffset!,
      initRadian: preData.stickerRadian,
      initScale: preData.stickerScale,
      parentSize: Size(w, Get.height),
      onChange: (scale, radian, offset) {
        preData.stickerScale = scale;
        preData.stickerRadian = radian;
        preData.stickerOffset = offset;

        10.milliseconds.delay(() {
          currentStickerOffset.value = offset;
          currentStickerRadian.value = radian;
          currentStickerScale.value = scale;
          currentStickerFlip.value =
              preData.lindiController.selectedWidget!.isFlip();
        });
      },
    );
    if (isFlip) {
      10.milliseconds.delay(() {
        preData.lindiController.selectedWidget?.flip();
      });
    }
  }

  /// 贴纸操作按钮
  List<LindiStickerIcon2> _getIcons(
      bool isFont, LindiController2 stickerController,
      {VoidCallback? onCopy}) {
    List<LindiStickerIcon2> icons = [];
    if (isFont) {
      icons = [
        LindiStickerIcon2(
            icon: Icons.close,
            iconSize: stickerIconSize,
            alignment: Alignment.topLeft,
            onTap: () {
              stickerController.selectedWidget!.delete();
            }),
        LindiStickerIcon2(
            icon: Icons.edit,
            iconSize: stickerIconSize,
            alignment: Alignment.bottomLeft,
            onTap: () {
              Get.dialog(InputPopWidget(
                font: getCurrentText(),
                input: (s) {
                  updateText(s);
                },
                content: getCurrentText(),
              ));
            }),
        LindiStickerIcon2(
            icon: Icons.cached,
            iconSize: stickerIconSize,
            alignment: Alignment.bottomRight,
            type: IconType2.resize),
        LindiStickerIcon2(
            icon: Icons.copy,
            iconSize: stickerIconSize,
            alignment: Alignment.topRight,
            onTap: onCopy),
      ];
    } else {
      icons = [
        LindiStickerIcon2(
            icon: Icons.close,
            iconSize: stickerIconSize,
            alignment: Alignment.topLeft,
            onTap: () {
              stickerController.selectedWidget?.delete();
            }),
        LindiStickerIcon2(
            icon: Icons.flip,
            iconSize: stickerIconSize,
            alignment: Alignment.bottomLeft,
            onTap: () {
              stickerController.selectedWidget!.flip();
              currentStickerFlip.value = !currentStickerFlip.value;
            }),
        LindiStickerIcon2(
            icon: Icons.cached,
            iconSize: stickerIconSize,
            alignment: Alignment.bottomRight,
            type: IconType2.resize),
        LindiStickerIcon2(
            icon: Icons.copy,
            iconSize: stickerIconSize,
            alignment: Alignment.topRight,
            onTap: onCopy),
      ];
    }
    return icons;
  }

  /// 更新图片贴纸
  void updateImageSticker(String newPath, String? stickerUrl,
      {Function()? onRefreshed}) {
    currentLayerData?.stickerRmbgPath?.value = newPath;
    currentLayerData?.stickerUrl = stickerUrl;

    200.milliseconds.delay(() {
      unlockStickerPres();
      // doneAllSticker();
      onRefreshed?.call();
    });
  }

  /// 更新vip贴纸
  void updateVip(bool isVip) {
    currentLayerData?.isVipData = isVip;
  }

  /// 更新文字
  void updateText(String? text) {
    bool isEmpty = text == null || text.isEmpty;
    currentLayerData?.stickerWidgetController?.text.value =
        isEmpty ? textStickerInitText : text;
    currentLayerData?.name.value = isEmpty ? textStickerInitText : text;
  }

  /// 更新当前字体颜色
  updateColor(String? color) {
    currentLayerData?.stickerWidgetController?.color.value = color ?? '';
  }

  /// 更新当前字体描边颜色
  updateStrokeColor(String? color) {
    currentLayerData?.stickerWidgetController?.strokeColor.value = color ?? '';
  }

  /// 更新当前字体描边宽度
  updateStrokeWidth(double? width) {
    currentLayerData?.stickerWidgetController?.strokeWidth.value = width ?? 1.0;
  }

  /// 更新字体
  void updateFont(String? font, String? fontUrl) {
    currentLayerData?.stickerWidgetController?.font.value = font ?? '';
    currentLayerData?.fontPath?.value = font ?? '';
    currentLayerData?.fontUrl = fontUrl;
  }

  void updateOpacity(double? opacity) {
    currentLayerData?.stickerWidgetController?.opacity.value = opacity ?? 1.0;
  }

  void updateImgColor(Color? color) {
    currentLayerData?.stickerWidgetController?.imgColor.value =
        color ?? Colors.transparent;
  }

  void updateStickerType(String? type) {
    currentLayerData?.stickerWidgetController?.stickerGongyiType.value =
        type ?? 'none';
  }

  /// 更新文字对齐方式
  void updateTextAlign(TextAlign? align) {
    currentLayerData?.stickerWidgetController?.textAlign.value =
        align ?? TextAlign.left;
  }

  /// 更新粗体
  void updateBold(bool? bold) {
    currentLayerData?.stickerWidgetController?.bold.value = bold ?? false;
  }

  /// 更新斜体
  void updateItalic(bool? italic) {
    currentLayerData?.stickerWidgetController?.italic.value = italic ?? false;
  }

  /// 更新下划线
  void updateUnderline(bool? underline) {
    currentLayerData?.stickerWidgetController?.underline.value =
        underline ?? false;
  }

  /// 更新字间距
  void updateWorldSpace(double? worldSpace) {
    currentLayerData?.stickerWidgetController?.worldSpace.value =
        worldSpace ?? 0.0;
  }

  /// 更新弯曲半径
  void updateCurveRadius(double? curveRadius) {
    currentLayerData?.stickerWidgetController?.curveRadius.value =
        curveRadius ?? 0.0;
  }

  /// 更新行间距
  void updateLineSpace(double? lineSpace) {
    currentLayerData?.stickerWidgetController?.lineSpace.value =
        lineSpace ?? 0.0;
  }

  /// 获取当前颜色
  String? getCurrentColor() {
    return currentLayerData?.stickerWidgetController?.color.value;
  }

  /// 获取当前描边颜色
  String? getCurrentStrokeColor() {
    return currentLayerData?.stickerWidgetController?.strokeColor.value;
  }

  /// 获取当前描边宽度
  double getCurrentStrokeWidth() {
    return currentLayerData?.stickerWidgetController?.strokeWidth.value ?? 1.0;
  }

  /// 获取当前字体
  String? getCurrentFont() {
    return currentLayerData?.stickerWidgetController?.font.value;
  }

  /// 获取当前透明度
  double getCurrentOpacity() {
    return currentLayerData?.stickerWidgetController?.opacity.value ?? 1.0;
  }

  /// 获取当前贴纸图片颜色
  Color getCurrentImageColor() {
    return currentLayerData?.stickerWidgetController?.imgColor.value ??
        Colors.transparent;
  }

  /// 获取当前贴纸图片工艺类型
  String getCurrentStickerType() {
    return currentLayerData?.stickerWidgetController?.stickerGongyiType.value ??
        'none';
  }

  /// 获取当前对齐方式
  TextAlign? getCurrentTextAlign() {
    return currentLayerData?.stickerWidgetController?.textAlign.value;
  }

  /// 获取当前是否粗体
  bool? getCurrentBold() {
    return currentLayerData?.stickerWidgetController?.bold.value;
  }

  /// 获取当前是否斜体
  bool? getCurrentItalic() {
    return currentLayerData?.stickerWidgetController?.italic.value;
  }

  /// 获取当前是否有下划线
  bool? getCurrentUnderline() {
    return currentLayerData?.stickerWidgetController?.underline.value;
  }

  /// 获取当前字间距
  double? getCurrentWorldSpace() {
    return currentLayerData?.stickerWidgetController?.worldSpace.value;
  }

  /// 获取当前行间距
  double? getCurrentLineSpace() {
    return currentLayerData?.stickerWidgetController?.lineSpace.value;
  }

  /// 获取当前弯曲半径
  double? getCurrentCurveRadius() {
    return currentLayerData?.stickerWidgetController?.curveRadius.value;
  }

  ///获取当前文字
  String getCurrentText() {
    String? text = currentLayerData?.stickerWidgetController?.text.value;
    return (text == null || text.isEmpty) ? textStickerInitText : text;
  }

  /// 获取当前是否为字体sticker
  bool isCurrentFont() {
    return currentLayerData?.isFont ?? false;
  }

  bool hasVipData() {
    return stickerPreDatas.value.any((element) => element.isVipData);
  }

  /// 获取当前选中的是否为VIP素材
  bool isCurrentVip() {
    return currentLayerData?.isVipData ?? false;
  }

  void doneAllSticker() {
    for (var predata in stickerPreDatas.value) {
      predata.lindiController.selectedWidget?.done();
    }
    stickerIndex.value = -1;
  }

  void clearSomeStickers() {
    // 创建待删除列表，避免在遍历时直接修改
    List<LayerData> toRemove = [];
    List<Widget> toRemoveWidgets = [];
    List<Widget> toRemoveMagnifiersWidgets = [];

    for (var i = 0; i < stickerPreDatas.value.length; i++) {
      var predata = stickerPreDatas.value[i];
      String text = predata.stickerWidgetController?.text.value ?? '';
      debugPrint('current sticker text = $text');
      if ((predata.isFont && (text == textStickerInitText || text.isEmpty)) ||
          (!BaseUtil.isMember() && predata.isVipData)) {
        toRemoveWidgets.add(stickerPres[i]);
        toRemoveMagnifiersWidgets.add(stickerMagnifiers[i]);
        toRemove.add(predata);
      }
    }

    // 批量删除
    for (var predata in toRemove) {
      if (currentLayerData == predata) {
        stickerIndex.value = -1;
      }
    }
    stickerPres.removeWhere((w) => toRemoveWidgets.contains(w));
    stickerMagnifiers.removeWhere((w) => toRemoveMagnifiersWidgets.contains(w));
    stickerPreDatas.value = stickerPreDatas.value
      ..removeWhere((c) => toRemove.contains(c));
  }

  /// 贴纸修改
  void _stcikerChangePop() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Container(
        height: Get.height * 0.4,
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
                    '图层编辑',
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
              child: StickerEditListWidget(
                stickerAddedController:
                    currentLayerData?.stickerWidgetController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// add sticker init position
  Offset _fetchInitRlPosition(Size stickerSize, {bool isTarget = false}) {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    Offset offset = Offset(
        ((w -
                    stickerSize.width -
                    (isTarget ? stickerIconSize / 1.65 : stickerIconSize * 2)) /
                2) /
            w,
        ((Get.height -
                    stickerSize.height -
                    (isTarget ? stickerIconSize / 1.65 : stickerIconSize * 2)) /
                2) /
            Get.height);
    debugPrint('offset = $offset');
    return offset;
  }

  /// 水平或者垂直居中贴纸字
  void hvCenter(bool isVertical) {
    if (currentLayerData == null) {
      BaseUtil.showToast('请选择图层');
      return;
    }

    if (currentLayerData?.isLocked == true) {
      BaseUtil.showToast('请先解锁图层');
      return;
    }

    currentLayerData?.lindiController.selectedWidget?.hvCenter(isVertical,
        parentSize: Size(UIUtils.isSquareScreen ? Get.width / 2 : Get.width, Get.height),
        stickerSize: currentLayerData?.isTarget == true ||
                currentLayerData?.isFont == true
            ? Size(
                currentLayerData!.stickerSize.width -
                    stickerIconSize * 2 -
                    borderWidth / 3,
                currentLayerData!.stickerSize.height -
                    stickerIconSize * 2 -
                    borderWidth / 3)
            : Size(currentLayerData!.stickerSize.width - borderWidth / 3,
                currentLayerData!.stickerSize.height - borderWidth / 3));
  }
}
