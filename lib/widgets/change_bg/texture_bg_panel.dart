import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../flutter_baji.dart';
import '../../controllers/texture_panel_controller.dart';
import '../../utils/base_util.dart';
import '../text/font/font_class_widget.dart';
import '../vip_bar.dart';
import 'texture_list.dart';

class TextureBgPanel extends StatelessWidget {
  final controller = Get.put(TexturePanelController());
  BjTextureDetail? fontDetail;

  final Function({BjTextureDetail? item, String? imgPath}) onTextureChanged;

  TextureBgPanel({super.key, required this.onTextureChanged, this.fontDetail});

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
        height: 230,
        child: GetBuilder<TexturePanelController>(
          init: controller,
          builder: (controller) {
            if (controller.fonts.isNotEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: FontClassWidget(
                      position: controller.position,
                      tabController: controller.tabController!,
                      tags: controller.fonts
                          .map((item) => item.groupName ?? '')
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: TabBarView(
                        controller: controller.tabController,
                        children: controller.fonts
                            .map((item) => TextureList(
                                // isMine: controller.fonts.indexOf(item) == 0,
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
                                fontDetail: fontDetail,
                                fons: item.list ?? [],
                                onChanged: (
                                    {BjTextureDetail? item,
                                    String? texturePath}) {
                                  controller.updateVipBg(
                                      (item?.isVipFont ?? false) &&
                                          !BaseUtil.isMember());
                                  onTextureChanged(
                                      item: item, imgPath: texturePath);
                                }))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Container(
                alignment: Alignment.center,
                height: 230,
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
        ));
  }

  Future<void> _handleUpload(BuildContext context) async {
    bool logined = await BaseUtil.isLogin() ?? false;
    if (!logined) {
      debugPrint('请先登录！');
      return;
    }

    BaseUtil.pickImage()?.then((String? path) async {
      if (path != null) {
        BaseUtil.showLoadingdialog(context);
        BajiUtil.uploadMineMaterial(path, 'bajibjimgin').then((success) {
          BaseUtil.showToast('上传成功');
          controller.fetchData();
          BaseUtil.hideLoadingdialog();
        });
      }
    });
  }
}
