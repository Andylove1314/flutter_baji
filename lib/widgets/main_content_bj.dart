import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/main_content_controller.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/layer_data.dart';
import 'package:flutter_baji/painters/shadow_bj_pre_painter.dart';
import 'package:flutter_baji/utils/ui_utils.dart';
import 'package:flutter_baji/widgets/change_bg/gradient_control_widget.dart';
import 'package:flutter_baji/widgets/craftsmanship/black_widget.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../clipers/shape_clipper.dart';
import '../models/badge_config.dart';
import '../painters/badget_compass_painter.dart';
import '../painters/bg_painter.dart';
import '../painters/solid_border_painter.dart';
import '../painters/target_container_painter.dart';
import 'change_bg/color_gradient_picker_panel.dart';

/// 首页 panel
class MainContentBj extends StatelessWidget {
  final bool isCircle;
  MainContentController mainContentController;

//bg widget
  final GradientType gradientType;
  final List<Color> bgColors;
  final List<double> bgStops;
  final bool paintTexture;
  final Offset gradientStart;
  final Offset gradientEnd;
  final Function(GradientType type, List<double> stops, Offset gradientStart,
      Offset gradientEnd)? onGradientColorChanged; // 颜色改变回调
  bool isGradientAction;
  List<Widget> stickers;
  List<LayerData> layerDatas;
  Function()? onMainTap;
  bool enableTouch;
  PhotoViewController? photoViewController;
  final ConfigSize bjSize;
  ImageInfo? bjBgImage;
  ImageInfo? customBgImage;
  final bool refreshBjBg;
  final bool showingCraftsmanship;
  ImageInfo? fumoImage;

  MainContentBj({
    super.key,
    required this.isCircle,
    required this.mainContentController,
    required this.bjSize,
    this.enableTouch = true,
    this.gradientType = GradientType.linear,
    this.bgColors = const [Colors.transparent, Colors.transparent],
    this.bgStops = const [0.0, 1.0],
    this.bjBgImage,
    this.customBgImage,
    this.refreshBjBg = false,
    this.paintTexture = false,
    this.gradientStart = Offset.zero,
    this.gradientEnd = Offset.zero,
    this.onGradientColorChanged,
    this.isGradientAction = false,
    this.stickers = const [],
    this.layerDatas = const [],
    this.onMainTap,
    this.photoViewController,
    this.showingCraftsmanship = false,
    this.fumoImage,
  });

  bool get isShowTotalLayer =>
      layerDatas.isEmpty ||
      (layerDatas.isNotEmpty &&
          layerDatas
              .every((element) => element.shouldShow && !element.blackLayer));

