import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/my_app_bar.dart';
import 'package:get/get.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../controllers/editor_header_crop_controller.dart';
import '../flutter_baji.dart';
import '../widgets/crop/custom_croplayer_painter.dart';

class EditorHeaderCropPage extends StatelessWidget {
  final controller = Get.put(EditorHeaderCropController());

  final String title;
  String? cropTip;
  final String afterPath;
  final bool isCircle;
  final String? maskAsset;
  double aspectRatio;
  bool showTipImage;

  EditorHeaderCropPage({
    super.key,
    required this.afterPath,
    required this.title,
    this.cropTip,
    this.isCircle = true,
    this.maskAsset,
    this.aspectRatio = 1.0,
    this.showTipImage = true,
  }) {
    controller.fetchCutImage(afterPath, maskImageAsset: maskAsset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Obx(() {
              if (controller.cutImageByte.value != null) {
                return _croper(
                  context,
                  controller.cutImageByte.value!,
                  controller.maskImage,
                );
              }
              return BaseUtil.loadingWidget(isLight: true);
            }),
          ),
          if (showTipImage)
            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Image.asset(
                  alignment: Alignment.center,
                  'pic_xx'.imageCropPng,
                  fit: BoxFit.fitWidth,
                ).marginSymmetric(horizontal: 20),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                MyAppBar(
                  bgColor: Colors.black,
                  leadColor: Colors.white,
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  action: const SizedBox(),
                ),
                const SizedBox(height: 20),
                Text(
                  cropTip ?? '请尽量确保将人脸放入示意线框区域',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xffFFED9B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 120,
              color: Colors.black,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 25),
              child: SizedBox(
                width: 130,
                child: FilledButton(
                  onPressed: () async {
                    BaseUtil.showLoadingdialog(context);
                    String? np = await EditorUtil.cropImage(
                      controller.imageCroperController,
                    );
                    var image = await BaseUtil.file2Image(File(np));
                    var newImage = await BajiUtil.cropImage(
                      image,
                      0,
                      0,
                      aspectRatio,
                      Get.pixelRatio,
                      false,
                      isCircle: isCircle,
                      ellipseRatio: aspectRatio,
                    );
                    np = await BaseUtil.image2File(newImage, ext: '.png');
                    BaseUtil.hideLoadingdialog();
                    Navigator.pop(context, np);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xffFF1A5A)),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 30),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // 设置圆角
                      ),
                    ),
                  ),
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _croper(BuildContext context, Uint8List cutImageByte, ui.Image? mask) {
    ThemeData themeData = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(surface: Colors.white),
    );

    return Theme(
      data: themeData,
      child: ExtendedImage.memory(
        width: MediaQuery.of(context).size.width,
        cutImageByte,
        cacheRawData: true,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            cropRectPadding: const EdgeInsets.all(20),
            cornerSize: const Size(15.0, 2.0),
            cornerColor: Colors.white,
            lineColor: Colors.white,
            lineHeight: 0.1,
            cropAspectRatio: 1.0,
            controller: controller.imageCroperController,
            cropLayerPainter: CustomEditorCropLayerPainter(
              maskImage: mask,
              aspectRatio: aspectRatio,
              isCircle: isCircle,
            ),
          );
        },
      ),
    );
  }
}
