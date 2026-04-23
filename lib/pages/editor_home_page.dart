import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/editor_home_controller.dart';
import 'package:flutter_baji/widgets/main_panel_editor.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../utils/editor_type.dart';
import '../utils/ui_utils.dart';
import '../widgets/custom_widget.dart';
import '../widgets/diff/diff_widget.dart';

class EditorHomePage extends StatelessWidget {
  final controller = Get.put(EditorHomeController());

  final String orignal;

  final bool? showFeatureDialog;
  final EditorType? groupType;
  final String? subGroupId;
  final FeatureDialogBuilder? featureDialogBuilder;
  final String title;

  EditorHomePage(
      {super.key,
      required this.orignal,
      required this.title,
      this.groupType,
      this.subGroupId,
      this.showFeatureDialog = false,
      this.featureDialogBuilder}) {
    if (showFeatureDialog == true) {
      200.milliseconds.delay(() {
        controller.showFeatureDialog(Get.context!, featureDialogBuilder,
            groupType: groupType, subGroupId: subGroupId);
      });
    }
  }

  final _panHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    controller.afterPath.value = orignal;
    return WillPopScope(
      onWillPop: () {
        if (orignal != controller.afterPath.value && !controller.saved) {
          showSaveImagePop(context, onSave: () {
            controller.getSaveImagePath().then((path) {
              EditorUtil.homeSaved(context, path);
            });
          }, onCancel: () {
            EditorUtil.clearTmpObject(controller.afterPath.value);
            Navigator.pop(context);
          });
          return Future.value(false);
        }
        EditorUtil.clearTmpObject(controller.afterPath.value);
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            _content(context),
            Positioned(top: 0, left: 0, right: 0, child: _bar(context)),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  AppBar _bar(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      shadowColor: const Color(0xff19191A).withOpacity(0.1),
      elevation: 2,
      actions: [
        Obx(() => saveAction(
            action: orignal != controller.afterPath.value
                ? () async {
                    // 保存图片
                    final path = await controller.getSaveImagePath();
                    EditorUtil.homeSaved(context, path);
                  }
                : null))
      ],
    );
  }

  Widget _content(BuildContext context) {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    return Stack(
      children: [
        FadeBeforeAfter(
          before:
              Image.file(File(orignal), width: w, fit: BoxFit.contain),
          after: Obx(() => Image.file(File(controller.afterPath.value),
              width: w, fit: BoxFit.contain)),
          diffBg: const Color(0xffFAFBFF),
          diffActionBottom: 13.0,
          diffActionRight: 9.0,
          actionMargin: EdgeInsets.only(bottom: _panHeight),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: MainPanelEditor(
            panHeight: _panHeight,
            onClick: (action) {
              controller.toEditor(context, EditorType.values[action.type]);
            },
          ),
        )
      ],
    );
  }
}
