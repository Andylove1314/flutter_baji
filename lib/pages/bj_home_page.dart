import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baji/controllers/bj_home_controller.dart';
import 'package:flutter_baji/controllers/main_content_controller.dart';
import 'package:flutter_baji/controllers/sticker_added_controller.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/gongyi_item.dart';
import 'package:flutter_baji/models/sticker_color_item.dart';
import 'package:flutter_baji/models/template_layer_item_data.dart';
import 'package:flutter_baji/utils/ui_utils.dart';
import 'package:flutter_baji/widgets/my_app_bar.dart';
import 'package:flutter_baji/widgets/main_panel_bj.dart';
import 'package:flutter_baji/widgets/sticker/sticker_panel.dart';
import 'package:get/get.dart';

import '../models/badge_config.dart';
import '../models/craftsmanship_data.dart';
import '../models/layer_data.dart';
import '../utils/base_util.dart';
import '../widgets/change_bg/change_bg_panel.dart';
import '../widgets/change_bg/color_gradient_picker_panel.dart';
import '../widgets/craftsmanship/craftsmanship_panel.dart';
import '../widgets/custom_widget.dart';
import '../widgets/remove_bg/erase_canvas.dart';
import '../widgets/slider_normal_parameter.dart';
import '../widgets/sticker/sticker_color_widget.dart';
import '../widgets/text/text_panel.dart';
import '../widgets/main_content_bj.dart';
import '../widgets/remove_bg/remove_bg_panel.dart';
import 'dart:math' as math;

class BjHomePage extends StatelessWidget {
  final controller = Get.put(BjHomeController());
  final mainController = Get.put(MainContentController(), tag: 'home&preview');

  final String title;
  final String imagePath;
  final bool isCircle;
  final ConfigSize size;
  final List<TemplateLayerItemData> initLayers;
  final List<String> bgColors;
  final String bjName;

  BjHomePage(this.imagePath, this.isCircle, this.size, this.initLayers,
      this.bgColors, this.title, this.bjName,
      {Key? key})
      : super(key: key) {
    controller.setBjRatio(size.ratio);

    if (initLayers.isNotEmpty) {
      _initLayers(initLayers, bgColors).then((v) {
        100.milliseconds.delay(() {
          controller.doneAllSticker();
        });
      });
    } else {
      final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
      _addOrRefreshSticker(
        name: '柄图',
        stickerPath: imagePath,
        isTarget: true,
        localSticker: true,
        stickerScale:
            w / (w - size.bjPreMarginLeft / 2 - size.bjPreMarginRight / 2),
      );
    }
    BaseUtil.logEvent('badge_02',
        params: {'badge_type': isCircle ? 'round' : 'square'});
  }

