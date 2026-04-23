import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/bubble_container.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import 'package:get/get.dart';
import '../../controllers/image_bg_action_panel_controller.dart';
import '../../flutter_baji.dart';
import '../../utils/base_util.dart';

class PreviewBgActionPanel extends StatelessWidget {
  final controller = Get.put(ImageBgActionPanelController());

  final Function(bool setImage, bool preset, {Color? color, String? path})
      onColorSelected;
  final actionHeight;

  PreviewBgActionPanel(
      {super.key, required this.onColorSelected, required this.actionHeight});

  @override
  Widget build(BuildContext context) {
    return BubbleContainer(
        padding: EdgeInsets.zero,
        borderRadius: 0,
        arrowOffsetRatio: 0.46,
        height: actionHeight,
        child: Obx(() {
          if (controller.colors.isEmpty) {
            return Center(child: BaseUtil.loadingWidget());
          }

          return Obx(() => Row(
                children: [
                  Expanded(
                      child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Obx(() => _buildCircleButton(
                            child: ClipOval(
                              child: Image.asset(
                                'trans_color_icon'.imageBjPng,
                                width: 37,
                                height: 37,
                                fit: BoxFit.cover,
                              ),
                            ),
                            isSelected: controller.clickTransparent.value,
                            onTap: () {
                              controller.selectedColorIndex.value = -1;
                              controller.clickTransparent.value = true;
                              onColorSelected.call(false, false,
                                  color: Colors.transparent);
                            },
                          )).paddingOnly(right: 12),
                      ...controller.colors.map((color) {
                        Color? bgColor = Color(int.parse(
                            '0xff${(color.color ?? 'ffffff').replaceAll('#', '')}'));

                        bool isSelected = controller.colors.indexOf(color) ==
                            controller.selectedColorIndex.value;

                        Widget circleButton = _buildCircleButton(
                          color: Color(
                            int.parse(
                                '0xff${(color.color ?? 'ffffff').replaceAll('#', '')}'),
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            controller.selectedColorIndex.value =
                                controller.colors.indexOf(color);
                            onColorSelected.call(false, true, color: bgColor);
                            controller.clickImage.value = false;
                            controller.clickTransparent.value = false;
                          },
                        );

                        if (color.image != null) {
                          circleButton = _buildCircleButton(
                            child: ClipOval(
                              child: NetImage(
                                url: color.image ?? '',
                                width: 37,
                                height: 37,
                                fit: BoxFit.cover,
                              ),
                            ),
                            isSelected: isSelected,
                            onTap: () {
                              controller.selectedColorIndex.value =
                                  controller.colors.indexOf(color);
                              controller
                                  .checkCache(color.image ?? '')
                                  .then((path) {
                                onColorSelected.call(true, true, path: path);
                                controller.clickImage.value = false;
                                controller.clickTransparent.value = false;
                              });
                            },
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: circleButton,
                        );
                      }),
                      if (controller.selectedImage.value.isNotEmpty)
                        _buildCircleButton(
                          child: ClipOval(
                            child: Image.file(
                              File(controller.selectedImage.value),
                              width: 37,
                              height: 37,
                              fit: BoxFit.cover,
                            ),
                          ),
                          isSelected: controller.clickImage.value,
                          onTap: () {
                            onColorSelected.call(true, false,
                                path: controller.selectedImage.value);
                            controller.clickImage.value = true;
                            controller.selectedColorIndex.value = -1;
                            controller.clickTransparent.value = false;
                          },
                        )
                    ],
                  )),

                  // 相机按钮
                  _buildCircleButton(
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color:  Color(0xffFF1A5A),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                    onTap: () async {
                      String? path = await BaseUtil.pickImage();
                      if (path == null) {
                        return;
                      }
                      controller.selectedImage.value = path;
                      onColorSelected.call(true, false,
                          path: path, color: null);
                      controller.clickImage.value = true;
                      controller.selectedColorIndex.value = -1;
                      controller.clickTransparent.value = false;
                    },
                  ),

                  const SizedBox(width: 12),
                ],
              ));
        }));
  }

  Widget _buildCircleButton(
      {Color? color,
      VoidCallback? onTap,
      Widget? child,
      bool isSelected = false}) {
    Widget icon = Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
    if (color == Colors.transparent) {
      icon = Image.asset(
        'icon_tm_color'.imageBjPng,
        width: 37,
        height: 37,
        fit: BoxFit.fill,
      );
    } else if (child != null) {
      icon = child;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: isSelected
                          ? const Color(0xffFF1A5A)
                          : Colors.transparent,
                      blurRadius: 5)
                ]),
            width: 37,
            height: 37,
          ),
          icon
        ],
      ),
    );
  }
}
