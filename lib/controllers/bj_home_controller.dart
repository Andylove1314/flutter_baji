import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/image_change_background_controller.dart';
import 'package:flutter_baji/controllers/bj_sticker_controller.dart';
import 'package:flutter_baji/models/layer_data.dart';
import 'package:flutter_baji/utils/ui_utils.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../flutter_baji.dart';
import '../models/badge_config.dart';
import '../models/gongyi_item.dart';
import '../models/template_data.dart';
import '../models/template_layer_item_data.dart';
import '../utils/base_util.dart';
import '../widgets/bubble_container.dart';
import '../widgets/layer_order_list_widget.dart';
import '../widgets/sticker_pre_view.dart';
import 'image_craftsmanship_controller.dart';
import 'image_remove_background_controller.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'main_content_controller.dart';

const baseOffsetY = 50.0;

class BjHomeController extends GetxController
    with
        ImageRemoveBackgroundController,
        ImageChangeBackgroundController,
        BjStickerController,
        ImageCraftsmanshipController {
  //功能索引
  final actionIndex = 0.obs;
  ImageInfo? bjBgImage;
  ImageInfo? customBgImage;
  final refreshBjBg = false.obs;

  // targetImage 图片宽高
  var targetImgWidgetWidth = 0.0; // widget实际宽度
  var targetImgWidgetHeight = 0.0; // widget实际高度

  final showEnhance = false.obs;

  final PhotoViewController photoViewController =
      PhotoViewController(initialPosition: const Offset(0, -baseOffsetY));

  double bjRatio = 1.0;

  void setBjRatio(double ratio) {
    bjRatio = ratio;
    if (bjRatio == 1.0) {
      BajiUtil.makeBjType = MakeType.baji;
    } else {
      BajiUtil.makeBjType = MakeType.xiaoka;
    }
  }

  List<GyItem> gongyiSrcs = [];
  String? pringImagePath;

  /// 覆膜相关
  List<BjFumoData> fumoDatas = [];
  BjFumoData? bjFumoData;
  ImageInfo? bjFumoImage;

  final TextEditingController _templateController = TextEditingController();

  @override
  void onInit() {
    // 监听 actionIndex 变化
    ever(actionIndex, (value) {
      if (actionIndex.value == 0) {
        _refreshScaleAndPosition(1.0, bjRatio == 1.0 ? 0 : 30);
        for (var element in stickerPreDatas.value) {
          element.clearEnable.value = false;
        }
      } else if (actionIndex.value == 1) {
        _refreshScaleAndPosition(bjRatio == 1.0 ? 1.0 : 0.95, -10);
        currentLayerData?.clearEnable.value = true;
      } else if (actionIndex.value == 2) {
        _refreshScaleAndPosition(bjRatio == 1.0 ? 1.0 : 0.85, -50);
        for (var element in stickerPreDatas.value) {
          element.clearEnable.value = false;
        }
      } else if (actionIndex.value == 3 || actionIndex.value == 4) {
        _refreshScaleAndPosition(bjRatio == 1.0 ? 1.0 : 0.80, -45);
        for (var element in stickerPreDatas.value) {
          element.clearEnable.value = false;
        }
      } else if (actionIndex.value == 5) {
        _refreshScaleAndPosition(0.62, -100);
        for (var element in stickerPreDatas.value) {
          element.clearEnable.value = false;
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScaleAndPosition(1.0, bjRatio == 1.0 ? 0 : 30);
    });
    ever(isClearing, (value) {
      if (value) {
        currentLayerData?.lindiController.selectedWidget?.lock();
      } else {
        currentLayerData?.lindiController.selectedWidget?.unlock();
      }
    });
    _loadCustomBgTexture("staff_1024".imageBjPng);
    super.onInit();
  }

  /// 贴纸宽高获取
  Future<Size> fetchStickerImgWh(String path, ConfigSize size,
      {Size? currentStickerInitSize}) async {
    //target
    bool isTarget = currentStickerInitSize == null;
    final file = File(path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    final imgWidthPix = frame.image.width;
    final imgHeightPix = frame.image.height;
    final screenWidth = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;

    if (isTarget) {
      if (imgWidthPix < size.bjWidthPixl * 1.5 ||
          imgHeightPix < size.bjHeightPixl * 1.5) {
        showEnhance.value = true;
      } else {
        showEnhance.value = false;
      }
    }

    // 判断是长图还是宽图
    var width;
    var height;
    var scale;
    if (imgWidthPix / imgHeightPix > screenWidth / Get.height) {
      width = screenWidth;
      height = width * imgHeightPix / imgWidthPix;
      if (isTarget) {
        scale = 1.0;
      } else {
        scale = currentStickerInitSize.width / width;
      }
    } else {
      height = Get.height;
      width = height * imgWidthPix / imgHeightPix;
      if (isTarget) {
        scale = 1.0;
      } else {
        scale = currentStickerInitSize.height / height;
      }
    }

    debugPrint('sticker原始尺寸: ${imgWidthPix}x${imgHeightPix}');
    debugPrint('sticker显示尺寸: ${width}x${height}');
    return Size(width * scale, height * scale);
  }

//增强提示
  Widget getEnhanceTip(BuildContext context,
      Function(String newPath, String newUrl) onEnhanced) {
    return Obx(() => actionIndex.value == 0 && showEnhance.value
        ? Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BubbleContainer(
                    showArrow: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '此图片分辨率低，可能会影响成品效果',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  String? path = _fetchEnhanceInputPath();
                                  BaseUtil.logEvent('badge_03',
                                      params: {'task_type': 'enhance'});
                                  BaseUtil.showLoadingdialog(context,
                                      msg: '图片增强中，请稍候');
                                  BajiUtil.enhance(path ?? '', 'normal')
                                      .then((newUrl) {
                                    if (newUrl != null) {
                                      debugPrint('增强后 $newUrl');
                                      BaseUtil.cacheImage(newUrl)
                                          .then((newPath) {
                                        debugPrint('增强后path $newPath');
                                        if (newPath != null) {
                                          onEnhanced.call(newPath, newUrl);
                                        }
                                        BaseUtil.hideLoadingdialog();
                                        BaseUtil.showToast('增强完成');
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 22),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:  Color(0xffFF1A5A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '人像照片增强',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                )),
                            GestureDetector(
                                onTap: () {
                                  BaseUtil.showLoadingdialog(context,
                                      msg: '图片增强中，请稍候');

                                  String? path = _fetchEnhanceInputPath();
                                  BajiUtil.enhance(path ?? '', 'game-enhance')
                                      .then((newUrl) {
                                    if (newUrl != null) {
                                      debugPrint('增强后 $newUrl');
                                      BaseUtil.cacheImage(newUrl)
                                          .then((newPath) {
                                        debugPrint('增强后path $newPath');
                                        if (newPath != null) {
                                          onEnhanced.call(newPath, newUrl);
                                        }
                                        BaseUtil.hideLoadingdialog();
                                        BaseUtil.showToast('增强完成');
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 22),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFF1A5A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '游戏截图增强',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ],
                    )).marginOnly(top: 10, right: 10),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      showEnhance.value = false;
                    },
                    child: Image.asset(
                      'icon_blackclose_pop_2'.imageBjPng,
                      width: 28,
                      height: 28,
                    ),
                  ),
                )
              ],
            ))
        : const SizedBox());
  }

  /// 显示图层
  void showLayerPop() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    '图层排序',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 确认排序 todo
                      Get.back();
                    },
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => LayerOrderListWidget(
                    stickerPreDatas: stickerPreDatas.value,
                    stickerPres: stickerPres,
                    stickerMagnifiers: stickerMagnifiers,
                    onDelete: (item) {
                      int index = stickerPreDatas.value.indexOf(item);
                      stickerPres.removeAt(index);
                      stickerMagnifiers.removeAt(index);
                      stickerPreDatas.value = RxList<LayerData>.from(
                          stickerPreDatas.value..removeAt(index));
                      stickerIndex.value = -1;
                    },
                    onReorder: (items, items1, items2) {
                      stickerPres = items1;
                      stickerMagnifiers = items2;
                      stickerPreDatas.value = RxList<LayerData>.from(items);
                    },
                    onLock: (lock, index) {
                      if (lock) {
                        stickerPreDatas
                            .value[index].lindiController.selectedWidget
                            ?.done();
                        if (currentLayerData == stickerPreDatas.value[index]) {
                          stickerIndex.value = -1;
                        }
                      }
                    },
                    onTap: (index) {},
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void loadBgTexture(String? path) {
    if (path == null) {
      return;
    }

    final image = Image.file(File(path)).image;
    image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      bjBgImage = info;
      refreshBjBg.value = !refreshBjBg.value;
    }));
  }

  void _loadCustomBgTexture(String asset) {
    if (asset == null) {
      return;
    }

    final image = Image.asset(asset).image;
    image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      customBgImage = info;
      refreshBjBg.value = !refreshBjBg.value;
    }));
  }

  /// 初始化编辑区位置及缩放
  void _refreshScaleAndPosition(double scale, double delta) {
    photoViewController.setScaleInvisibly(scale);
    photoViewController.position = Offset(0, delta - baseOffsetY);
  }

  /// 获取增强目标图片路径
  String? _fetchEnhanceInputPath() {
    // 获取target的stickerRmbgPath.value
    String? lastPath;
    for (var element in stickerPreDatas.value) {
      if (element.isTarget == true) {
        lastPath = element.stickerRmbgPath?.value ?? '';
        break;
      }
    }
    debugPrint('enhanceInputPath: $lastPath');
    return lastPath;
  }

  /// 是否包含涂抹后的图层
  bool _containClearLayer() {
    for (var element in stickerPreDatas.value) {
      if (element.clearKey1?.currentState?.canUndo() ?? false) {
        return true;
      }
    }
    return false;
  }

  /// 获取去背景目标图片路径
  List<dynamic> fetchRemoveBgInputPath() {
    // 获取target的stickerRmbgPath.value
    int index = -1;
    for (var element in stickerPres) {
      var pre = (element as RepaintBoundary).child as StickerPreView;
      if (pre.isLocked.value == false) {
        index = stickerPres.indexOf(element);
        break;
      }
    }
    //获取当前图层
    if (index == -1) {
      return [-1, null];
    }

    String? lastPath = stickerPreDatas.value[index].stickerRmbgPath?.value;
    debugPrint('rmbgInputPath: $lastPath');
    return [index, lastPath];
  }

  // 创建模板数据
  Future<TemplateData?> _createTemplateData(
      String? maker,
      List<LayerData> layerDatas,
      bool isCircle,
      ConfigSize configSize,
      List<String> bgColors) async {
    if (layerDatas.isEmpty) {
      return null;
    }
    List<TemplateLayerItemData> layerItems = [];
    for (var layerData in layerDatas) {
      // 创建图层项数据
      TemplateLayerItemData layerItem = TemplateLayerItemData(
          stickerScale: layerData.stickerScale,
          stickerOffset: [
            layerData.stickerOffset?.dx ?? 0.0,
            layerData.stickerOffset?.dy ?? 0.0
          ],
          stickerRadian: layerData.stickerRadian,
          opacity: layerData.stickerWidgetController?.opacity.value ?? 1.0,
          vipData: layerData.isVipData ? 1 : 0,
          isTarget: layerData.isTarget ? 1 : 0,
          isBig: layerData.isBig ? 1 : 0,
          name: layerData.name.value,
          isFont: layerData.isFont ? 1 : 0,
          isFlip: layerData.lindiController.selectedWidget?.isFlip() == true
              ? 1
              : 0);

      // 根据是否为文字类型设置对应的数据
      if (layerData.isFont) {
        final controller = layerData.stickerWidgetController;
        layerItem.textSticker = TemplateLayerText(
            text: controller.text.value,
            fontUrl: layerData.fontUrl,
            color: controller.color.value,
            bold: controller.bold.value ? 1 : 0,
            italic: controller.italic.value ? 1 : 0,
            underline: controller.underline.value ? 1 : 0,
            textAlign: controller.textAlign.value == TextAlign.left
                ? 0
                : controller.textAlign.value == TextAlign.center
                    ? 1
                    : 2,
            worldSpace: controller.worldSpace.value,
            lineSpace: controller.lineSpace.value,
            strokeColor: controller.strokeColor.value,
            strokeWidth: controller.strokeWidth.value,
            curveRadius: controller.curveRadius.value);
      } else {
        if (layerData.stickerUrl == null || layerData.stickerUrl!.isEmpty) {
          layerData.stickerUrl = await BajiUtil.uploadTemplateImage(
              layerData.stickerRmbgPath?.value ?? '');
        }

        layerItem.imageSticker =
            TemplateLayerImage(stickerUrl: layerData.stickerUrl);

        if (layerData.stickerWidgetController.imgColor.value !=
            Colors.transparent) {
          layerItem.imageSticker?.color =
              color2String(layerData.stickerWidgetController.imgColor.value);
        }
      }
      layerItems.add(layerItem);
    }

    TemplateData templateData = TemplateData(
        makerName: maker,
        type: isCircle ? 0 : 1,
        configSize: configSize,
        layerItems: layerItems,
        bgColors: bgColors);

    return templateData;
  }

  String color2String(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  Color string2Color(String color) {
    return Color(int.parse(color.replaceAll("#", ""), radix: 16));
  }

// 出模版
  Future<void> saveTemplate(
      BuildContext context,
      bool isCircle,
      ConfigSize configSize,
      List<String> bgColors,
      MainContentController mainController) async {
    if (stickerPreDatas.value.isEmpty) {
      BaseUtil.showToast('请添加图层');
      return;
    }

    if (_containClearLayer()) {
      BaseUtil.showToast('请移除涂抹后的图层');
      return;
    }

    BaseUtil.showLoadingdialog(context);
    doneAllSticker();
    // 创建模板参数
    String? maker = await BaseUtil.fetchDeviceName();
    final templateData = await _createTemplateData(
        maker, stickerPreDatas.value, isCircle, configSize, bgColors);

    final jsonData = templateData?.toJson();
    String jsonString = jsonEncode(jsonData);
    debugPrint('TemplateData: $jsonString');

    // 模版吧唧图
    var inner = await mainController.saveBjBloodInner();
    String? bjUrl;
    String? path;
    if (inner != null) {
      path = await BaseUtil.image2File(inner);
      if (path != null) {
        bjUrl = await BajiUtil.uploadTemplateImage(path);
      }
    }

    // 模版名称
    String templateName = 'template_${DateTime.now().millisecondsSinceEpoch}';

    BaseUtil.hideLoadingdialog();

    Get.bottomSheet(
        backgroundColor: Colors.white,
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '出模成功',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '制作人：',
                  ),
                  Text(
                    maker ?? '',
                  ),
                  const Text(
                    '+',
                  ).marginOnly(left: 10, right: 10),
                  Expanded(
                    child: TextField(
                        controller: _templateController,
                        decoration: const InputDecoration(
                            hintText: '输入制作人名称',
                            hintStyle: TextStyle(color: Colors.blue))),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '模版名称：',
                  ),
                  Expanded(
                    child: Text(
                      templateName,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '模版成图：',
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Image.file(
                        File(path ?? ''),
                        height: 80,
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                  child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('模版参数：'),
                    Flexible(
                      child: Text('$jsonString'),
                    ),
                  ],
                ),
              )),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 120,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey)),
                        onPressed: () {
                          BajiUtil.copyTemplate(
                              makerName: '$maker-${_templateController.text}',
                              templateParam: jsonString);
                        },
                        child: const Text(
                          '拷贝模板参数',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                      width: 120,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.pink)),
                        onPressed: () {
                          BaseUtil.showLoadingdialog(context);
                          BajiUtil.saveTemplate(
                                  maker: '$maker-${_templateController.text}',
                                  templateImage: bjUrl ?? '',
                                  templateName: templateName,
                                  templateParam: jsonString)
                              ?.then((success) {
                            BaseUtil.hideLoadingdialog();
                            if (success) {
                              BaseUtil.showToast('模板已保存');
                            } else {
                              BaseUtil.showToast('模板保存失败');
                            }
                          });
                        },
                        child: const Text(
                          '保存模板',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ))
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void onClose() {
    stickerPreDatas.value.clear();
    stickerPres.clear();
    stickerMagnifiers.clear();
    stickerIndex.value = -1;

    ///来自模版，没有进启动页
    if (BajiUtil.templateData != null) {
      BajiUtil.closeCallbacks();
    }

    super.onClose();
  }
}
