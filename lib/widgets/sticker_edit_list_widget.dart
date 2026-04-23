import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';
import '../controllers/sticker_added_controller.dart';

class StickerEditListWidget extends StatelessWidget {
  final StickerAddedController? stickerAddedController;
  const StickerEditListWidget({super.key, this.stickerAddedController});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSlider(
              '透明度',
              0.0,
              1.0,
              (value) => stickerAddedController?.opacity.value = value,
              stickerAddedController?.opacity.value ?? 1.0,
              initialValue: 1.0,
            ),
            _buildSlider(
              '色相',
              -1.0,
              1.0,
              (value) => stickerAddedController?.hue.value = value,
              stickerAddedController?.hue.value ?? 0.0,
              initialValue: 0.0,
            ),
            _buildSlider(
              '饱和度',
              -1.0,
              1.0,
              (value) => stickerAddedController?.saturation.value = value,
              stickerAddedController?.saturation.value ?? 0.0,
              initialValue: 0.0,
            ),
            _buildSlider(
              '亮度',
              -0.5,
              1.0,
              (value) => stickerAddedController?.brightness.value = value,
              stickerAddedController?.brightness.value ?? 0.0,
              initialValue: 0.0,
            ),
            _buildSlider(
              '对比度',
              -0.5,
              0.5,
              (value) => stickerAddedController?.contrast.value = value,
              stickerAddedController?.contrast.value ?? 0.0,
              initialValue: 0.0,
            ),
          ],
        ));
  }

  Widget _buildSlider(
    String title,
    double min,
    double max,
    Function(double) onChanged,
    double value, {
    double initialValue = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.1),
                trackHeight: 2,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          IconButton(
            icon: Image.asset(
              'icon_back_yopbaji'.imageBjPng,
              width: 20,
            ),
            onPressed: () => onChanged(initialValue.toDouble()),
          ),
        ],
      ),
    );
  }
}
