import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import 'back_pop_widget.dart';
import 'save_jpg_png_pop_widget.dart';
import 'save_tip_pop_widget.dart';
import 'vip_pop_widget.dart';

void showVipPop(BuildContext context,
    {required Function() onBuy,
    required Function() onCancel,
    required String content}) {
  showDialog(
      context: context,
      builder: (c) {
        return Material(
          color: Colors.transparent,
          child: VipTipPopWidget(
            content: content,
            onBuy: onBuy,
            onCancel: onCancel,
          ),
        );
      });
}

void showRmbgVipPop(BuildContext context, {required Function() onBuy}) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFFDBEC), Colors.white]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      height: 360,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'pic_shiyi_qbj'.imageRmbgPng,
                height: 180,
              ),
              const SizedBox(
                height: 26,
              ),
              const Text(
                '开通会员后，可以在一张图片中加入多个去背景人物',
                style: const TextStyle(
                    color: Color(0xff19191A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ).marginOnly(left: 30, right: 30),
              const SizedBox(
                height: 32,
              ),
              FilledButton(
                  onPressed: () async {
                    Get.back();
                    onBuy.call();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all( Color(0xffFF1A5A)),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 30)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // 设置圆角
                        ),
                      )),
                  child: const Text(
                    '购买会员',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ))
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                'icon_close_pop'.imageRmbgPng,
                width: 26,
                height: 26,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

void showSaveTypePop(
  BuildContext context, {
  required Function() onSaveJpg,
  required Function() onSavePng,
}) {
  Get.dialog(
      Container(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: SaveJpgPngPopWidget(
            onSaveJpg: onSaveJpg,
            onSavePng: onSavePng,
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      useSafeArea: true);
}

void showSaveImagePop(BuildContext context,
    {required Function() onSave, required Function() onCancel}) {
  showDialog(
      context: context,
      builder: (c) {
        return Material(
          color: Colors.transparent,
          child: BackTipPopWidget(
            onSave: onSave,
            onCancel: onCancel,
          ),
        );
      });
}

/// save 按钮
Widget saveAction({Function()? action}) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    child: IconButton(
      onPressed: action,
      icon: Opacity(
        opacity: action == null ? 0.5 : 1.0,
        child: Image.asset(
          'icon_save'.imageEditorPng,
          width: 21,
        ),
      ),
    ),
  );
}

void showSaveEffectPop(
    BuildContext context, ShaderConfiguration config, TextureSource texture,
    {required Function(bool saveEffect, String name) onSave,
    required Function() onCancel}) {
  showDialog(
      context: context,
      builder: (c) {
        return Material(
          color: Colors.transparent,
          child: SaveTipPopWidget(
            configuration: config,
            textureSource: texture,
            onSave: onSave,
            onCancel: onCancel,
          ),
        );
      });
}
