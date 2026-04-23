import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/image_fumo_action_panel_controller.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import 'package:get/get.dart';
import '../../flutter_baji.dart';
import '../../utils/base_util.dart';
import '../bubble_container.dart';

class PreviewMoActionPanel extends StatelessWidget {
  final controller = Get.put(ImageFumoActionPanelController());
  final bool isCircle;
  final Function(
          BjFumoData? fumoData, String? thumb, String? path, String? name)
      onFumoSelected;
  final actionHeight;

  PreviewMoActionPanel(
      {super.key,
      required this.onFumoSelected,
      required this.actionHeight,
      required this.isCircle});

  @override
  Widget build(BuildContext context) {
    return BubbleContainer(
      padding: EdgeInsets.zero,
      borderRadius: 0,
      arrowOffsetRatio: 0.12,
      height: actionHeight,
      child: Obx(() {
        if (controller.fumos.isEmpty) {
          return Center(child: BaseUtil.loadingWidget());
        }

        return Obx(() => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.fumos.length,
              itemBuilder: (context, index) {
                final fumo = controller.fumos[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => _buildCircleButton(
                          child: ClipOval(
                            child: NetImage(
                              url: fumo.image ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          isSelected:
                              controller.selectedFumoIndex.value == index,
                          onTap: () {
                            controller.selectedFumoIndex.value = index;
                            controller
                                .checkCache((isCircle
                                        ? fumo.imageCircle
                                        : fumo.imageSquare) ??
                                    '')
                                .then((path) {
                              onFumoSelected(fumo, fumo.image, path, fumo.name);
                            });
                          },
                        )),
                    const SizedBox(height: 4),
                    Text(fumo.name ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  width: 12,
                );
              },
            ));
      }),
    );
  }

  Widget _buildCircleButton(
      {required Widget child, VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (isSelected)
            Image.asset(
              'icon_choose_color_2'.imageBjPng,
              width: 14,
            )
        ],
      ),
    );
  }
}
