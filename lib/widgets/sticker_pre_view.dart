import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lindi/lindi_controller_2.dart';
import 'lindi/lindi_sticker_widget_2.dart';

class StickerPreView extends StatelessWidget {
  final LindiController2 stickerController;
  final VoidCallback? onTapBg;
  final RxBool isLocked; // 添加 visible 参数
  Widget? bgContent;

  StickerPreView(
      {super.key,
      required this.stickerController,
      required this.isLocked,
      this.bgContent,
      this.onTapBg}) {
    bgContent ??= Container(
      color: Colors.transparent,
      width: double.infinity,
      height: double.infinity,
    );
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('StikerView build');

    return Container(
      alignment: Alignment.center,
      child: Obx(() => IgnorePointer(
            ignoring: isLocked.value,
            child: _buildStickerView(),
          )),
    );
  }

  _buildStickerView() {
    return LindiStickerWidget2(
        globalKey: stickerController.globalKey,
        controller: stickerController,
        child: IgnorePointer(
          ignoring: onTapBg == null,
          child: GestureDetector(
            onTap: onTapBg,
            child: bgContent,
          ),
        ));
  }
}
