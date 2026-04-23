import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/frame_source_controller.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';
import '../../flutter_baji.dart';
import '../net_image.dart';

class FrameWidget extends StatelessWidget {
  FrameDetail frameDetail;

  Function(FrameDetail? item, String? framePath)? onSelect;

  FrameWidget({super.key, required this.frameDetail, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FrameSourceController(),
        tag: '${frameDetail.classId}_${frameDetail.id}');
    controller.checkCache(frameDetail);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        _fetchSrc(),
        Obx(() {
          Widget icon = Image.asset(
            width: 12,
            'icon_cloud'.imageEditorPng,
            fit: BoxFit.fitWidth,
          );

          if (controller.frameStatus.value == 0) {
            icon = SizedBox(
              width: 12,
              height: 12,
              child: BaseUtil.loadingWidget(isLight: false, size: 12),
            );
          } else if (controller.frameStatus.value == 1) {
            icon = const SizedBox();
          }

          return GestureDetector(
            onTap: () {
              debugPrint('000000');
              if (controller.frameStatus.value == 1) {
                debugPrint('cached: ${controller.framePath.value}');
                onSelect?.call(frameDetail, controller.framePath.value);
              } else {
                controller.cacheFrame(frameDetail).then((path) {
                  debugPrint('cached: $path');
                  onSelect?.call(frameDetail, path);
                });
              }
            },
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(bottom: 3, right: 3),
              child: icon,
            ),
          );
        }),
      ],
    );
  }

  Widget _fetchSrc() {
    if (frameDetail.imgFrom == 0) {
      return Image.asset(
        frameDetail.image ?? '',
        fit: BoxFit.contain,
      );
    } else if (frameDetail.imgFrom == 1) {
      return Image.file(
        File(frameDetail.image ?? ''),
        fit: BoxFit.contain,
      );
    }
    return NetImage(
      url: frameDetail.image ?? '',
      fit: BoxFit.contain,
    );
  }
}
