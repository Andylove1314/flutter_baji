import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/rmbg_sure_controller.dart';
import '../flutter_baji.dart';
import '../utils/base_util.dart';

class RmbgSurePage extends StatelessWidget {
  final controller = Get.put(RmbgSureController());

  final String orignal;

  final String title;

  RmbgSurePage({
    super.key,
    required this.orignal,
    required this.title,
  }) {
    controller.afterPath.value = orignal;
    controller.fetchCardWh(orignal);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.back(result: controller.afterPath.value);
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              height: double.infinity,
              width: double.infinity,
              'pic_bg_qbj'.imageRmbgJpg,
              fit: BoxFit.fill,
            ),
            Obx(() => Image.file(File(controller.afterPath.value))),
            Positioned(top: 0, left: 0, right: 0, child: _bar(context)),
            Positioned(bottom: 0, left: 0, right: 0, child: _action(context)),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      shadowColor: const Color(0xff19191A).withOpacity(0.1),
      elevation: 2,
    );
  }

  Widget _action(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32, top: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: () async {
                  String? np = await EditorUtil.goCropPage(
                      context, controller.afterPath.value);
                  if (np != null) {
                    controller.afterPath.value = np;
                  }
                },
                icon: Image.asset(
                  'icon_caijian@3x'.imageRmbgPng,
                  width: 24,
                )).marginOnly(left: 37),
          ),
          Align(
            alignment: Alignment.center,
            child: FilledButton(
                onPressed: () async {
                  BaseUtil.showLoadingdialog(context);
                  String? newUrl =
                      await RmbgUtil.aiRemoveBg(controller.afterPath.value);
                  if (newUrl != null) {
                    BaseUtil.cacheImage(newUrl).then((newPath) {
                      BaseUtil.hideLoadingdialog();
                      debugPrint('去背景后path $newPath');
                      if (newPath != null) {
                        controller.afterPath.value = newPath;
                        Get.back(result: controller.afterPath.value);
                      }
                    });
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all( Color(0xffFF1A5A)),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        vertical: 9, horizontal: 30)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // 设置圆角
                      ),
                    )),
                child: const Text(
                  '去背景',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                )),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
                onTap: () async {
                  Get.back(result: controller.afterPath.value);
                },
                child: const Text(
                  '直接添加',
                  style: TextStyle(
                      color: Color(0xff19191A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                )).marginOnly(right: 22),
          )
        ],
      ),
    );
  }

  /// 去背景
  void _removeBg(BuildContext context) {
    BaseUtil.showLoadingdialog(context, msg: '去背景中...');
    RmbgUtil.aiRemoveBg(orignal).then((newUrl) {
      if (newUrl != null) {
        debugPrint('去背景 $newUrl');
        BaseUtil.cacheImage(newUrl).then((newPath) {
          debugPrint('去背景后path $newPath');
          if (newPath != null) {
            controller.afterPath.value = newPath;
          }
          BaseUtil.hideLoadingdialog();
        });
      }
    });
  }
}