  @override
  Widget build(BuildContext context) {
    mainContentController.setShape(isCircle, bjSize);
    return IgnorePointer(
        ignoring: !enableTouch,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              width: double.infinity,
              height: double.infinity,
              "pre_bg".imageBjPng,
              fit: BoxFit.fill,
            ),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: UIUtils.isSquareScreen ? Get.width / 2 : Get.width,
                height: Get.height,
                child: PhotoView.customChild(
                  enablePanAlways: true,
                  initialScale: PhotoViewComputedScale.contained,
                  controller: photoViewController,
                  enableRotation: true,
                  disableGestures: true,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  child: _mainContent(),
                ),
              ),
            )
          ],
        ));
  }

  /// 主内容
  Widget _mainContent() {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        showingCraftsmanship
            ? const SizedBox()
            : SizedBox(
                child: CustomPaint(
                  painter: ShadowBjPrePainter(
                      isCircle: isCircle,
                      marginLeft: bjSize.bjPreMarginLeft,
                      marginRight: bjSize.bjPreMarginRight,
                      bjRatio: bjSize.ratio,
                      radius: bjSize.radius),
                  size: Size.infinite,
                ),
              ),
        SizedBox(
          child: CustomPaint(
            painter: BgPainter(
                isCircle: isCircle,
                marginLeft: bjSize.bjPreMarginLeft +
                    (showingCraftsmanship
                        ? mainContentController.getBloodViewWidth()
                        : 0),
                marginRight: bjSize.bjPreMarginRight +
                    (showingCraftsmanship
                        ? mainContentController.getBloodViewWidth()
                        : 0),
                bjRatio: bjSize.ratio,
                type: gradientType,
                colors: bgColors,
                stops: bgStops,
                bjBgImage: customBgImage,
                paintTexture: true,
                gradientStart: gradientStart,
                gradientEnd: gradientEnd,
                radius: bjSize.radius),
            size: Size.infinite,
          ),
        ),
        RepaintBoundary(
          key: mainContentController.cardKey,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: [
              Stack(
                children: [
                  if (isShowTotalLayer)
                    RepaintBoundary(
                      key: mainContentController.bgKey,
                      child: SizedBox(
                        child: CustomPaint(
                          painter: BgPainter(
                              isCircle: isCircle,
                              marginLeft: bjSize.bjPreMarginLeft +
                                  (showingCraftsmanship
                                      ? mainContentController
                                          .getBloodViewWidth()
                                      : 0),
                              marginRight: bjSize.bjPreMarginRight +
                                  (showingCraftsmanship
                                      ? mainContentController
                                          .getBloodViewWidth()
                                      : 0),
                              bjRatio: bjSize.ratio,
                              type: gradientType,
                              colors: bgColors,
                              stops: bgStops,
                              bjBgImage: bjBgImage,
                              paintTexture: paintTexture,
                              gradientStart: gradientStart,
                              gradientEnd: gradientEnd,
                              radius: bjSize.radius),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: onMainTap,
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  showingCraftsmanship
                      ? ClipPath(
                          clipper: ShapeClipper(
                              isCircle: isCircle,
                              marginLeft: bjSize.bjPreMarginLeft +
                                  mainContentController.getBloodViewWidth(),
                              marginRight: bjSize.bjPreMarginRight +
                                  mainContentController.getBloodViewWidth(),
                              bjRatio: bjSize.ratio,
                              radius: bjSize.radius),
                          child: _layers(),
                        )
                      : _layers(),
                ],
              ),
              SizedBox(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: TargetContainerPainter(
                        isCircle: isCircle,
                        marginLeft: bjSize.bjPreMarginLeft,
                        marginRight: bjSize.bjPreMarginRight,
                        bjRatio: bjSize.ratio,
                        radius: bjSize.radius,
                        maskColor:
                            showingCraftsmanship ? Colors.transparent : null),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        ),
        showingCraftsmanship
            ? const SizedBox()
            : SizedBox(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: SolidBorderPainter(
                        isCircle: isCircle,
                        marginLeft: bjSize.bjPreMarginLeft,
                        marginRight: bjSize.bjPreMarginRight,
                        bjRatio: bjSize.ratio,
                        bloodRatio:
                            bjSize.bjBloodLineWidthPixl / bjSize.bjWidthPixl,
                        radius: bjSize.radius),
                    size: Size.infinite,
                  ),
                ),
              ),
        showingCraftsmanship
            ? const SizedBox()
            : RepaintBoundary(
                key: mainContentController.compassKey,
                child: SizedBox(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: BadgetCompassPainter(
                          isCircle: isCircle,
                          marginLeft: bjSize.bjPreMarginLeft,
                          marginRight: bjSize.bjPreMarginRight,
                          bjRatio: bjSize.ratio,
                          bloodRatio:
                              bjSize.bjBloodLineWidthPixl / bjSize.bjWidthPixl,
                          radius: bjSize.radius),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
        showingCraftsmanship && isShowTotalLayer
            ? CustomPaint(
                painter: BgPainter(
                    isCircle: isCircle,
                    marginLeft: bjSize.bjPreMarginLeft +
                        mainContentController.getBloodViewWidth(),
                    marginRight: bjSize.bjPreMarginRight +
                        mainContentController.getBloodViewWidth(),
                    bjRatio: bjSize.ratio,
                    type: gradientType,
                    colors: bgColors,
                    stops: bgStops,
                    bjBgImage: fumoImage,
                    paintTexture: true,
                    gradientStart: gradientStart,
                    gradientEnd: gradientEnd,
                    radius: bjSize.radius),
                size: Size.infinite,
              )
            : const SizedBox(),
        if (isGradientAction)
          GradientControlWidget(
            onGradientColorChanged: onGradientColorChanged,
            bgColors: bgColors,
            bgStops: bgStops,
            gradientType: gradientType,
            marginLeft: bjSize.bjPreMarginLeft,
            marginRight: bjSize.bjPreMarginRight,
            cardRatio: bjSize.ratio,
          )
      ],
    );
  }

  /// 图层
  Widget _layers() {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: List.generate(stickers.length, (index) {
        return Opacity(
          opacity: !showingCraftsmanship ||
                  (layerDatas[index].shouldShow &&
                          (layerDatas[index].craftsmanshipData?.isStamping ==
                              false) ||
                      layerDatas[index].blackLayer)
              ? 1.0
              : 0.0,
          child: BlackWidget(
              balck: layerDatas[index].blackLayer, content: stickers[index]),
        );
      }),
    );
  }
}