  @override
  Widget build(BuildContext context) {
    // UIUtils.setTransparentStatusBar();
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            body: Stack(alignment: Alignment.center, children: [
          _main(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: //actions
                _stickerChangePanel(context),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: //actions
                _action(context),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _title(context),
          ),
          Positioned(
            top: _fetchEnhanceTop(),
            left: 0,
            right: 0,
            child: _enhance(context),
          )
        ])));
  }

  /// 内容区
  Widget _main() {
    return Obx(
        () => MainContentBj(
          enableTouch: controller.actionIndex.value != 5,
          mainContentController: mainController,
          bjSize: size,
          isCircle: isCircle,
          gradientType: controller.type.value,
          bgColors: controller.colors.value,
          bgStops: controller.stops.value,
          bjBgImage: controller.bjBgImage,
          customBgImage: controller.customBgImage,
          refreshBjBg: controller.refreshBjBg.value,
          paintTexture: controller.bgType.value == BgColorType.pattern,
          gradientStart: controller.gradientStart.value,
          gradientEnd: controller.gradientEnd.value,
          onGradientColorChanged: (GradientType type, List<double> stops,
              Offset start, Offset end) {
            controller.gradientStart.value = start;
            controller.gradientEnd.value = end;
            controller.stops.value = stops;
          },
          isGradientAction: controller.isGradientAction.value,
          stickers: controller.stickerPres,
          layerDatas: controller.stickerPreDatas.value,
          onMainTap: () {
            controller.doneAllSticker();
          },
          photoViewController: controller.photoViewController,
          showingCraftsmanship: controller.actionIndex.value == 5,
          fumoImage: controller.bjFumoImage,
        ),
      );
  }

  /// action
  Widget _action(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Obx(() => controller.actionIndex.value == 5
            ? controller.layerTypeGroup(
                controller.stickerPreDatas.value,
                onChangeGy: (layerDatas, currentType) {
                  controller.stickerPreDatas.value =
                      RxList<LayerData>.from(layerDatas);
                  controller.currentType.value = currentType;
                },
              ).marginOnly(bottom: 8)
            : Obx((() {
                if (controller.actionIndex.value != 0) {
                  return const SizedBox();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         controller.hvCenter(false);
                    //       },
                    //       child: Image.asset(
                    //         'icon_spjz'.imagePng,
                    //         width: 36,
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 5,
                    //     ),
                    //     GestureDetector(
                    //       onTap: () {
                    //         controller.hvCenter(true);
                    //       },
                    //       child: Image.asset(
                    //         'icon_czjz'.imagePng,
                    //         width: 36,
                    //       ),
                    //     ),
                    //   ],
                    // ).marginOnly(left: 10, bottom: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            BaseUtil.pickImage()?.then((newSticker) {
                              if (newSticker != null) {
                                _addOrRefreshSticker(
                                    name: '图层',
                                    stickerPath: newSticker,
                                    isTarget: false,
                                    localSticker: true);
                              }
                            });
                          },
                          child: Image.asset(
                            'icon_daoru_baji'.imageBjPng,
                            width: 36,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => {controller.showLayerPop()},
                          child: Image.asset(
                            'icon_frame_icon'.imageBjPng,
                            width: 36,
                          ),
                        ),
                      ],
                    ).marginOnly(right: 10, bottom: 8)
                  ],
                );
              }))),
        Obx(() {
          switch (controller.actionIndex.value) {
            case 0:
              return MainPanelBj(
                removeBackground: () {
                  if (controller.currentLayerData != null &&
                      controller.currentLayerData?.isFont == false) {
                    controller.actionIndex.value = 1;
                    controller.lockStickerPres();
                  } else {
                    BaseUtil.showToast('请选择要抠图的图层');
                  }
                },
                changeBackground: () {
                  controller.actionIndex.value = 2;
                  controller.doneAllSticker();
                },
                sticker: () {
                  controller.actionIndex.value = 3;
                  // controller.doneAllSticker();
                },
                text: () {
                  controller.actionIndex.value = 4;
                  controller.doneAllSticker();
                },
                craftsmanship: () {
                  controller.actionIndex.value = 5;
                  controller.doneAllSticker();
                },
              );

            case 1:
              return RemoveBgPanel(
                onClose: () {
                  _close();
                },
                onConfirm: () {
                  _close();
                  BaseUtil.logEvent('badge_03', params: {'task_type': 'rembg'});
                },
                removeAd: () {
                  BaseUtil.goVipBuy();
                },
                adTask: () {
                  _removeBg(context);
                },
                undo: () {
                  controller.currentLayerData?.clearKey1?.currentState?.undo();
                  controller.currentLayerData?.clearKey2?.currentState?.undo();
                },
                reset: () {
                  controller.currentLayerData?.clearKey1?.currentState?.reset();
                  controller.currentLayerData?.clearKey2?.currentState?.reset();
                },
                paintWidthCallback: (width) {
                  controller.currentLayerData?.clearKey1?.currentState
                      ?.updatePainterWidth(width);

                  controller.currentLayerData?.clearKey2?.currentState
                      ?.updatePainterWidth(width);
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
                      List<dynamic> rmData =
                          controller.fetchRemoveBgInputPath();
                      if (rmData[0] < 0) {
                        return;
                      }
                      controller.stickerPreDatas.value[rmData[0]]
                          .stickerRmbgPath?.value = controller
                              .stickerPreDatas.value[rmData[0]].stickerPath ??
                          '';

                      controller.stickerPreDatas.value[rmData[0]].stickerUrl =
                          controller.stickerPreDatas.value[rmData[0]]
                                  .initImageUrl ??
                              '';
                      controller.stickerPreDatas.value[rmData[0]].rmBg = false;
                      controller.stickerPreDatas.value[rmData[0]].clearKey1
                          ?.currentState
                          ?.reset();
                      controller.stickerPreDatas.value[rmData[0]].clearKey2
                          ?.currentState
                          ?.reset();
                      break;
                  }
                },
              );

            case 2:
              return ChangeBgPanel(
                onClose: () {
                  _close();
                },
                onConfirm: () {
                  if (!_canUseTexturebg(context)) {
                    return;
                  }
                  controller.actionIndex.value = 0;
                  controller.isGradientAction.value = false;
                },
                onGradientColorChanged: (type, colors, stops) {
                  // 处理渐变色变化
                  controller.type.value = type;
                  controller.colors.value = colors;
                  controller.stops.value = stops;
                  controller.bgType.value = BgColorType.gradient;
                },
                onTypeChanged: (type) {
                  controller.isGradientAction.value =
                      (type == BgColorType.gradient);
                },
                onTextureChanged: ({imgPath, item}) => {
                  controller.currentTextureData = item,
                  controller.bgType.value = BgColorType.pattern,
                  debugPrint('updateTexture: $imgPath, $item'),
                  controller.loadBgTexture(imgPath)
                },
              );

            case 3:
              return StickerPanel(
                type: 0,
                onClose: () {
                  _close();
                },
                onConfirm: () {
                  BaseUtil.logEvent('badge_03',
                      params: {'task_type': 'sticker'});
                  if (!_canUseSticker(context)) {
                    return;
                  }
                  controller.actionIndex.value = 0;
                  controller.clearSomeStickers();
                },
                onChanged: ({StickDetail? item, String? path, bool? isBig}) {
                  _addOrRefreshSticker(
                      name: item?.name ?? '',
                      stickerPath: path ?? '',
                      stickerUrl: item?.image,
                      gongyi: item?.gongyi,
                      isTarget: false,
                      isBig: isBig ?? false);
                },
                onAddLocalSticker: () {
                  BaseUtil.pickImage()?.then((newSticker) {
                    if (newSticker != null) {
                      _addOrRefreshSticker(
                          name: '图层',
                          stickerPath: newSticker,
                          isTarget: false,
                          localSticker: true);
                    }
                  });
                },
              );
            case 4:
              return Obx(() => TextPanel(
                    type: 0,
                    onClose: () {
                      _close();
                    },
                    onConfirm: () {
                      BaseUtil.logEvent('badge_03',
                          params: {'task_type': 'text'});
                      if (!_canUseSticker(context)) {
                        return;
                      }

                      controller.actionIndex.value = 0;
                      controller.doneAllSticker();
                      controller.clearSomeStickers();
                    },
                    initialIndex: 0,
                    fontDetail: null,
                    color: controller.getCurrentColor(),
                    opacity: controller.getCurrentOpacity(),
                    bold: controller.getCurrentBold(),
                    italic: controller.getCurrentItalic(),
                    underline: controller.getCurrentUnderline(),
                    textAlign: controller.getCurrentTextAlign(),
                    worldSpace: controller.getCurrentWorldSpace(),
                    lineSpace: controller.getCurrentLineSpace(),
                    curveRadius: controller.getCurrentCurveRadius(),
                    strokeColor: controller.getCurrentStrokeColor(),
                    strokeWidth: controller.getCurrentStrokeWidth(),
                    onEffectSave: () async {},
                    onFontChanged: (
                        {FontDetail? item, String? ttfPath, String? imgPath}) {
                      _addOrRefreshSticker(
                          isFont: true,
                          addNew: !controller.isCurrentFont(),
                          name: controller.getCurrentText(),
                          fontPath: ttfPath,
                          fontUrl: item?.file,
                          stickerPath: '',
                          vipData: item?.isVipFont ?? false,
                          isTarget: false,
                          isBig: false);
                    },
                    onColorChanged: (color) {
                      controller.updateColor(color);
                    },
                    onStrokeColorChanged: (color) {
                      controller.updateStrokeColor(color);
                    },
                    onOpacityChanged: (opacity) {
                      if (controller.isCurrentFont()) {
                        controller.updateOpacity(opacity);
                      }
                    },
                    onAlignChanged: (align) {
                      controller.updateTextAlign(align);
                    },
                    onBold: (bold) {
                      controller.updateBold(bold);
                    },
                    onItalic: (italic) {
                      controller.updateItalic(italic);
                    },
                    onUnderline: (underline) {
                      controller.updateUnderline(underline);
                    },
                    onWorldSpaceChanged: (worldSpace) {
                      controller.updateWorldSpace(worldSpace);
                    },
                    onLineSpaceChanged: (lineSpace) {
                      controller.updateLineSpace(lineSpace);
                    },
                    onCurveRadiusChanged: (curveRadius) {
                      controller.updateCurveRadius(curveRadius);
                    },
                    onStrokeWidthChanged: (double? strokeWidth) {
                      controller.updateStrokeWidth(strokeWidth);
                    },
                  ));

            case 5:
              return CraftsmanshipPanel(
                layerDatas: controller.stickerPreDatas.value,
                onChangeGy: (layerDatas, currentType) {
                  controller.currentType.value = currentType;
                  controller.stickerPreDatas.value =
                      RxList<LayerData>.from(layerDatas);
                },
                onClose: () {
                  _close();
                },
                onConfirm: () {
                  BaseUtil.logEvent('badge_03', params: {'task_type': 'tech'});
                  controller.actionIndex.value = 0;
                },
                isCircle: isCircle,
                size: size,
                onFumoSelect: (fumos, data, info) {
                  ///更新覆膜
                  controller.fumoDatas = fumos;
                  controller.bjFumoData = data;
                  controller.bjFumoImage = info;
                  controller.refreshBjBg.value = !controller.refreshBjBg.value;
                },
              );
          }

          return const SizedBox();
        })
      ],
    );
  }

  /// 贴纸操作
  Widget _stickerChangePanel(BuildContext context) {
    return Obx(() {
      if (controller.stickerIndex.value >= 0 &&
          controller.actionIndex.value == 3) {
        if (controller.currentLayerData?.isFont == true) {
          return const SizedBox();
        }

        return Container(
          height: _fetchStickerPanelHeight(),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '透明度',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Expanded(
                    child: Obx(() => SliderNormalParameterWidget(
                          lineColor: const Color(0xffB1B1B3),
                          initValue: controller.getCurrentOpacity(),
                          max: 1.0,
                          min: 0.0,
                          onChanged: (double value) {
                            debugPrint('sticker Opacity: $value');
                            controller.updateOpacity(value);
                          },
                        )),
                  ),
                ],
              ).paddingOnly(left: 22, right: 22, bottom: 15, top: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '颜色',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Expanded(
                      child: Obx(() => StickerColorWidget(
                            onColorSelect: (color) {
                              debugPrint('sticker color: $color');
                              controller.updateImgColor(color);
                              controller.updateStickerType(null);
                            },
                            stickerType: controller.getCurrentStickerType(),
                            color: controller.getCurrentImageColor(),
                            images: controller.currentLayerData?.gongyi ?? [],
                            onImageSelect: (item) {
                              controller.updateStickerType(item?.type);
                              controller.updateImgColor(null);
                              if (item == null) {
                                return;
                              }

                              if (item.type == 'none') {
                                _addOrRefreshSticker(
                                    name: '',
                                    stickerPath: controller
                                            .currentLayerData?.stickerPath ??
                                        '',
                                    stickerUrl:
                                        controller.currentLayerData?.stickerUrl,
                                    addNew: false);
                                return;
                              }

                              BaseUtil.fetchCacheImage(item.image)
                                  .then((value) {
                                _addOrRefreshSticker(
                                    name: '',
                                    stickerPath: value ?? '',
                                    stickerUrl: item.image,
                                    addNew: false,
                                    stickerType: item.type);
                                BaseUtil.showToast('已切换至${item.name}效果');
                              });
                            },
                          )))
                ],
              ).paddingOnly(left: 22, right: 22, bottom: 7),
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }

  /// 贴纸去背景
  void _removeBg(BuildContext context) {
    List<dynamic> rmData = controller.fetchRemoveBgInputPath();
    if (rmData[0] < 0) {
      return;
    }

    BaseUtil.showLoadingdialog(context, msg: '去背景中...');
    BajiUtil.aiRemoveBg(rmData[1]).then((newUrl) {
      if (newUrl != null) {
        debugPrint('去背景 $newUrl');
        BaseUtil.cacheImage(newUrl).then((newPath) {
          debugPrint('去背景后path $newPath');
          if (newPath != null) {
            controller.stickerPreDatas.value[rmData[0]].stickerRmbgPath?.value =
                newPath;
            controller.stickerPreDatas.value[rmData[0]].rmBg = true;
            controller.stickerPreDatas.value[rmData[0]].stickerUrl = newUrl;
            _close();
          }
          BaseUtil.hideLoadingdialog();
        });
      }
    });
  }

  /// enhance
  Widget _enhance(BuildContext context) {
    return controller.getEnhanceTip(context, (newPath, newUrl) {
      for (var element in controller.stickerPreDatas.value) {
        if (element.isTarget == true) {
          element.stickerRmbgPath?.value = newPath;
          controller.fetchStickerImgWh(newPath, size);

          // 还没有去背景的，更新stickerPath为增强后的
          if (!element.rmBg) {
            element.stickerPath = newPath;
            element.stickerUrl = newUrl;
          }
        }
      }
    });
  }

  double _fetchEnhanceTop() {
    Size bjSize = _fetchBjSize();
    var h = (Get.height - bjSize.height) / 2;
    var contentHeight = bjSize.height + h - baseOffsetY;
    return contentHeight + 10;
  }

  /// title
  Widget _title(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyAppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                size.size,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onBack: () {
            _close();
          },
          action: Row(
            children: [
              if (BajiUtil.canMakeTemplate)
                Obx(() => CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.actionIndex.value != 0
                          ? null
                          : () {
                              controller.saveTemplate(
                                  context,
                                  isCircle,
                                  size,
                                  _changeColors(controller.colors.value),
                                  mainController);
                            },
                      child: Text(
                        '出模',
                        style: TextStyle(
                            color: controller.actionIndex.value != 0
                                ? Colors.black.withOpacity(0.4)
                                : Colors.black,
                            fontSize: 14),
                      ),
                    )).marginOnly(right: 5),
              Obx(() => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: controller.actionIndex.value != 0
                        ? null
                        : () {
                            _saveAndPre(context);
                          },
                    child: Text(
                      '预览/保存',
                      style: TextStyle(
                          color: controller.actionIndex.value != 0
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black,
                          fontSize: 14),
                    ),
                  ))
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: Stack(
            children: [
              Obx(() {
                debugPrint('stickerIndex=${controller.stickerIndex.value}');
                return IndexedStack(
                  index: controller.stickerIndex.value,
                  children: controller.stickerMagnifiers,
                );
              }),
              Obx(() => Visibility(
                  visible: controller.actionIndex.value == 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          child: AutoSizeText(
                        '虚线里放图案 → 虚线外不露白 → 白线外不印刷',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () {
                          BajiUtil.bloodTipClick();
                        },
                        child: Image.asset(
                          'tip_chuxie'.imageBjPng,
                          width: 14,
                          fit: BoxFit.fill,
                        ),
                      )
                    ],
                  ).paddingOnly(top: 7, left: 5, right: 5))),
              if (BajiUtil.canMakeTemplate)
                Obx(() => controller.stickerIndex.value != -1 &&
                        controller.actionIndex.value != 1 &&
                        controller.actionIndex.value != 5
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          '贴纸位置：(x:${controller.currentStickerOffset.value.dx}, y:${controller.currentStickerOffset.value.dy})\n贴纸缩放：${controller.currentStickerScale.value}\n贴纸旋转：${controller.currentStickerRadian.value}\n贴纸反转：${controller.currentStickerFlip.value}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      )
                    : const SizedBox())
            ],
          ),
        )
      ],
    );
  }

  // vip素材检测
  bool _canUseSticker(BuildContext context) {
    if (!BaseUtil.isMember() && controller.hasVipData()) {
      showVipPop(context, content: '您使用了VIP素材，请在开通会员后保存效果？', onBuy: () {
        BaseUtil.goVipBuy();
      }, onCancel: () {
        controller.clearSomeStickers();
      });
      return false;
    }
    return true;
  }

  // vip素材检测
  bool _canUseTexturebg(BuildContext context) {
    if (!BaseUtil.isMember() && controller.isVipData()) {
      showVipPop(context, content: '您使用了VIP素材，请在开通会员后保存效果？', onBuy: () {
        BaseUtil.goVipBuy();
      }, onCancel: () {
        controller.bjBgImage = null;
        controller.refreshBjBg.value = !controller.refreshBjBg.value;
      });
      return false;
    }
    return true;
  }

  _saveAndPre(BuildContext context) {
    controller.doneAllSticker();
    _saveImage(context, false);
    // showSaveTypePop(context, onSaveJpg: () {
    //   _saveImage(context, true);
    // }, onSavePng: () {
    //   _saveImage(context, false);
    // });
  }

  /// 添加或者更新贴纸
  Future<void> _addOrRefreshSticker({
    required String name,
    required String stickerPath,
    String? stickerUrl,
    List<StickerColorItem>? gongyi,
    bool vipData = false,
    bool addNew = true,
    bool isTarget = false,
    bool isBig = false,
    bool isFont = false,
    String stickerType = 'none',
    String? fontPath,
    String? fontUrl,
    bool localSticker = false,
    StickerAddedController? stickerController,
    double stickerScale = 1.0,
    Offset? stickerOffset,
    double stickerRadian = 0.0,
    bool isFlip = false,
  }) async {
    if (!isFont && stickerPath.isEmpty) {
      return;
    }

    if (addNew) {
      Size? stickerSize = _fetchStickerSize(isTarget, isBig, isFont);
      GlobalKey<EraseCanvasState> clearKey1 = GlobalKey<EraseCanvasState>();
      GlobalKey<EraseCanvasState> clearKey2 = GlobalKey<EraseCanvasState>();

      if (stickerController == null) {
        final String uniqueTag =
            DateTime.now().microsecondsSinceEpoch.toString();
        stickerController = Get.put(StickerAddedController(), tag: uniqueTag);
      }

      if (isFont) {
        stickerController?.font.value = fontPath ?? '';
        controller.addSticker(isFont, stickerController!,
            ttfPath: fontPath,
            fontUrl: fontUrl,
            name: name,
            vipData: vipData,
            stickerSize: stickerSize!,
            magnifierKey1: clearKey1,
            magnifierKey2: clearKey2,
            eraseClearOffset: Offset.zero.obs,
            stickerOffset: stickerOffset,
            stickerRadian: stickerRadian,
            stickerScale: stickerScale,
            local: localSticker,
            magnifierSize: const Size(1, 1), onCopy: () {
          _addOrRefreshSticker(
            name: name,
            stickerPath: stickerPath,
            fontPath: fontPath,
            fontUrl: fontUrl,
            isFont: isFont,
            isTarget: false,
            isBig: isBig,
            vipData: vipData,
            localSticker: localSticker,
            // stickerController: stickerController,
            // stickerScale: stickerScale,
            // stickerOffset: stickerOffset,
            // stickerRadian: stickerRadian
          );
          //拷贝属性
          controller.updateText(stickerController!.text.value);
          controller.updateColor(stickerController.color.value);
          if (controller.isCurrentFont()) {
            controller.updateOpacity(stickerController.opacity.value);
          }
          controller.updateTextAlign(stickerController.textAlign.value);
          controller.updateBold(stickerController.bold.value);
          controller.updateUnderline(stickerController.underline.value);
          controller.updateItalic(stickerController.italic.value);
          controller.updateWorldSpace(stickerController.worldSpace.value);
          controller.updateLineSpace(stickerController.lineSpace.value);
          controller.updateFont(fontPath, fontUrl);
          controller.updateStrokeColor(stickerController.strokeColor.value);
          controller.updateCurveRadius(stickerController.curveRadius.value);
          controller.updateStrokeWidth(stickerController.strokeWidth.value);
        });
        return;
      }

      Size imgSize = await controller.fetchStickerImgWh(stickerPath, size,
          currentStickerInitSize: stickerSize);

      controller.addSticker(isFont, stickerController!,
          isTarget: isTarget,
          name: name,
          vipData: vipData,
          isBig: isBig,
          stickerPath: stickerPath,
          stickerUrl: stickerUrl,
          initImageUrl: stickerUrl,
          stickerSize: isTarget ? imgSize : stickerSize!,
          magnifierKey1: clearKey1,
          magnifierKey2: clearKey2,
          magnifierSize: imgSize,
          gongyi: gongyi,
          stickerOffset: stickerOffset,
          stickerRadian: stickerRadian,
          stickerScale: stickerScale,
          isFlip: isFlip,
          local: localSticker,
          eraseClearOffset: Offset.zero.obs, onCopy: () {
        //拷贝属性
        String? imgPath = controller.currentLayerData?.stickerRmbgPath?.value;
        String? imgUrl = controller.currentLayerData?.stickerUrl;

        _addOrRefreshSticker(
          name: '图层',
          stickerPath: imgPath ?? '',
          isFont: isFont,
          isTarget: false,
          isBig: isBig,
          vipData: vipData,
          localSticker: localSticker,
          stickerUrl: imgUrl,
          isFlip: isFlip,
          // stickerController: stickerController,
          // stickerScale: stickerScale,
          // stickerOffset: stickerOffset,
          // stickerRadian: stickerRadian
        );
      });
    } else {
      controller.updateVip(vipData);
      if (isFont) {
        controller.updateFont(fontPath, fontUrl);
      } else {
        controller.updateImageSticker(stickerPath, stickerUrl, onRefreshed: () {
          // controller.actionIndex.value = 0;
        });
      }
    }
  }

  /// 获取 贴纸大小
  Size? _fetchStickerSize(bool isTarget, bool isBig, bool isFont) {
    if (isTarget) {
      return null;
    }

    if (isFont) {
      // 创建一个临时的 TextPainter 来计算文本尺寸
      final textPainter = TextPainter(
        text: TextSpan(
          text: controller.getCurrentText(),
          style: TextStyle(
            fontFamily: controller.getCurrentFont(),
            fontSize: controller.textStickerFontSize,
            fontWeight: controller.getCurrentBold() == true
                ? FontWeight.bold
                : FontWeight.normal,
            fontStyle: controller.getCurrentItalic() == true
                ? FontStyle.italic
                : FontStyle.normal,
            decoration: controller.getCurrentUnderline() == true
                ? TextDecoration.underline
                : TextDecoration.none,
            letterSpacing: controller.getCurrentWorldSpace(), // 字间距也需要缩放
            height: 1 + (controller.getCurrentLineSpace() ?? 0.0),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: controller.getCurrentTextAlign() ?? TextAlign.left,
      );

      // 计算文本尺寸，限制最大宽度为屏幕宽度
      textPainter.layout(
          minWidth: 0,
          maxWidth: (UIUtils.isSquareScreen ? Get.width / 2 : Get.width) * 0.9);
      final textSize = textPainter.size;

      return textSize;
    }
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    final wh = (w - 63) / 4;
    Size stickerSize = Size(wh, wh);

    if (isBig) {
      Size bjsize = _fetchBjInnerSize();
      if (isCircle) {
        // 在圆形模式下，确保矩形贴纸的对角线等于圆的直径
        // 使用勾股定理计算内切矩形的边长：边长 = 直径 / √2
        double diameter = math.min(bjsize.width, bjsize.height) -
            controller.stickerIconSize * 2;
        double side = diameter / math.sqrt(2);
        stickerSize = Size(side, side);
      } else {
        stickerSize = Size(bjsize.width - controller.stickerIconSize * 2,
            bjsize.height - controller.stickerIconSize * 2);
      }
    }

    return stickerSize;
  }

  /// bj size
  Size _fetchBjSize() {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    var bjWidth = w - size.bjPreMarginLeft - size.bjPreMarginRight;
    var bjHeight = bjWidth / size.ratio;
    return Size(bjWidth, bjHeight);
  }

  /// bj inner size
  Size _fetchBjInnerSize() {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    var bjWidth = w - size.bjPreMarginLeft - size.bjPreMarginRight;
    var bjHeight = bjWidth / size.ratio;

    double lineWRatio = size.bjBloodLineWidthPixl / size.bjWidthPixl;
    double lineHRatio = size.bjBloodLineWidthPixl / size.bjHeightPixl;
    var newW = bjWidth * (1 - lineWRatio);
    var newH = bjHeight * (1 - lineHRatio);

    return Size(newW, newH);
  }

  Future<void> _saveImage(BuildContext context, bool isJpg) async {
    controller.pringImagePath = null;
    controller.gongyiSrcs.clear();
    BaseUtil.showLoadingdialog(context);
    String? bjCard = await mainController.saveBjContent();
    await BajiUtil.saveImage(bjCard ?? '', false, false);
    String? bjCard2 = await mainController
        .saveNormalLayerImage(controller.stickerPreDatas.value);
    controller.pringImagePath = bjCard2;
    await BajiUtil.saveImage(bjCard2 ?? '', true, isJpg);

    final croped = await mainController.saveBjBloodInner();
    BaseUtil.hideLoadingdialog();
    200.milliseconds.delay(() {
      BajiUtil.goPreview(
          image: croped,
          isCircle: isCircle,
          size: size,
          customBgImage: controller.customBgImage,
          fumoImage: controller.bjFumoImage,
          fumoData: controller.bjFumoData,
          fumoDatas: controller.fumoDatas,
          bjName: bjName,
          changeGy: () {
            controller.actionIndex.value = 5;
          });
    });

    BaseUtil.logEvent('badge_04', params: {
      'badge_type': isCircle ? 'round' : 'square',
      'tech_type': 'print'
    });

    _saveGongyi(isJpg);
  }

  ///保存工艺图
  Future<void> _saveGongyi(bool isJpg) async {
    // 遍历所有图层
    final originalPaths = <LayerData, String>{};
    for (var layerData in controller.stickerPreDatas.value) {
      // 如果图层包含白墨工艺
      bool hasGongyilayer = layerData.craftsmanshipData?.type != null &&
          layerData.craftsmanshipData?.type != CraftsmanshipType.none;
      bool containWhiteInk =
          layerData.gongyi?.any((item) => item.type == 'whiteInk') ?? false;
      if (hasGongyilayer && containWhiteInk) {
        // 保存原始路径
        originalPaths[layerData] = layerData.stickerRmbgPath?.value ?? '';
        // 获取白墨工艺项
        final whiteInkItem = layerData.gongyi!.firstWhere(
          (item) => item.type == 'whiteInk',
        );
        String? path = await BaseUtil.fetchCacheImage(whiteInkItem.image);
        layerData.stickerRmbgPath?.value = path ?? '';
      }
    }

    try {
      // 获取工艺图层并保存
      List<List<dynamic>> paths = await mainController
          .saveCraftsmanshipLayerImage(controller.stickerPreDatas.value);
      //恢复path
      for (var entry in originalPaths.entries) {
        entry.key.stickerRmbgPath?.value = entry.value;
      }
      // 使用 for 循环按顺序保存每个图层
      for (var path in paths) {
        if (path.isNotEmpty) {
          try {
            controller.gongyiSrcs.add(GyItem(
                gyPath: path[0],
                craftsmanshipData: path[1] as CraftsmanshipData));
            await Future.delayed(
                const Duration(milliseconds: 200)); // 添加延迟，避免并发保存
            await BajiUtil.saveImage(path[0], true, isJpg);
          } catch (e) {
            debugPrint('保存工艺图层失败: $path, 错误: $e');
            // 继续处理下一个文件，不中断整个流程
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('处理工艺图层失败: $e');
    }
  }

  /// 贴纸编辑框高度
  double _fetchStickerPanelHeight() {
    if (controller.actionIndex.value == 0) {
      return 180.0;
    } else if (controller.actionIndex.value == 1) {
      return 290.0;
    } else if (controller.actionIndex.value == 2) {
      return 415.0;
    } else if (controller.actionIndex.value == 3) {
      return 350.0;
    } else if (controller.actionIndex.value == 4) {
      return 390.0;
    }

    return 0.0;
  }

  void _close() {
    switch (controller.actionIndex.value) {
      case 0:
        Get.back();
        break;
      case 1:
        controller.actionIndex.value = 0;
        controller.unlockStickerPres();
        controller.doneAllSticker();
        break;
      case 2:
        controller.bjBgImage = null;
        controller.refreshBjBg.value = !controller.refreshBjBg.value;
        controller.actionIndex.value = 0;
        controller.isGradientAction.value = false;
        break;
      case 3:
        controller.actionIndex.value = 0;
        controller.clearSomeStickers();
        break;
      case 4:
        controller.actionIndex.value = 0;
        controller.doneAllSticker();
        controller.clearSomeStickers();
        break;
      case 5:
        controller.actionIndex.value = 0;
        break;
    }
  }

  /// 初始化图层
  Future<void> _initLayers(
      List<TemplateLayerItemData> initLayers, List<String> bgColors) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BaseUtil.showLoadingdialog(Get.context!);
    });

    debugPrint('init bgColor: $bgColors');
    controller.colors.value = _changeColors2(bgColors);

    debugPrint('init sticker count: ${initLayers.length}');
    for (var layerData in initLayers) {
      final String uniqueTag = DateTime.now().microsecondsSinceEpoch.toString();
      StickerAddedController stickerController =
          Get.put(StickerAddedController(), tag: uniqueTag);
      stickerController.opacity.value = layerData.opacity;

      debugPrint('init sticker: ${layerData.isFont} - ${layerData.name}');

      // 文字
      String? fontPath;
      String? fontUrl;
      // 图片
      String? stickerPath;

      if (layerData.isFont == 1) {
        stickerController.text.value = layerData.textSticker?.text ?? '';
        stickerController.color.value =
            layerData.textSticker?.color ?? '0xFFFFFFFF';
        stickerController.textAlign.value =
            layerData.textSticker?.textAlign == 0
                ? TextAlign.left
                : (layerData.textSticker?.textAlign == 1
                    ? TextAlign.center
                    : TextAlign.right);
        stickerController.bold.value = layerData.textSticker?.bold == 1;
        stickerController.italic.value = layerData.textSticker?.italic == 1;
        stickerController.underline.value =
            layerData.textSticker?.underline == 1;
        stickerController.worldSpace.value =
            layerData.textSticker?.worldSpace ?? 0.0;
        stickerController.lineSpace.value =
            layerData.textSticker?.lineSpace ?? 0.0;
        stickerController.strokeColor.value =
            layerData.textSticker?.strokeColor ?? '0xFFFFFFFF';
        stickerController.strokeWidth.value =
            layerData.textSticker?.strokeWidth ?? 1.0;
        stickerController.curveRadius.value =
            layerData.textSticker?.curveRadius ?? 0.0;
        fontUrl = layerData.textSticker?.fontUrl ?? '';

        fontPath = await BaseUtil.fetchCacheFont(fontUrl, cache: true);
      } else {
        String? url = layerData.imageSticker?.stickerUrl;
        if (url != null && url.isNotEmpty) {
          stickerPath = await BaseUtil.fetchCacheImage(url);
        }
        String? color = layerData.imageSticker?.color;
        if (color != null && color.isNotEmpty) {
          stickerController.imgColor.value = controller.string2Color(color);
        }
      }

      // 添加贴纸
      await _addOrRefreshSticker(
        name: layerData.name,
        stickerPath: stickerPath ?? '',
        stickerUrl: layerData.imageSticker?.stickerUrl,
        fontPath: fontPath,
        fontUrl: fontUrl,
        isFont: layerData.isFont == 1,
        isTarget: layerData.isTarget == 1,
        isBig: layerData.isBig == 1,
        vipData: layerData.vipData == 1,
        addNew: true,
        stickerController: stickerController,
        stickerOffset:
            Offset(layerData.stickerOffset[0], layerData.stickerOffset[1]),
        stickerRadian: layerData.stickerRadian,
        stickerScale: layerData.stickerScale,
        isFlip: layerData.isFlip == 1,
      );
    }
    BaseUtil.hideLoadingdialog();
  }

  /// 颜色转换,用于存储
  List<String> _changeColors(List<Color> values) {
    List<String> colors = [];
    for (Color color in values) {
      String hexColor = controller.color2String(color);
      colors.add(hexColor);
    }
    return colors;
  }

  /// 颜色转换,用于存储
  List<Color> _changeColors2(List<String> values) {
    List<Color> colors = [];
    for (String color in values) {
      Color color2 = controller.string2Color(color);
      colors.add(color2);
    }
    return colors;
  }
}
