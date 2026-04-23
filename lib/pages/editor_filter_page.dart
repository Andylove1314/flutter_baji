import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/filters/filters_panel.dart';
import 'package:flutter_baji/widgets/parameters_container.dart';
import 'package:get/get.dart';
import '../constants/constant_editor.dart';
import '../controllers/editor_filter_controller.dart';
import '../flutter_baji.dart';
import '../widgets/diff/diff_widget.dart';

class EditorFilterPage extends StatelessWidget {
  final String afterPath;

  final controller = Get.put(EditorFilterController());

  final int? subActionIndex;
  EditorFilterPage({super.key, this.subActionIndex, required this.afterPath}) {
    controller.loadSourceImage(afterPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: FadeBeforeAfter(
              before: Image.file(File(afterPath),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain),
              after: Obx(() => (controller.textureSource.value != null)
                  ? ImageShaderPreview(
                      texture: controller.textureSource.value!,
                      configuration: controller.filterDetail.value != null
                          ? controller.currentConfig
                          : controller.none,
                    )
                  : BaseUtil.loadingWidget(isLight: true)),
              diffActionTop: MediaQuery.of(context).padding.top + 20,
              diffActionRight: 9.0,
              contentMargin: const EdgeInsets.only(bottom: 100),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                /// filters

                Obx(() => (controller.filterDetail.value != null &&
                        (controller.filterDetail.value?.id ?? 0) >= 0)
                    ? (Obx(
                        () => controller.refreshParamValue.value
                            ? _paramWidget(context)
                            : _paramWidget(context),
                      ))
                    : const SizedBox()),
                FiltersPanel(
                  fds: EditorUtil.filterList,
                  sourceFiltersConfig: controller.currentConfig,
                  usingDetail: controller.filterDetail.value,
                  initialIndex: subActionIndex,
                  onChanged: ({FilterDetail? item}) {
                    controller.filterDetail.value = item;
                    controller.updateFilterNoise();
                    controller.refreshParamValue.value =
                        !controller.refreshParamValue.value;
                  },
                  onEffectSave: () async {
                    if (controller.filterDetail.value == null) {
                      return;
                    }

                    BaseUtil.showLoadingdialog(context);
                    String effectImagePath = await BaseUtil.exportFilterImage(
                        context, controller.currentConfig,
                        texture: controller.textureSource.value);

                    if (EditorUtil.editorType == null) {
                      /// 更新 home after
                      EditorUtil.refreshHomeEffect(effectImagePath);
                    } else {
                      if (EditorUtil.singleEditorSavetoAlbum) {
                        EditorUtil.homeSaved(context, effectImagePath);
                      }
                      EditorUtil.clearTmpObject(effectImagePath);
                    }

                    BaseUtil.hideLoadingdialog();
                    Get.back();
                  },
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _paramWidget(BuildContext context) {
    return Column(
      children: [
        ...controller.currentConfig.filtersDataChildren((e) {
          /// 更新噪点
          controller.updateFilterNoise();

          /// 更新当前配置
          e.update(controller.currentConfig);
          controller.refreshParamValue.value =
              !controller.refreshParamValue.value;
        }, paramMap: filterParamInitValues, paramNames: ['Intensity'])
      ],
    );
  }
}
