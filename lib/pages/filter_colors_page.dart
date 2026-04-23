import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/filter_colors_controller.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/widgets/parameters_container.dart';
import 'package:flutter_gpu_filters_interface/flutter_gpu_filters_interface.dart';
import 'package:get/get.dart';

import '../constants/constant_editor.dart';
import '../models/action_data.dart';
import '../utils/base_util.dart';
import '../widgets/colors/colors_pan.dart';
import '../widgets/colors/params_list_widget.dart';
import '../widgets/custom_widget.dart';
import '../widgets/diff/diff_widget.dart';

class FilterColorsPage extends StatelessWidget {
  final controller = Get.put(
    FilterColorsController(),
    tag: DateTime.now().microsecondsSinceEpoch.toString(),
  );

  final String afterPath;

  final int type;

  FilterColorsPage({super.key, required this.afterPath, required this.type}) {
    debugPrint('FilterColorsPage=$afterPath');
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
              before: Image.file(
                File(afterPath),
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
              after: Obx(() {
                // 依赖刷新标记，确保参数变化时重建预览
                final _ = controller.refreshParamValue.value;
                return (controller.textureSource.value != null)
                    ? ImageShaderPreview(
                        texture: controller.textureSource.value!,
                        configuration: controller.finalConfig,
                      )
                    : BaseUtil.loadingWidget(isLight: true);
              }),
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
                /// colors
                Obx(
                  () => controller.refreshParamValue.value
                      ? _paramWidget(context)
                      : _paramWidget(context),
                ),
                ColorsPan(
                  tags: _genConfig(),
                  sourceFiltersConfig: controller.finalConfig,
                  onClick: (action) async {
                    controller.currentParamsList.value = action.params ?? [];
                    if (action.params == null) {
                      bool? logined = (await BaseUtil.isLogin()) ?? false;

                      if (!logined) {
                        return;
                      }
                      _showEffects(context);
                    }
                  },
                  onEffectSave: () async {
                    if (controller.textureSource.value == null) {
                      return;
                    }

                    showSaveEffectPop(
                      context,
                      controller.finalConfig,
                      controller.textureSource.value!,
                      onSave: (saveEffect, name) async {
                        BaseUtil.showLoadingdialog(context);

                        await Future.delayed(const Duration(milliseconds: 500));
                        String effectImagePath =
                            await BaseUtil.exportFilterImage(
                              context,
                              controller.finalConfig,
                              texture: controller.textureSource.value,
                            );

                        if (type == 0) {
                          if (EditorUtil.editorType == null) {
                            /// 更新 home after
                            EditorUtil.refreshHomeEffect(effectImagePath);
                          } else {
                            if (EditorUtil.singleEditorSavetoAlbum) {
                              EditorUtil.homeSaved(context, effectImagePath);
                            }
                            EditorUtil.clearTmpObject(effectImagePath);
                          }
                        } else if (type == 1) {
                          if (RmbgUtil.rmbgType == null) {
                            /// 更新 home after
                            RmbgUtil.refreshHomeLayerEffect(effectImagePath);
                          } else {
                            RmbgUtil.saveImage(context, effectImagePath);
                            RmbgUtil.clearTmpObject();
                          }
                        }

                        if (saveEffect) {
                          bool? logined = (await BaseUtil.isLogin()) ?? false;

                          if (!logined) {
                            return;
                          }

                          bool? successed = await BaseUtil.saveColorEffectParam(
                            type,
                            controller.finalConfig.parameters,
                            effectImagePath,
                            name,
                          );
                          BaseUtil.showToast.call(
                            successed == true ? '保存配方成功' : '保存配方失败',
                          );
                        }
                        BaseUtil.hideLoadingdialog();
                        Get.back();
                      },
                      onCancel: () {
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  void _showEffects(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.transparent,
      builder: (c) {
        return GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: 13,
                  bottom: 184,
                  child: ParamsListWidget(
                    type: type,
                    bottom: 184,
                    applyPf: (effect) {
                      for (ConfigurationParameter p
                          in controller.finalConfig.parameters) {
                        (p as NumberParameter).value =
                            effect.paramGroup[p.name] ?? 0.0;
                        p.update(controller.finalConfig);
                      }
                      controller.refreshParamValue.value =
                          !controller.refreshParamValue.value;
                    },
                    recover: () {
                      if (controller.currentParamMap.isEmpty) {
                        for (ConfigurationParameter p
                            in controller.finalConfig.parameters) {
                          (p as NumberParameter).value =
                              colorParamInitValues[p.name] ?? 0.0;
                          p.update(controller.finalConfig);
                        }
                      } else {
                        for (ConfigurationParameter p
                            in controller.finalConfig.parameters) {
                          (p as NumberParameter).value =
                              controller.currentParamMap[p.name] ?? 0.0;
                          p.update(controller.finalConfig);
                        }
                      }
                      controller.refreshParamValue.value =
                          !controller.refreshParamValue.value;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ActionData> _genConfig() {
    for (ActionData item in colorActions) {
      item.configs = controller.finalConfig
          .currentParameter(item.params ?? [])
          .cast<NumberParameter>();
    }
    return colorActions;
  }

  void _saveCurrentEffectParam() {
    for (var param in controller.finalConfig.parameters) {
      controller.currentParamMap[param.name] =
          (param as NumberParameter).value * 1.0;
    }
  }

  Widget _paramWidget(BuildContext context) {
    return Column(
      children: [
        ...controller.finalConfig.colorsEffectChildren(
          (e) {
            controller.refreshParamValue.value =
                !controller.refreshParamValue.value;
            e.update(controller.finalConfig);
            _saveCurrentEffectParam();
          },
          paramMap: colorParamInitValues,
          paramNames: controller.currentParamsList.value,
        ),
      ],
    );
  }
}
