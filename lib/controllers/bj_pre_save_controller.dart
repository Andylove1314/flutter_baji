import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/gongyi_item.dart';
import 'package:flutter_baji/painters/shadow_bj_incard_painter.dart';
import 'package:flutter_baji/utils/ui_utils.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../models/craftsmanship_data.dart';
import '../models/zhoubian_config.dart';
import '../painters/bg_painter.dart';
import '../painters/image_painter.dart';
import '../utils/base_util.dart';
import '../widgets/lindi/lindi_controller_2.dart';
import '../widgets/lindi/lindi_sticker_icon_2.dart';
import '../widgets/net_image.dart';

class BjPreSaveController extends GetxController
    with GetTickerProviderStateMixin {
  final GlobalKey cardKey = GlobalKey();
  final GlobalKey _bjKey = GlobalKey();

  final _titleHeight = kToolbarHeight + Get.statusBarHeight / Get.pixelRatio;
  final actionHeight = 100.0;

  final cardWidth = 0.0.obs;
  final cardHeight = 0.0.obs;

  final ZhoubianConfig config = ZhoubianConfig.presetSizes[0];

  final LindiController2 lindiController = LindiController2(
    borderColor: Colors.white,
    globalKey: GlobalKey(),
    insidePadding: 0,
    maxScale: 100,
    minScale: 0.3,
  );

  BjFumoData? currentFumoData;

  final currentBgColor = Colors.transparent.obs;
  final currentBgImagePath = ''.obs;
  bool preset = true;

  late AnimationController tipAnimationController;
  final showTip = false.obs;
  final TextEditingController _textEditingController = TextEditingController();

  String? bjUrl;
  String? bjPath;

  final showHightLight = true.obs;

  Widget? content;
  Widget? contentBack;

  @override
  void onInit() {
    super.onInit();
    tipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // 延迟显示提示条
    Future.delayed(const Duration(milliseconds: 500), () {
      showTip.value = true;
      tipAnimationController.forward();
      BaseUtil.showToast('已隐藏出血线');
    });
  }

  void handleFeedback(bool isPositive) {
    // 处理反馈逻辑
    tipAnimationController.reverse();
  }

  @override
  void onClose() {
    tipAnimationController.dispose();
    super.onClose();
  }

  Future<String?> saveCardZhoubianImage(
      int widthPix, int heightPix, int extPixl) async {
    ui.Image image =
        await BaseUtil.captureImageWithKey(cardKey, Get.pixelRatio);

    String? imagePath =
        await BaseUtil.createNewSize(image, widthPix, heightPix, extPixl, '周边');

    return imagePath;
  }

  /// 显示反馈对话框
  void showFeedbackDialog(BuildContext context) {
    Get.bottomSheet(
      barrierColor: Colors.black.withOpacity(0.3),
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const Text(
              "请告诉我们使用中遇到的问题",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _textEditingController,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "请输入原因",
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 29, right: 29, bottom: 40),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ Color(0xffFF1A5A),  Color(0xffFF1A5A)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    BajiUtil.feedback(_textEditingController.text.toString())
                        .then((success) {
                      if (success ?? true) {
                        BaseUtil.showToast('感谢您的反馈！');
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "提交",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取car尺寸
  void fetchCardWh(bool isCircle, double bjRatio, dynamic image, double radius,
      ImageInfo? customBgImage, bool isCard,
      {ImageInfo? fumoImage, BjFumoData? fumoData}) {
    currentFumoData = fumoData;
    final maxWidth = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    final maxHeight = Get.height - _titleHeight - actionHeight;
    double w, h;
    if (config.ratio > 1) {
      // 宽度大于高度的情况
      w = maxWidth;
      h = w / config.ratio;
      if (h > maxHeight) {
        // 如果高度超出限制，则按高度计算
        h = maxHeight;
        w = h * config.ratio;
      }
    } else {
      // 高度大于宽度的情况
      h = maxHeight;
      w = h * config.ratio;
      if (w > maxWidth) {
        // 如果宽度超出限制，则按宽度计算
        w = maxWidth;
        h = w / config.ratio;
      }
    }
    cardWidth.value = w;
    cardHeight.value = h;
    200.milliseconds.delay(() {
      WidgetsBinding.instance.addPostFrameCallback((c) {
        _addSticker(isCircle, bjRatio, image, radius, customBgImage, isCard,
            fumoImage: fumoImage, fumoData: fumoData);
      });
    });
  }

  void _addSticker(bool isCircle, double bjRatio, dynamic image, double radius,
      ImageInfo? customBgImage, bool isCard,
      {ImageInfo? fumoImage, BjFumoData? fumoData}) {
    double bjWidth = cardWidth.value;
    double bjHeight = bjWidth / bjRatio;

    content = CustomPaint(
      painter: ShadowBjIncardPainter(radius: radius, isCircle: isCircle),
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(bjWidth / 2)
            : BorderRadius.circular(radius),
        child: SizedBox(
          width: bjWidth,
          height: bjHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: BgPainter(
                    isCircle: isCircle,
                    marginLeft: 0,
                    marginRight: 0,
                    bjRatio: bjRatio,
                    colors: [Colors.transparent, Colors.transparent],
                    stops: [0.0, 1.0],
                    bjBgImage: customBgImage,
                    paintTexture: true,
                    radius: radius),
                size: Size.infinite,
              ),
              CustomPaint(
                painter: ImagePainter(image as ui.Image),
                size: Size(bjWidth, bjHeight),
              ),
              CustomPaint(
                painter: BgPainter(
                    isCircle: isCircle,
                    marginLeft: 0,
                    marginRight: 0,
                    bjRatio: bjRatio,
                    colors: [Colors.transparent, Colors.transparent],
                    stops: [0.0, 1.0],
                    bjBgImage: fumoImage,
                    paintTexture: true,
                    radius: radius),
                size: Size.infinite,
              ),
              Obx(() => Visibility(
                  visible: showHightLight.value,
                  child: isCircle
                      ? Image.asset('pic_gaoguang_yuan'.imageBjPng,
                          fit: BoxFit.fill)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Image.asset(
                            'pic_gaoguang_fang'.imageBjPng,
                            fit: BoxFit.fill,
                          ),
                        ))),
            ],
          ),
        ),
      ),
    );

    _loadTexture('baji_beimian'.imageBjPng,
        isCircle: isCircle,
        bjRatio: bjRatio,
        radius: radius,
        bjWidth: bjWidth,
        bjHeight: bjHeight);

    lindiController.add(
        Container(
          child: RepaintBoundary(
            key: _bjKey,
            child: content!.paddingAll(7 * Get.pixelRatio),
          ),
        ),
        [
          LindiStickerIcon2(
              icon: Icons.flip,
              alignment: Alignment.bottomLeft,
              onTap: () {
                lindiController.selectedWidget!.flip();
              }),
          LindiStickerIcon2(
              icon: Icons.cached,
              alignment: Alignment.bottomRight,
              type: IconType2.resize),
        ],
        initialRlPosition: _fetchInitRlPosition(
            Size(bjWidth, bjHeight), Size(cardWidth.value, cardHeight.value)),
        parentSize: Size(cardWidth.value, cardHeight.value));
  }

  /// add sticker init position
  Offset _fetchInitRlPosition(Size stickerSize, Size parentSize) {
    Offset offset = Offset(
      ((parentSize.width - stickerSize.width) / 2) / parentSize.width,
      ((parentSize.height - stickerSize.height) / 2) / parentSize.height,
    );
    debugPrint('offset = $offset');
    return offset;
  }

  /// 上传吧唧图片到后台
  Future<void> _uploadBajiImage(bool isCard) async {
    BaseUtil.showLoadingdialog(Get.context!);
    bjPath = await BaseUtil.captureImageWithKey(_bjKey, Get.pixelRatio,
        saveFile: true);
    bjUrl = await BajiUtil.uploadBaji(bjPath);
    BaseUtil.hideLoadingdialog();
    // showShare(Get.context!, isCard);
  }

  /// 分享
  Future<void> showShare(BuildContext context, bool isCard) async {
    if (bjUrl == null) {
      await _uploadBajiImage(isCard);
    }

    BajiUtil.shareImage(context,
        image: bjPath,
        bjWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(width: 158, File(bjPath ?? '')),
            const Text(
              '这么惊艳的谷子不该被埋没，快告诉好友吧',
              style: const TextStyle(color: Color(0xff2D2727), fontSize: 14),
            )
          ],
        ),
        imageUrl: bjUrl ?? '',
        title: 'Ta做的谷子，需要宝子们围观！',
        content: '我在「你我当年」做了个${isCard ? '小卡' : '吧唧'}！宝子们快来一起呱唧呱唧！');
  }

  void _loadTexture(String asset,
      {required bool isCircle,
      required double bjRatio,
      required double radius,
      required double bjWidth,
      required double bjHeight}) {
    final image = Image.asset(asset).image;
    // image 转 ui.Image
    image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      contentBack = CustomPaint(
        painter: ShadowBjIncardPainter(radius: radius, isCircle: isCircle),
        child: CustomPaint(
          painter: ImagePainter(info.image),
          size: Size(bjWidth, bjHeight),
        ),
      );
    }));

    // image
  }

  /// 冲突检测
  bool conflictCheck(BjFumoData? fumoData, List<BjFumoData> fumoList,
      List<GyItem> gyList, String? bjImage,
      {Function()? changeGy, Function(BjFumoData? newData)? next}) {
    bool isMultiGongyi = gyList.length > 1 ||
        gyList.any((item) =>
            item.craftsmanshipData?.type != CraftsmanshipType.golden &&
            item.craftsmanshipData?.type != CraftsmanshipType.uv);

    bool conflictGyAndMo = false;

    if (gyList.isNotEmpty &&
        !isMultiGongyi &&
        (fumoData != null && fumoData.inStampingOrUv != 1)) {
      conflictGyAndMo = true;
    }

    if (isMultiGongyi || conflictGyAndMo) {
      Get.dialog(
          useSafeArea: false,
          barrierColor: Colors.transparent,
          Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 16, top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(Icons.close,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 162,
                          height: 162,
                          child: content!,
                        ),
                        if (conflictGyAndMo)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 30, top: 20, right: 30, bottom: 18),
                                decoration: BoxDecoration(
                                    color: const Color(0xffFFE9DF),
                                    borderRadius: BorderRadius.circular(100)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 1),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'icon_dengpao'.imageBjPng,
                                      width: 18,
                                    ).marginOnly(right: 2),
                                    Flexible(
                                        child: Text(
                                      '烫印和UV工艺只能在${fumoList[fumoList.indexWhere((item) => item.inStampingOrUv == 1)].name}上使用',
                                      style: const TextStyle(
                                          color: Color(0xffFF2F1D),
                                          fontSize: 13),
                                    ))
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '覆膜',
                                    style: TextStyle(
                                        color: Color(0xff666364),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ).marginOnly(top: 15, left: 15, right: 20),
                                  Expanded(
                                      child: SizedBox(
                                    height: 80,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.only(right: 15),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Widget itemWidget = Column(
                                          children: [
                                            SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Stack(
                                                children: [
                                                  NetImage(
                                                    url:
                                                        fumoList[index].image ??
                                                            '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                  if (fumoList[index]
                                                          .inStampingOrUv ==
                                                      1)
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Image.asset(
                                                        'icon_choose_color_2'
                                                            .imageBjPng,
                                                        width: 14,
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                            Text(
                                              fumoList[index].name ?? '',
                                              style: const TextStyle(
                                                  color: Color(0xff666364),
                                                  fontSize: 13),
                                            ).marginOnly(top: 4),
                                          ],
                                        );

                                        if (fumoList[index].inStampingOrUv ==
                                            1) {
                                          return itemWidget;
                                        }
                                        return Opacity(
                                            opacity: 0.4, child: itemWidget);
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const SizedBox(
                                          width: 15,
                                        );
                                      },
                                      itemCount: fumoList.length,
                                    ),
                                  ))
                                ],
                              )
                            ],
                          ),
                        if (conflictGyAndMo && isMultiGongyi)
                          const Text(
                            '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -',
                            style: TextStyle(
                                color: Color(0xffB9B9B9), fontSize: 20),
                          ),
                        if (isMultiGongyi)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 18),
                                decoration: BoxDecoration(
                                    color: const Color(0xffFFE9DF),
                                    borderRadius: BorderRadius.circular(100)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 1),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'icon_dengpao'.imageBjPng,
                                      width: 20,
                                      height: 20,
                                    ).marginOnly(right: 2),
                                    const Flexible(
                                        child: Text(
                                      '当前供应商只支持单独烫金和单独UV工艺',
                                      style: const TextStyle(
                                          color: Color(0xffFF2F1D),
                                          fontSize: 13),
                                    ))
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '工艺',
                                    style: const TextStyle(
                                        color: Color(0xff666364),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ).marginOnly(top: 40, left: 15, right: 20),
                                  Expanded(
                                      child: SizedBox(
                                    height: 120,
                                    child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.file(
                                                    File(bjImage ?? '')),
                                              ),
                                              const Text(
                                                '打印层',
                                                style: const TextStyle(
                                                    color: Color(0xff666364),
                                                    fontSize: 13),
                                              )
                                            ],
                                          ).marginOnly(right: 15),
                                          ...gyList.map((item) {
                                            return Column(
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: Image.file(
                                                      File(item.gyPath ?? '')),
                                                ),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                            'icon_tip'
                                                                .imageBjPng,
                                                            width: 14)
                                                        .marginOnly(right: 2),
                                                    Text(
                                                      item.craftsmanshipData
                                                              ?.name ??
                                                          '',
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xff666364),
                                                          fontSize: 13),
                                                    )
                                                  ],
                                                ).marginOnly(top: 4),
                                              ],
                                            ).marginOnly(right: 22);
                                          })
                                        ]),
                                  ))
                                ],
                              )
                            ],
                          ),
                        SizedBox(
                          width: 239,
                          child: FilledButton(
                              onPressed: () async {
                                Get.back();
                                if (conflictGyAndMo) {
                                  BjFumoData? newData = fumoList.firstWhere(
                                      (item) => item.inStampingOrUv == 1);
                                  next?.call(newData);
                                } else {
                                  changeGy?.call();
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Color(0xffFF1A5A)),
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 9, horizontal: 30)),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50), // 设置圆角
                                    ),
                                  )),
                              child: Text(
                                conflictGyAndMo ? '修改并继续' : '重新修改',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              )),
                        ).marginOnly(bottom: 30, top: 39)
                      ],
                    ),
                  ),
                ],
              )));
      return true;
    }

    return false;
  }

