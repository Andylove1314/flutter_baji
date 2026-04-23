import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/lindi/lindi_controller_2.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../widgets/lindi/lindi_sticker_icon_2.dart';
import '../widgets/text/font/input_pop_widget.dart';
import 'sticker_added_controller.dart';

class EditorTextController extends GetxController {
  final LindiController2 stickerController = LindiController2(
    borderColor: Colors.white,
    globalKey: GlobalKey(),
    insidePadding: 13,
    maxScale: 10,
    minScale: 0.3,
    borderWidth: 1.5,
  );

  final contentW = 0.0.obs;
  final contentH = 0.0.obs;

  final GlobalKey imageKey = GlobalKey();

  StickerAddedController? currentAddedController;

  @override
  onInit() {
    stickerController.onPositionChange((index) {
      currentAddedController = stickerController.selectedFlagData;
      debugPrint(
          'currentAddedController = ${currentAddedController?.text.value}');
    });
    stickerController.addListener(() {
      currentAddedController = stickerController.selectedFlagData;
      debugPrint(
          'currentAddedController = ${currentAddedController?.text.value}');
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
            stickerController.selectedWidget!.delete();
          }),
      LindiStickerIcon2(
          icon: Icons.edit,
          iconSize: 14,
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
          iconSize: 14,
          alignment: Alignment.bottomRight,
          type: IconType2.resize),
      LindiStickerIcon2(
          icon: Icons.copy,
          iconSize: 14,
          alignment: Alignment.topRight,
          onTap: onCopy),
    ];
    ;

    return icons;
  }

  /// 更新文字
  void updateText(String? text) {
    bool isEmpty = text == null || text.isEmpty;
    currentAddedController?.text.value = isEmpty ? textStickerInitText : text;
  }

  /// 更新当前字体颜色
  updateColor(String? color) {
    currentAddedController?.color.value = color ?? '';
  }

  /// 更新当前字体描边颜色
  updateStrokeColor(String? color) {
    currentAddedController?.strokeColor.value = color ?? '';
  }

  /// 更新当前字体描边宽度
  updateStrokeWidth(double? width) {
    currentAddedController?.strokeWidth.value = width ?? 1.0;
  }

  /// 更新字体
  void updateFont(String? font, String? fontUrl) {
    currentAddedController?.font.value = font ?? '';
  }

  void updateOpacity(double? opacity) {
    currentAddedController?.opacity.value = opacity ?? 1.0;
  }

  void updateImgColor(Color? color) {
    currentAddedController?.imgColor.value = color ?? Colors.transparent;
  }

  /// 更新文字对齐方式
  void updateTextAlign(TextAlign? align) {
    currentAddedController?.textAlign.value = align ?? TextAlign.left;
  }

  /// 更新粗体
  void updateBold(bool? bold) {
    currentAddedController?.bold.value = bold ?? false;
  }

  /// 更新斜体
  void updateItalic(bool? italic) {
    currentAddedController?.italic.value = italic ?? false;
  }

  /// 更新下划线
  void updateUnderline(bool? underline) {
    currentAddedController?.underline.value = underline ?? false;
  }

  /// 更新字间距
  void updateWorldSpace(double? worldSpace) {
    currentAddedController?.worldSpace.value = worldSpace ?? 0.0;
  }

  /// 更新弯曲半径
  void updateCurveRadius(double? curveRadius) {
    currentAddedController?.curveRadius.value = curveRadius ?? 0.0;
  }

  /// 更新行间距
  void updateLineSpace(double? lineSpace) {
    currentAddedController?.lineSpace.value = lineSpace ?? 0.0;
  }

  ///获取当前文字
  String getCurrentText() {
    String? text = currentAddedController?.text.value;
    return (text == null || text.isEmpty) ? textStickerInitText : text;
  }

  /// 获取当前颜色
  String? getCurrentColor() {
    return currentAddedController?.color.value;
  }

  /// 获取当前描边颜色
  String? getCurrentStrokeColor() {
    return currentAddedController?.strokeColor.value;
  }

  /// 获取当前描边宽度
  double getCurrentStrokeWidth() {
    return currentAddedController?.strokeWidth.value ?? 1.0;
  }

  /// 获取当前字体
  String? getCurrentFont() {
    return currentAddedController?.font.value;
  }

  /// 获取当前透明度
  double getCurrentOpacity() {
    return currentAddedController?.opacity.value ?? 1.0;
  }

  /// 获取当前贴纸图片颜色
  Color getCurrentImageColor() {
    return currentAddedController?.imgColor.value ?? Colors.transparent;
  }

  /// 获取当前贴纸图片工艺类型
  String getCurrentStickerType() {
    return currentAddedController?.stickerGongyiType.value ?? 'none';
  }

  /// 获取当前对齐方式
  TextAlign? getCurrentTextAlign() {
    return currentAddedController?.textAlign.value;
  }

  /// 获取当前是否粗体
  bool? getCurrentBold() {
    return currentAddedController?.bold.value;
  }

  /// 获取当前是否斜体
  bool? getCurrentItalic() {
    return currentAddedController?.italic.value;
  }

  /// 获取当前是否有下划线
  bool? getCurrentUnderline() {
    return currentAddedController?.underline.value;
  }

  /// 获取当前字间距
  double? getCurrentWorldSpace() {
    return currentAddedController?.worldSpace.value;
  }

  /// 获取当前行间距
  double? getCurrentLineSpace() {
    return currentAddedController?.lineSpace.value;
  }

  /// 获取当前弯曲半径
  double? getCurrentCurveRadius() {
    return currentAddedController?.curveRadius.value;
  }

  void clearSomeStickers() {
    for (var key in stickerController.dynamicFlagDatas.keys) {
      var value = stickerController.dynamicFlagDatas[key];
      bool shoulRemove = value.text.value == textStickerInitText;
      if (shoulRemove) {
        stickerController.widgets.removeWhere((element) {
          return element.key! == key;
        });
      }
    }
    stickerController.dynamicFlagDatas
        .removeWhere((key, value) => value.text.value == textStickerInitText);
  }
}
