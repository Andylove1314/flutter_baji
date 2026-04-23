import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baji/controllers/bj_home_controller.dart';
import 'package:flutter_baji/controllers/bj_pre_save_controller.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/badge_config.dart';
import 'package:flutter_baji/widgets/preview/preview_bg_action_panel.dart';
import 'package:flutter_baji/widgets/sticker_pre_view.dart';
import 'package:get/get.dart';

import '../utils/base_util.dart';
import '../utils/ui_utils.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/preview/preview_main_action_panel.dart';

class BjCardPreviewPage extends StatelessWidget {
  final controller = Get.put(BjPreSaveController());

  final dynamic image;
  final bool isCircle;
  final ConfigSize size;
  final String? bjName;
  ImageInfo? customBgImage;
  ImageInfo? fumoImage;
  BjFumoData? fumoData;
  List<BjFumoData> fumoDatas;
  Function()? changeGy;

  BjCardPreviewPage(
      {super.key,
      required this.image,
      required this.isCircle,
      required this.size,
      this.customBgImage,
      this.fumoImage,
      this.fumoData,
      this.fumoDatas = const [],
      this.changeGy,
      this.bjName}) {
    controller.fetchCardWh(isCircle, size.ratio, image, size.radius,
        customBgImage, size.bjWidthPixl != size.bjHeightPixl,
        fumoData: fumoData, fumoImage: fumoImage);
  }

  @override
  Widget build(BuildContext context) {
    UIUtils.setTransparentStatusBar();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() => _card()),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: //actions
                  _action(context),
            ),
            Positioned(
              bottom: controller.actionHeight,
              left: 0,
              child: //actions
                  _tipWidget(context),
            ),
            Positioned(
              bottom: controller.actionHeight + 23,
              right: 10,
              child: //actions
                  _highLightFlag(),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _title(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context) {
    return Obx(() => PreviewMainActionPanel(
        actionHeight: controller.actionHeight,
        currentBgImagePath: controller.currentBgImagePath.value,
        currentBgColor: controller.currentBgColor.value,
        onBgSelected: () {
          Get.bottomSheet(
            PreviewBgActionPanel(
              actionHeight: controller.actionHeight,
              onColorSelected: (setImage, preset, {color, path}) {
                controller.preset = preset;
                controller.currentBgColor.value = color ?? Colors.transparent;
                controller.currentBgImagePath.value = path ?? '';
              },
            ).marginOnly(
              bottom: controller.actionHeight / 2 + 25,
            ),
            barrierColor: Colors.transparent,
          );
        },
        onPrintGoods: () {
          if (!isCircle || (size.size != '58x58mm')) {
            BaseUtil.showToast('当前供应商只支持制作58mm的圆形吧唧');
            return;
          }

          BjHomeController homeController = Get.find();
          bool conflict = controller.conflictCheck(
              fumoData,
              fumoDatas,
              homeController.gongyiSrcs,
              homeController.pringImagePath, changeGy: () {
            Get.back();
            changeGy?.call();
          }, next: (fumo) {
            _tipPop(homeController, fumo);
          });
          if (conflict) {
            return;
          }
          _tipPop(homeController, fumoData);
        }));
  }

  void _tipPop(BjHomeController homeController, BjFumoData? fumo) {
    controller.surePrintTip(() {
      PrintBajiData printBajiData = PrintBajiData(
          printBajiPath: homeController.pringImagePath,
          name: '打印图',
          printGyPath: homeController.gongyiSrcs.isNotEmpty
              ? homeController.gongyiSrcs[0].gyPath
              : null,
          gyName: homeController.gongyiSrcs.isNotEmpty
              ? homeController.gongyiSrcs[0].craftsmanshipData?.name
              : null,
          craftsmanData: homeController.gongyiSrcs.isNotEmpty
              ? homeController.gongyiSrcs[0].craftsmanshipData
              : null,
          fumoData: fumo,
          tipPrintBaji: controller.content,
          tipPrintBack: controller.contentBack,
          bjName: bjName,
          configSize: size);
      BajiUtil.goPrintGoods(printBajiData, BajiUtil.makeBjType.name);
    });
  }

  Widget _title(BuildContext context) {
    return MyAppBar(
      title: const Text(
        '预览',
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      action: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text(
          '保存图片',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        onPressed: () {
          BaseUtil.logEvent('badge_05', params: {
            'badge_type': isCircle ? 'round' : 'square',
            'background_type': controller.preset ? 'preset' : 'upload',
          });

          controller.lindiController?.selectedWidget?.done();
          200.milliseconds.delay(() async {
            BaseUtil.showLoadingdialog(context);
            String? zhoubian = await controller.saveCardZhoubianImage(
                controller.config.cardWidthPixl,
                controller.config.cardHeightPixl,
                0);
            await BajiUtil.saveImage(zhoubian ?? '', false, false);
            BaseUtil.hideLoadingdialog();
            controller.showShare(
                context, size.bjWidthPixl != size.bjHeightPixl);
          });
        },
      ),
    );
  }

  Widget _card() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'toumingbg'.imageBjJpg,
          fit: BoxFit.cover,
          width: controller.cardWidth.value,
          height: controller.cardHeight.value,
        ),
        RepaintBoundary(
          key: controller.cardKey,
          child: Obx(() {
            return Container(
              alignment: Alignment.center,
              width: controller.cardWidth.value,
              height: controller.cardHeight.value,
              decoration: BoxDecoration(
                  color: controller.currentBgColor.value,
                  image: controller.currentBgImagePath.value.isEmpty
                      ? null
                      : DecorationImage(
                          image: Image.file(
                                  File(controller.currentBgImagePath.value))
                              .image,
                          fit: BoxFit.cover)),
              child: StickerPreView(
                  stickerController: controller.lindiController,
                  isLocked: false.obs,
                  onTapBg: () =>
                      controller.lindiController.selectedWidget?.done()),
            );
          }),
        )
      ],
    );
  }

  /// 提示条
  Widget _tipWidget(BuildContext context) {
    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller.tipAnimationController,
          curve: Curves.easeOutBack,
        )),
        child: Obx(() => Visibility(
            visible: controller.showTip.value,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.showFeedbackDialog(context);
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16, bottom: 23),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white, Color(0xffFF9C9C)]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                    child: const Text(
                      "我有话要说",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1925),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 110,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      controller.tipAnimationController.reverse();
                    },
                    child: Image.asset(
                      'icon_blackclose_pop_2'.imageBjPng,
                      width: 18,
                      height: 18,
                    ),
                  ),
                )
              ],
            ))));
  }

  /// 高亮开关
  Widget _highLightFlag() {
    return GestureDetector(
      onTap: () {
        controller.showHightLight.value = !controller.showHightLight.value;
      },
      child: Obx(() {
        if (controller.showHightLight.value) {
          return Image.asset(
            'gaoguang_on'.imageBjPng,
            width: 37,
            height: 37,
            fit: BoxFit.fill,
          );
        }
        return Image.asset(
          'gaoguang_off'.imageBjPng,
          width: 37,
          height: 37,
          fit: BoxFit.fill,
        );
      }),
    );
  }
}