// 印谷确认
  void surePrintTip(Function()? sure) {
    Get.dialog(
        barrierColor: Colors.transparent,
        useSafeArea: false,
        Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 16, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 30,
                            ),
                            const Text(
                              '实物偏移为正常现象',
                              style: const TextStyle(
                                  color: Color(0xff19191A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child:
                                  const Icon(Icons.close, color: Colors.black),
                            ),
                          ],
                        ),
                      ).marginOnly(bottom: 12),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Image.asset('icon_dengpao'.imagePng, width: 20)
                      //         .marginOnly(right: 2),
                      //     const Text(
                      //       '均不在售后范围内！',
                      //       style: TextStyle(
                      //           color: Color(0xff19191A),
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.bold),
                      //     )
                      //   ],
                      // ).marginOnly(top: 12, bottom: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            margin: const EdgeInsets.only(left: 15, right: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xffFFD13A),
                                borderRadius: BorderRadius.circular(3.5)),
                            child: const Text('情况1',
                                style: TextStyle(
                                    color: Color(0xff19191A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Text('图案设计成圆形',
                              style: TextStyle(
                                  color: Color(0xff19191A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'tip1'.imageBjPng,
                          height: 130,
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.center,
                        ),
                      ).marginOnly(top: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            margin: const EdgeInsets.only(left: 15, right: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xffFFD13A),
                                borderRadius: BorderRadius.circular(3.5)),
                            child: const Text('情况2',
                                style: TextStyle(
                                    color: Color(0xff19191A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Flexible(
                              child: Text('图案内有圆形的文字或线条元素',
                                  style: TextStyle(
                                      color: Color(0xff19191A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ).marginOnly(top: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'tip2'.imageBjPng,
                          height: 130,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ).marginOnly(top: 15),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 19),
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 4, bottom: 4),
                        decoration:
                            const BoxDecoration(color: const Color(0xffFFD13A)),
                        child: const Text(
                            '*所有图案中带有圆形元素的情况下，实物均有不同程度的偏移，均不在售后范围内！',
                            style: TextStyle(
                                color: Color(0xff19191A),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 239,
                        child: FilledButton(
                            onPressed: () async {
                              Get.back();
                              sure?.call();
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Color(0xffFF1A5A)),
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 9, horizontal: 30)),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(50), // 设置圆角
                                  ),
                                )),
                            child: const Text(
                              '我已知晓',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            )),
                      ).marginOnly(bottom: 30, top: 39)
                    ],
                  ),
                ),
              ],
            )));
  }
}
