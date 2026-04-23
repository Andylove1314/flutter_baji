import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/font_panel_controller.dart';
import 'package:get/get.dart';

import '../../../flutter_baji.dart';
import '../../../utils/base_util.dart';
import 'font_class_widget.dart';
import 'font_list.dart';

class FontFontPanel extends StatelessWidget {
  final controller = Get.put(FontPanelController());
  FontDetail? fontDetail;

  final Function({FontDetail? item, String? ttfPath, String? imgPath})
      onChanged;

  FontFontPanel({super.key, required this.onChanged, this.fontDetail});

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
        child: GetBuilder<FontPanelController>(
          init: controller,
          builder: (controller) {
            if (controller.fonts.isNotEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // VipBar(
                  //     showVipbg: controller.showVipbar,
                  //     subAction: () {
                  //       BajiUtil.goVipBuy();
                  //     }),
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
                            .map((item) => FontList(
                                fontDetail: fontDetail,
                                fons: item.list ?? [],
                                onChanged: (
                                    {FontDetail? item,
                                    String? ttfPath,
                                    String? imgPath}) {
                                  controller.updateVipFont(
                                      (item?.isVipFont ?? false) &&
                                          !BaseUtil.isMember());
                                  onChanged(
                                      item: item,
                                      ttfPath: ttfPath,
                                      imgPath: imgPath);
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
}
