import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/sticker/sticker_panel.dart';
import 'package:get/get.dart';

import '../controllers/editor_sticker_controller.dart';
import '../controllers/sticker_added_controller.dart';
import '../flutter_baji.dart';
import '../utils/ui_utils.dart';
import '../widgets/custom_widget.dart';
import '../widgets/slider_opacity_parameter.dart';
import '../widgets/sticker_pre_view.dart';

class EditorStickerPage extends StatelessWidget {
  final controller = Get.put(EditorStickerController());
  final String afterPath;
  final int? subActionIndex;

  EditorStickerPage({super.key, required this.afterPath, this.subActionIndex});
  final _stickerSize = ((UIUtils.isSquareScreen ? Get.width / 2 : Get.width) - 63) / 4;

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
                   _getImageWidgetSize();
                    return child;
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
          Obx(() => SliderOpacityParameterWidget(
                value: controller.currentOpacity.value,
                onChanged: (double value) {
                  controller.currentAddedController?.opacity.value = value;
                  controller.currentOpacity.value = value;
                },
              )),
          StickerPanel(
            type: 1,
            onClose: () {
              Get.back();
            },
            onConfirm: () {
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
            onChanged: ({StickDetail? item, String? path, bool? isBig}) {
              if (path != null) {
                _addSticker(item: item, path);
              }
            },
            onAddLocalSticker: () {
              BaseUtil.pickImage()?.then((newSticker) {
                if (newSticker != null) {
                  _addSticker(newSticker);
                }
              });
            },
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

  void _addSticker(String path, {StickDetail? item}) {
    final String uniqueTag = DateTime.now().microsecondsSinceEpoch.toString();
    final stickerAddController =
        Get.put(StickerAddedController(), tag: uniqueTag);
    stickerAddController.isVip = item?.isVipSticker ?? false;

    controller.stickerController.add(
        Container(
          width: _stickerSize,
          height: _stickerSize,
          child: Obx(() => Opacity(
              opacity: stickerAddController.opacity.value,
              child: Image.file(
                File(path),
              ))),
        ), controller.getIcons(onCopy: () {
      _addSticker(item: item, path);
    }),
        parentSize: Size(controller.contentW.value, controller.contentH.value),
        initialRlPosition:
            _fetchInitRlPosition(Size(_stickerSize, _stickerSize)),
        flagData: stickerAddController);
  }
}
