import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/rmbg_action_controller.dart';
import '../flutter_baji.dart';
import '../utils/base_util.dart';
import '../widgets/remove_bg/erase_canvas.dart';
import '../widgets/remove_bg/remove_bg_panel.dart';

class RmbgActionPage extends StatelessWidget {
  final controller = Get.put(RmbgActionController());

  final String orignal;

  final String title;

  RmbgActionPage({
    super.key,
    required this.orignal,
    required this.title,
  }) {
    controller.afterPath.value = orignal;
    controller.fetchCardWh(orignal);
  }

  final _magnifierSize = 90.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            height: double.infinity,
            width: double.infinity,
            'pic_bg_qbj'.imageRmbgJpg,
            fit: BoxFit.fill,
          ),
          _content(context),
          Positioned(top: 0, left: 0, right: 0, child: _bar(context)),
          Positioned(bottom: 0, left: 0, right: 0, child: _action(context)),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          shadowColor: const Color(0xff19191A).withOpacity(0.1),
          elevation: 2,
          // actions: [
          //   Obx(() => saveAction(
          //       action: orignal != controller.afterPath.value
          //           ? () async {
          //               // 保存图片
          //               final path = await controller.getSaveImagePath();
          //               RmbgUtil.saveImage(context, path);
          //             }
          //           : null))
          // ],
        ),
        _clearTip(),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return RepaintBoundary(
      key: controller.rmKey,
      child: Obx(() => SizedBox(
            width: controller.cardWidth.value,
            height: controller.cardHeight.value,
            child: EraseCanvas(
                key: controller.clearKey,
                enable: true,
                imagePath: controller.afterPath.value,
                imageOpacity: 1.0,
                clearMode: true,
                onEraseStart: (Offset? position) {
                  debugPrint('开始擦除 : ${position?.dx}, ${position?.dy}');
                  controller.eraseClearOffset.value = position!;
                  controller.clearKey2.currentState?.autoErase(position);
                },
                onEraseEnd: () {
                  debugPrint('结束擦除');
                  controller.eraseClearOffset.value = Offset.zero;
                  controller.clearKey2.currentState?.stopErase();
                }),
          )),
    );
  }

  Widget _action(BuildContext context) {
    return RemoveBgPanel(
      onClose: () {
        Get.back();
      },
      onConfirm: () {
        controller.exportImage2(context, (np) {
          if (np != null) {
            RmbgUtil.refreshHomeLayerEffect(np);
            Get.back();
          }
        });
      },
      removeAd: () {
        BaseUtil.goVipBuy();
      },
      adTask: () {
        _removeBg(context);
      },
      undo: () {
        controller.clearKey.currentState?.undo();
        controller.clearKey2.currentState?.undo();
      },
      reset: () {
        controller.clearKey.currentState?.reset();
        controller.clearKey2.currentState?.undo();
      },
      paintWidthCallback: (width) {
        controller.clearKey.currentState?.updatePainterWidth(width);
        controller.clearKey2.currentState?.undo();
      },
      blureCallback: (intensity) {},
      onModeChange: (mode) {
        // 处理模式切换
        switch (mode) {
          case RemoveBgMode.ai:
            _removeBg(context);
            break;
          case RemoveBgMode.erase:
            break;
          case RemoveBgMode.recoveryErase:
            controller.clearKey.currentState?.reset();
            controller.clearKey2.currentState?.reset();
            controller.afterPath.value = orignal;
        }
      },
    );
  }

  /// 去背景
  void _removeBg(BuildContext context) {
    BaseUtil.showLoadingdialog(context, msg: '去背景中...');
    RmbgUtil.aiRemoveBg(orignal).then((newUrl) {
      if (newUrl != null) {
        debugPrint('去背景 $newUrl');
        BaseUtil.cacheImage(newUrl).then((newPath) {
          debugPrint('去背景后path $newPath');
          if (newPath != null) {
            controller.afterPath.value = newPath;
          }
          BaseUtil.hideLoadingdialog();
        });
      }
    });
  }

  Widget _clearTip() {
    return Obx(() => Opacity(
          opacity: controller.eraseClearOffset.value != Offset.zero ? 1.0 : 0.0,
          child: SizedBox(
            width: _magnifierSize,
            height: _magnifierSize,
            child: ClipRRect(
              child: Transform.scale(
                scale: 1.5,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Positioned(
                      left: -controller.eraseClearOffset.value.dx +
                          (_magnifierSize / 2) -
                          2.5,
                      // 修改定位计算
                      top: -controller.eraseClearOffset.value.dy +
                          (_magnifierSize / 2) -
                          2.5,
                      child: SizedBox(
                        width: controller.cardWidth.value,
                        height: controller.cardHeight.value,
                        child: IgnorePointer(
                          ignoring: true,
                          child: EraseCanvas(
                              key: controller.clearKey2,
                              enable: false,
                              imagePath: controller.afterPath.value,
                              imageOpacity: 1.0,
                              clearMode: true),
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
}
