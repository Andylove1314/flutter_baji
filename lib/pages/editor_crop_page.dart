import 'dart:io';

import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:image/image.dart' as img;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:typed_data';

import '../constants/constant_editor.dart';
import '../controllers/editor_crop_controller.dart';
import '../flutter_baji.dart';
import '../models/action_data.dart';
import '../widgets/crop/custom_croplayer_painter.dart';
import '../widgets/crop/crop_panel.dart';
import '../widgets/slider_degree_parameter.dart';

class EditorCropPage extends StatelessWidget {
  final controller = Get.put(EditorCropController());

  String afterPath;

  EditorCropPage({super.key, required this.afterPath}) {
    controller.fetchCutImage(afterPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(child: Obx(() {
                    if (controller.cutImageByte.value != null) {
                      return _croper(context, controller.cutImageByte.value!);
                    }
                    return BaseUtil.loadingWidget(isLight: true);
                  })),
                  _pan(context)
                ],
              )),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10),
                child: _fwAction(),
              ))
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _croper(BuildContext context, Uint8List cutImageByte) {
    ThemeData themeData = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        surface: Colors.white,
      ),
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
            return _fetchConfig();
          },
        ));
  }

  Widget _fwAction() {
    return Obx(() => Visibility(
        visible: controller.showfw.value,
        child: SizedBox(
          height: 25,
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // 设置圆角半径
                  ),
                ),
              ),
              onPressed: () {
                controller.currentAddDegree.value = 0.0;
                controller.currentCropIndex.value = 1;
                controller.imageCroperController.reset();
              },
              child: const Text(
                '复位',
                style: TextStyle(
                    color: Color(0xff1E1925),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )),
        )));
  }

  Widget _slider() {
    return Obx(() => SliderDegreeParameterWidget(
          degree: controller.currentAddDegree.value,
          onChanged: (value) async {
            if (Platform.isIOS) {
              Haptics.vibrate(HapticsType.heavy);
            } else {
              if ((await Vibration.hasVibrator()) ?? true) {
                Vibration.vibrate(duration: 15);
              }
            }
            var increment = value - controller.currentAddDegree.value;
            controller.imageCroperController.rotate(degree: increment);
            controller.currentAddDegree.value = value;
          },
        ));
  }

  Widget _pan(BuildContext context) {
    return Obx(() => Column(
          children: [
            Visibility(visible: controller.showSli.value, child: _slider()),
            CropPanel(
              classIndex: controller.currentCropIndex.value,
              onTab: (tab) {
                controller.showStatus(tab.type == 1, controller.showfw.value);
              },
              onClick: (type, action) {
                img.Image? cutImage = controller.cutImage;
                if (cutImage == null) {
                  return;
                }

                if (type == 0) {
                  // 裁剪
                  var cropRatio;
                  if (action.cropRatio == -1) {
                    //原图
                    cropRatio = cutImage!.width / cutImage!.height;
                  } else {
                    cropRatio = action.cropRatio;
                  }
                  controller.imageCroperController
                      .updateCropAspectRatio(cropRatio);
                  controller.currentCropIndex.value =
                      cutActions[0].subActions!.indexOf(action);
                  controller.imageCroperController.updateConfig(_fetchConfig());
                } else if (type == 1) {
                  //旋转
                  if (action.type == 10) {
                    // 水平flip
                    controller.imageCroperController.flip();
                  } else if (action.type == 11) {
                    //垂直flip
                    controller.imageCroperController
                        .rotate(degree: 180.0, rotateCropRect: true);
                    controller.imageCroperController.flip();
                  } else {
                    // 角度旋转
                    controller.imageCroperController.rotate(
                        degree: action.rotateAngle,
                        rotateCropRect: true,
                        animation: true);
                  }
                }
              },
              onConfirm: () async {
                BaseUtil.showLoadingdialog(context);
                String after = await EditorUtil.cropImage(
                    controller.imageCroperController);

                ActionData currentCrop = cutActions[0]
                    .subActions![controller.currentCropIndex.value];
                if (currentCrop.cropCircle) {
                  var image = await BaseUtil.file2Image(File(after));
                  var newImage = await BajiUtil.cropImage(
                      image, 0, 0, currentCrop.cropRatio, Get.pixelRatio, false,
                      isCircle: currentCrop.cropCircle,
                      ellipseRatio: currentCrop.cropRatio);
                  after = await BaseUtil.image2File(newImage, ext: '.png');
                }

                if (EditorUtil.editorType == null) {
                  /// 更新 home after
                  EditorUtil.refreshHomeEffect(after);
                } else {
                  if (EditorUtil.singleEditorSavetoAlbum) {
                    EditorUtil.homeSaved(context, after);
                  }
                  EditorUtil.clearTmpObject(after);
                }

                BaseUtil.hideLoadingdialog();
                Navigator.pop(context, after);
              },
              actionData: cutActions,
            )
          ],
        ));
  }

  EditorConfig _fetchConfig() {
    return EditorConfig(
        cropRectPadding: const EdgeInsets.all(20),
        cornerSize: const Size(30.0, 4.0),
        cornerColor: Colors.white,
        lineColor: Colors.white,
        lineHeight: 2,
        controller: controller.imageCroperController,
        cropLayerPainter: cutActions[0]
                .subActions![controller.currentCropIndex.value]
                .cropCircle
            ? CustomEditorCropLayerPainter(
                aspectRatio: cutActions[0]
                    .subActions![controller.currentCropIndex.value]
                    .cropRatio,
                isCircle: true)
            : const EditorCropLayerPainter());
  }
}
