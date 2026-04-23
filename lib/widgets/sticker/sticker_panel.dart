import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/sticker_panel_controller.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/sticker/sticker_class_widget_2.dart';
import 'package:get/get.dart';

import '../../flutter_baji.dart';
import '../confirm_bar.dart';
import 'stickers_list.dart';

class StickerPanel extends StatelessWidget {
  final controller = Get.put(StickerPanelController());

  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final Function({StickDetail? item, String? path, bool? isBig}) onChanged;
  final Function() onAddLocalSticker;

  final int type;

  StickerPanel(
      {super.key,
      this.onClose,
      this.onConfirm,
      required this.onChanged,
      required this.onAddLocalSticker,
      required this.type}) {
    controller.fetchData(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GetBuilder<StickerPanelController>(
            init: controller,
            builder: (controller) {
              if (controller.stickers.isNotEmpty) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: onAddLocalSticker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'icon_daorusticker'.imageBjPng,
                                width: 14,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              const Text(
                                '导入',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xff19191A)),
                              )
                            ],
                          ),
                        ).paddingOnly(left: 13, top: 15, bottom: 2),
                        Expanded(
                            child: StickerClassWidget2(
                                position: controller.position,
                                tabController: controller.tabController!,
                                tags: controller.stickers))
                      ],
                    ),
                    Container(
                      color: Colors.white,
                      height: 160,
                      child: TabBarView(
                        controller: controller.tabController,
                        children: controller.stickers
                            .map((item) => StickersList(
                                // isMine: controller.stickers.indexOf(item) == 0,
                                upload: () {
                                  _handleUpload(context);
                                },
                                delete: (id) {
                                  BaseUtil.showLoadingdialog(context);
                                  BajiUtil.deleteMineMaterial(id)
                                      .then((success) {
                                    if (success) {
                                      item.list!.removeWhere((element) =>
                                          element.id.toString() == id);
                                      controller.update();
                                      BaseUtil.showToast('删除成功');
                                    }
                                    BaseUtil.hideLoadingdialog();
                                  });
                                },
                                usingDetail: null,
                                sts: item.list ?? [],
                                onChanged: (
                                    {StickDetail? stcikerItem,
                                    String? stcikerPath}) {
                                  controller.updateVipSticker(
                                      (stcikerItem?.isVipSticker ?? false) &&
                                          !BaseUtil.isMember());
                                  onChanged(
                                      item: stcikerItem,
                                      path: stcikerPath,
                                      isBig: item.isBigGroup);
                                }))
                            .toList(),
                      ),
                    ),
                  ],
                );
              }

              return Container(
                  alignment: Alignment.center,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: BaseUtil.loadingWidget());
            },
          ),
          ConfirmBar(
            cancel: onClose,
            confirm: onConfirm,
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '贴纸',
                  style: TextStyle(
                    color: Color(0xff969799),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleUpload(BuildContext context) async {
    bool logined = await BaseUtil.isLogin() ?? false;
    if (!logined) {
      debugPrint('请先登录！');
      return;
    }
    BaseUtil.pickImage()?.then((String? path) {
      if (path != null) {
        BaseUtil.showLoadingdialog(context);
        BajiUtil.uploadMineMaterial(path, 'bajibgstickers').then((success) {
          BaseUtil.showToast('上传成功');
          controller.fetchData(type);
          BaseUtil.hideLoadingdialog();
        });
      }
    });
  }
}
