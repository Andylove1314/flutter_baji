import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';
import '../controllers/editor_text_controller.dart';
import '../controllers/sticker_added_controller.dart';
import '../flutter_baji.dart';
import '../utils/ui_utils.dart';
import '../widgets/custom_widget.dart';
import '../widgets/sticker_pre_view.dart';
import '../widgets/text/text_panel.dart';
import '../widgets/text/text_sticker_widget.dart';

class EditorTextPage extends StatelessWidget {
  final controller = Get.put(EditorTextController());
  final String afterPath;
  final int? subActionIndex;

  EditorTextPage({super.key, required this.afterPath, this.subActionIndex});

  final _stickerSize = (UIUtils.isSquareScreen ? Get.width / 2 : Get.width - 63) / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                key: controller.imageKey,
                fit: BoxFit.contain,
                File(afterPath),
                frameBuilder: (context, child, loadingProgress, loaded) {
                  if (loaded) {
                    _getImageWidgetSize();
                    return child;
                  }
                  return BaseUtil.loadingWidget(isLight: true);
                },
              ),
              Obx(() => SizedBox(
                    width: controller.contentW.value,
                    height: controller.contentH.value,
                    child: StickerPreView(
                      stickerController: controller.stickerController,
                      isLocked: false.obs,
                      onTapBg: () {
                        controller.stickerController.selectedWidget?.done();
                        controller.currentAddedController = null;
                      },
                    ),
                  )),
            ],
          )),
          TextPanel(
            type: 1,
            onClose: () {
              Get.back();
            },
            onConfirm: () {
              controller.clearSomeStickers();

              if (controller.stickerController.widgets.isEmpty) {
                return;
              }

              ///最后检查
              bool isContainVipSticker = controller
                  .stickerController.dynamicFlagDatas.values
                  .any((item) => item?.isVip ?? false);
              if (isContainVipSticker && !(BaseUtil.isMember())) {
                showVipPop(context, content: '您使用了VIP素材，请在开通会员后保存效果？',
                    onBuy: () {
                  BaseUtil.goVipBuy();
                }, onCancel: () {});
                return;
              }
              BaseUtil.showLoadingdialog(context);
              EditorUtil.addSticker(afterPath, controller.stickerController)
                  .then((after) {
                if (EditorUtil.editorType == null) {
                  /// 更新 home after
                  EditorUtil.refreshHomeEffect(after);
                } else {
                  if (EditorUtil.singleEditorSavetoAlbum) {
                    EditorUtil.homeSaved(context, after);
                  }
                  EditorUtil.clearTmpObject(after);
                }

                BaseUtil.hideLoadingdialog();
                Navigator.pop(context);
              });
            },
            initialIndex: 0,
            fontDetail: null,
            color: controller.getCurrentColor(),
            opacity: controller.getCurrentOpacity(),
            bold: controller.getCurrentBold(),
            italic: controller.getCurrentItalic(),
            underline: controller.getCurrentUnderline(),
            textAlign: controller.getCurrentTextAlign(),
            worldSpace: controller.getCurrentWorldSpace(),
            lineSpace: controller.getCurrentLineSpace(),
            curveRadius: controller.getCurrentCurveRadius(),
            strokeColor: controller.getCurrentStrokeColor(),
            strokeWidth: controller.getCurrentStrokeWidth(),
            onFontChanged: (
                {FontDetail? item, String? ttfPath, String? imgPath}) {
              if (ttfPath != null) {
                if (controller.currentAddedController != null) {
                  controller.updateFont(ttfPath, item?.file);
                } else {
                  _addSticker(item: item, ttfPath);
                }
              }
            },
            onColorChanged: (color) {
              controller.updateColor(color);
            },
            onStrokeColorChanged: (color) {
              controller.updateStrokeColor(color);
            },
            onOpacityChanged: (opacity) {
              controller.updateOpacity(opacity);
            },
            onAlignChanged: (align) {
              controller.updateTextAlign(align);
            },
            onBold: (bold) {
              controller.updateBold(bold);
            },
            onItalic: (italic) {
              controller.updateItalic(italic);
            },
            onUnderline: (underline) {
              controller.updateUnderline(underline);
            },
            onWorldSpaceChanged: (worldSpace) {
              controller.updateWorldSpace(worldSpace);
            },
            onLineSpaceChanged: (lineSpace) {
              controller.updateLineSpace(lineSpace);
            },
            onCurveRadiusChanged: (curveRadius) {
              controller.updateCurveRadius(curveRadius);
            },
            onStrokeWidthChanged: (double? strokeWidth) {
              controller.updateStrokeWidth(strokeWidth);
            },
            onEffectSave: () {},
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  void _getImageWidgetSize() {
    if (controller.contentW.value != 0.0 && controller.contentH.value != 0.0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((v) {
      var renderBox = controller.imageKey.currentContext?.findRenderObject();
      if (renderBox == null) {
        return;
      }
      var size = (renderBox as RenderBox).size; // 获取 widget 的宽高
      controller.contentW.value = size.width;
      controller.contentH.value = size.height;
    });
  }

  /// add sticker init position
  Offset _fetchInitRlPosition(Size stickerSize) {
    Offset offset = Offset(
        ((controller.contentW.value - stickerSize.width - 28) / 2) /
            controller.contentW.value,
        ((controller.contentH.value - stickerSize.height - 28) / 2) /
            controller.contentH.value);
    debugPrint('offset = $offset');
    return offset;
  }

  void _addSticker(String ttfPath, {FontDetail? item}) {
    final String uniqueTag = DateTime.now().microsecondsSinceEpoch.toString();
    final stickerAddController =
        Get.put(StickerAddedController(), tag: uniqueTag);
    stickerAddController.font.value = ttfPath;
    stickerAddController.isVip = item?.isVipFont ?? false;

    controller.stickerController.add(
        Container(
          child: TextStickerWidget(
              fontSize: 20.0, controller: stickerAddController),
        ), controller.getIcons(onCopy: () {
      _addSticker(item: item, ttfPath);

      //拷贝属性
      controller.updateText(stickerAddController.text.value);
      controller.updateColor(stickerAddController.color.value);
      controller.updateOpacity(stickerAddController.opacity.value);
      controller.updateTextAlign(stickerAddController.textAlign.value);
      controller.updateBold(stickerAddController.bold.value);
      controller.updateUnderline(stickerAddController.underline.value);
      controller.updateItalic(stickerAddController.italic.value);
      controller.updateWorldSpace(stickerAddController.worldSpace.value);
      controller.updateLineSpace(stickerAddController.lineSpace.value);
      controller.updateFont(ttfPath, item?.file);
      controller.updateStrokeColor(stickerAddController.strokeColor.value);
      controller.updateCurveRadius(stickerAddController.curveRadius.value);
      controller.updateStrokeWidth(stickerAddController.strokeWidth.value);
    }),
        parentSize: Size(controller.contentW.value, controller.contentH.value),
        initialRlPosition:
            _fetchInitRlPosition(Size(_stickerSize, _stickerSize)),
        flagData: stickerAddController);
  }
}
