import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baji/controllers/bj_start_controller.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/badge_config.dart';
import 'package:get/get.dart';
import '../controllers/main_content_controller.dart';
import '../utils/base_util.dart';
import '../widgets/main_content_bj.dart';
import '../widgets/my_app_bar.dart';

class BjStartPage extends StatelessWidget {
  final controller = Get.put(BjStartController());
  final mainController = Get.put(MainContentController(), tag: 'start');

  bool makeTemplate;
  String? imagePath;
  String title;

  BjStartPage(
      {Key? key,
      required this.title,
      this.imagePath,
      this.makeTemplate = false})
      : super(key: key) {
    BaseUtil.logEvent('badge_01', params: {'task_type': 'enter'});

    if (imagePath != null) {
      controller.addSticker(name: 'start', stickerPath: imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UIUtils.setTransparentStatusBar();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
          body: Stack(children: [
        Obx(() {
          BadgeConfig currentBadgeConfig =
              BadgeConfig.presetSizes[controller.badgeIndex.value];
          var isCircle = currentBadgeConfig.isCircle;

          ConfigSize currentSize =
              currentBadgeConfig.configSizes[controller.sizeIndex.value];

          var left = currentSize.bjPreMarginLeft;
          var right = currentSize.bjPreMarginRight;

          ConfigSize copyed = ConfigSize(
              description: currentSize.description,
              size: currentSize.size,
              ratio: currentSize.ratio,
              bjPreMarginLeft: left,
              bjPreMarginRight: right,
              bjWidthPixl: currentSize.bjWidthPixl,
              bjHeightPixl: currentSize.bjHeightPixl,
              bjBloodLineWidthPixl: currentSize.bjBloodLineWidthPixl,
              radius: currentSize.radius,
              extPixl: currentSize.extPixl);

          return MainContentBj(
            mainContentController: mainController,
            isCircle: isCircle,
            customBgImage: controller.customBgImage,
            refreshBjBg: controller.refreshBjBg.value,
            bjSize: copyed,
            enableTouch: true,
            layerDatas: controller.stickerPreDatas.value,
            stickers: controller.stickerPres,
          );
        }),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _bottomSize(),
        ),
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyAppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  action: SizedBox(),
                ),
                _shapeSelector(),
              ],
            ))
      ])),
    );
  }

  Widget _bottomSize() {
    return Column(
      children: [
        // 尺寸选择区域
        Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(() => Wrap(
                  // alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: BadgeConfig
                      .presetSizes[controller.badgeIndex.value].configSizes
                      .map(((toElement) {
                    int index = BadgeConfig
                        .presetSizes[controller.badgeIndex.value].configSizes
                        .indexOf(toElement);
                    bool isSelected = controller.sizeIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.sizeIndex.value = index,
                      child: _buildSizeButton(
                          BadgeConfig.presetSizes[controller.badgeIndex.value]
                              .configSizes[index],
                          isSelected),
                    );
                  })).toList(),
                ))),

        // 下一步按钮
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.only(left: 47, right: 47, bottom: 29, top: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                var input;

                if (!makeTemplate &&
                    (imagePath == null || imagePath?.isEmpty == true)) {
                  input = await BaseUtil.pickImage();
                } else {
                  input = imagePath ?? '';
                }

                BajiUtil.goHome(
                  title: title,
                  imagePath: input,
                  isCircle: BadgeConfig
                      .presetSizes[controller.badgeIndex.value].isCircle,
                  size: BadgeConfig.presetSizes[controller.badgeIndex.value]
                      .configSizes[controller.sizeIndex.value],
                  bjName:
                      BadgeConfig.presetSizes[controller.badgeIndex.value].name,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffFF1A5A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                imagePath != null || makeTemplate ? '下一步' : '添加柄图',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeButton(ConfigSize size, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE0E9) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color:
                      isSelected ? Colors.transparent : const Color(0xFFFFE0E9),
                  width: 1)),
          child: AutoSizeText(
            size.size,
            style: const TextStyle(
              fontSize: 14,
              color:  Color(0xffFF1A5A),
              fontWeight: FontWeight.w500,
            ),
            minFontSize: 8,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// 形状选择
  Widget _shapeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFEEEEEE),
          ),
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: BadgeConfig.presetSizes.map((toElement) {
                BadgeConfig config = toElement;
                int index = BadgeConfig.presetSizes.indexOf(config);
                bool isSelected = controller.badgeIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    controller.badgeIndex.value = index;
                    controller.sizeIndex.value = 0;
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: isSelected
                          ? Border.all(color: const Color(0xffFF1A5A))
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16 / config.configSizes[0].ratio,
                          decoration: BoxDecoration(
                            shape: config.isCircle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: config.isCircle
                                ? null
                                : BorderRadius.circular(2),
                            color: isSelected
                                ? const Color(0xffFF1A5A)
                                : const Color(0xffAEAEAE),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          config.name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xffFF1A5A)
                                : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }
}
