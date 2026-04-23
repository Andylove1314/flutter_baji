import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/font_widget_controller.dart';
import '../../../flutter_baji.dart';
import '../../../utils/base_util.dart';
import '../../net_image.dart';

class FontWidget extends StatelessWidget {
  FontDetail fontDetail;
  Function(FontDetail? item, String? ttfPath, String? imgPath)? onSelect;

  FontWidget({super.key, required this.fontDetail, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(FontWidgetController(fontDetail), tag: fontDetail.file ?? '');
    return GestureDetector(
        onTap: () {
          debugPrint('000000');
          if (controller.isCached.value) {
            debugPrint('cached: ${controller.cachedPath.value}');
            onSelect?.call(
                fontDetail, controller.cachedPath.value, fontDetail.image);
          } else {
            controller.cacheFont(fontDetail).then((path) {
              debugPrint('cached: $path');
              onSelect?.call(fontDetail, path, fontDetail.image);
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _fetchSrc(),
            Obx(() {
              Widget icon = Image.asset(
                width: 12,
                'icon_cloud'.imageBjPng,
                fit: BoxFit.fitWidth,
              );

              if (controller.isLoading.value) {
                icon = SizedBox(
                  width: 12,
                  height: 12,
                  child: BaseUtil.loadingWidget(isLight: false, size: 12),
                );
              } else if (controller.isCached.value) {
                icon = const SizedBox();
              }

              return Container(
                color: Colors.transparent,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(bottom: 3, right: 3),
                child: icon,
              );
            })
          ],
        ));
  }

  Widget _fetchSrc() {
    if (fontDetail.imgFrom == 0) {
      return Image.asset(
        fontDetail.image ?? '',
        fit: BoxFit.fill,
      );
    } else if (fontDetail.imgFrom == 1) {
      return Image.file(
        File(fontDetail.image ?? ''),
        fit: BoxFit.fill,
      );
    }
    return NetImage(
      url: fontDetail.image ?? '',
      fit: BoxFit.fill,
    );
  }
}
