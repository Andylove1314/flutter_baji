import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import 'package:get/get.dart';
import '../../controllers/rmbg_bg_panel_controller.dart';
import '../../utils/base_util.dart';

class RmbgBgPanel extends StatelessWidget {
  final controller = Get.put(RmbgBgPanelController());

  final String bgUrl;
  final Function(String path, String bgUrl) onSelected;
  final actionHeight;

  RmbgBgPanel(
      {super.key,
      required this.onSelected,
      required this.bgUrl,
      this.actionHeight = 73.0}) {
    controller.selectedImage.value = bgUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.zero,
        height: actionHeight,
        child: Obx(() {
          if (controller.imageBgs.isEmpty) {
            return Center(child: BaseUtil.loadingWidget());
          }

          return Obx(() => Row(
                children: [
                  Expanded(
                      child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...controller.imageBgs.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: _buildCircleButton(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: NetImage(
                                url: img.image ?? '',
                                width: 60,
                                height: actionHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                            isSelected:
                                controller.selectedImage.value == img.image,
                            onTap: () {
                              controller.selectedImage.value = img.image ?? '';
                              controller
                                  .checkCache(img.image ?? '')
                                  .then((path) {
                                onSelected.call(path ?? '', img.image ?? '');
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  )),
                  const SizedBox(width: 12),
                ],
              ));
        }));
  }

  Widget _buildCircleButton(
      {VoidCallback? onTap, required Widget child, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: actionHeight,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            child,
            Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: isSelected
                          ?  Color(0xffFF1A5A)
                          : Colors.transparent,
                      width: 2)),
            ),
          ],
        ),
      ),
    );
  }
}
