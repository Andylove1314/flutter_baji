import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/sticker_widget_controller.dart';
import 'package:get/get.dart';

import '../../flutter_baji.dart';
import '../../utils/base_util.dart';
import '../net_image.dart';

class StickerWidget extends StatelessWidget {
  StickDetail stickerDetail;

  Function(StickDetail? item, String? stickerPath)? onSelect;

  StickerWidget({super.key, required this.stickerDetail, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StickerWidgetController(stickerDetail),
        tag: stickerDetail.image ?? '');

    return Container(
      color: (stickerDetail.color != null &&
              '${stickerDetail.color}'.isNotEmpty &&
              '${stickerDetail.color}' != 'null')
          ? Color(int.parse(stickerDetail.color)) // example: 0xffababab
          : Colors.transparent,
      child: GestureDetector(
        onTap: () {
          if (controller.isCached.value) {
            debugPrint('cached: ${controller.cachedPath.value}');
            onSelect?.call(stickerDetail, controller.cachedPath.value);
          } else {
            controller.cacheSticker(stickerDetail).then((path) {
              debugPrint('cached: $path');
              onSelect?.call(stickerDetail, path);
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
        ),
      ),
    );
  }

  Widget _fetchSrc() {
    if (stickerDetail.imgFrom == 0) {
      return Image.asset(
        stickerDetail.image ?? '',
        fit: BoxFit.contain,
      );
    } else if (stickerDetail.imgFrom == 1) {
      return Image.file(
        File(stickerDetail.image ?? ''),
        fit: BoxFit.contain,
      );
    }
    return NetImage(
      url: stickerDetail.image ?? '',
      fit: BoxFit.contain,
    );
  }
}
