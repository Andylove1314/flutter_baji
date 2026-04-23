import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/change_bg/color_gradient_picker_panel.dart';
import 'package:flutter_baji/widgets/main_panel_rmbg.dart';
import 'package:get/get.dart';

import '../controllers/rmbg_home_controller.dart';
import '../flutter_baji.dart';
import '../utils/rmbg_type.dart';
import '../utils/ui_utils.dart';
import '../widgets/change_bg/change_bg_panel.dart';
import '../widgets/change_bg/gradient_control_widget.dart';
import '../widgets/custom_widget.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/rmbg_changebg/rmbg_change_bg_panel.dart';
import '../widgets/sticker_pre_view.dart';

class RmbgHomePage extends StatelessWidget {
  final controller = Get.put(RmbgHomeController());

  final String orignal;

  final String title;

  RmbgHomePage({
    super.key,
    required this.orignal,
    required this.title,
  }) {
    controller.basePath.value = orignal;
    controller.fetchCardWh(controller.basePath);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _close(context);
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _content(context),
            Positioned(top: 0, left: 0, right: 0, child: _bar(context)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _action(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    return MyAppBar(
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      onBack: () {
        _close(context);
      },
      action: Obx(() => saveAction(
          action: (orignal != controller.basePath.value ||
                  controller.colors.value !=
                      [Colors.transparent, Colors.transparent])
              ? () async {
                  // 保存图片
                  controller.save(context);
                }
              : null)),
    );
  }

  Widget _content(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          height: double.infinity,
          width: double.infinity,
          'pic_bg_qbj'.imageRmbgJpg,
          fit: BoxFit.fill,
        ),
        Obx(() => _card()),
      ],
    );
  }

  Widget _card() {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
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
            final angle =
                (controller.gradientStart.value == controller.gradientEnd.value)
                    ? math.pi / 2
                    : math.atan2(
                        controller.gradientEnd.value.dy -
                            controller.gradientStart.value.dy,
                        controller.gradientEnd.value.dx -
                            controller.gradientStart.value.dx);

            return Container(
              alignment: Alignment.center,
              width: controller.cardWidth.value,
              height: controller.cardHeight.value,
              child: StickerPreView(
                  stickerController: controller.lindiController,
                  isLocked: false.obs,
                  bgContent: Container(
                    decoration: BoxDecoration(
                        gradient: controller.currentBgImagePath.value.isEmpty
                            ? controller.grantType.value == GradientType.linear
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    transform:
                                        GradientRotation(angle - math.pi / 2),
                                    colors: controller.colors.value,
                                    stops: controller.stops.value,
                                  )
                                : RadialGradient(
                                    center: Alignment.center,
                                    radius: 0.5,
                                    transform:
                                        GradientRotation(angle - math.pi / 2),
                                    colors: controller.colors.value,
                                    stops: controller.stops.value,
                                  )
                            : null,
                        image: controller.currentBgImagePath.value.isEmpty
                            ? null
                            : DecorationImage(
                                image: Image.file(File(
                                        controller.currentBgImagePath.value))
                                    .image,
                                fit: BoxFit.cover)),
                  ),
                  onTapBg: () {
                    controller.lindiController.selectedWidget?.done();
                    controller.currentLayer.value = null;
                  }),
            );
          }),
        ),
        SizedBox(
          width: w,
          height: w,
          child: Obx(() {
            if (controller.actionIndex.value == 4 &&
                controller.bgType.value == BgColorType.gradient) {
              return GradientControlWidget(
                  onGradientColorChanged: (GradientType type,
                      List<double> stops, Offset start, Offset end) {
                    controller.gradientStart.value = start;
                    controller.gradientEnd.value = end;
                    controller.stops.value = stops;
                  },
                  bgColors: controller.colors,
                  bgStops: controller.stops,
                  gradientType: controller.grantType.value,
                  marginLeft: 20,
                  marginRight: 20,
                  cardRatio: 1.0);
            }
            return const SizedBox();
          }),
        )
      ],
    );
  }

  void _close(BuildContext context) {
    if (controller.actionIndex.value != 0) {
      controller.actionIndex.value = 0;
      return;
    }

    if (orignal != controller.basePath.value &&
        !controller.saved &&
        controller.colors.value != [Colors.transparent, Colors.transparent]) {
      showSaveImagePop(context, onSave: () {
        controller.save(context);
      }, onCancel: () {
        RmbgUtil.clearTmpObject();
        Get.back();
      });
      return;
    }
    RmbgUtil.clearTmpObject();
    Get.back();
  }

  Widget _action(BuildContext context) {
    Widget top = Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 36,
            ),
            controller.actionIndex.value == 5
                ? Text('选中图层拖动缩放旋转照片',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    )).marginOnly(bottom: 12)
                : const SizedBox(),
            controller.actionIndex.value == 0
                ? GestureDetector(
                    onTap: () {
                      controller.showRmbgLayer();
                    },
                    child: Image.asset(
                      'icon_frame_icon'.imageBjPng,
                      width: 36,
                    ),
                  ).marginOnly(right: 10, bottom: 8)
                : const SizedBox(
                    width: 36,
                  )
          ],
        ));

    Widget action = Obx(() {
      switch (controller.actionIndex.value) {
        case 0:
          return MainPanelRmbg(
            panHeight: controller.panHeight,
            onClick: (action) {
              controller.toEditor(context, RmbgType.values[action.type]);
            },
          );

        case 4:
          return ChangeBgPanel(
            onClose: () {
              controller.actionIndex.value = 0;
            },
            onConfirm: () {
              controller.actionIndex.value = 0;
            },
            onGradientColorChanged: (type, colors, stops) {
              controller.grantType.value = type;
              controller.colors.value = colors;
              controller.stops.value = stops;
              controller.currentBgImagePath.value = '';
              controller.currentBgImageUrl.value = '';
            },
            onTypeChanged: (type) {
              controller.bgType.value = type;
              debugPrint('onTypeChanged=$type');
            },
            onTextureChanged: ({imgPath, item}) => {},
          );

        case 5:
          return RmbgChangeBgPanel(
            bgUrl: controller.currentBgImageUrl.value,
            onClose: () {
              controller.actionIndex.value = 0;
            },
            onConfirm: () {
              controller.actionIndex.value = 0;
            },
            onModeChange: (mode) {
              // 处理模式切换
              switch (mode) {
                case BgActionMode.load:
                  BaseUtil.pickImage()?.then((np) {
                    if (np != null) {
                      controller.currentBgImagePath.value = np;
                      controller.currentBgImageUrl.value = '';
                    }
                  });
                  break;
                case BgActionMode.list:
                  break;
                case BgActionMode.remove:
                  controller.currentBgImagePath.value = '';
                  controller.currentBgImageUrl.value = '';
                  break;
              }
            },
            onSelected: (String path, String bgUrl) {
              controller.currentBgImagePath.value = path;
              controller.currentBgImageUrl.value = bgUrl;
            },
          );
      }

      return const SizedBox();
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [top, action],
    );
  }
}
