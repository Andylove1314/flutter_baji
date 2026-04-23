import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../utils/editor_type.dart';

class EditorHomeController extends GetxController {
  bool saved = false;
  final afterPath = ''.obs;

  Future<String> getSaveImagePath() async {
    saved = true;
    return afterPath.value;
  }

  @override
  void onInit() {
    super.onInit();
  }

  // 修改功能提示弹窗方法
  void showFeatureDialog(
      BuildContext context, FeatureDialogBuilder? featureDialogBuilder,
      {EditorType? groupType, String? subGroupId}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // 定义确认按钮的回调函数
        onConfirm() {
          Navigator.of(dialogContext).pop();

          toEditor(
            context, // 使用原始上下文
            groupType ?? EditorType.crop,
            subGroupId,
          );
        }

        return featureDialogBuilder?.call(dialogContext, onConfirm) ??
            AlertDialog(
              title: const Text(
                '新功能提示',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              content: const Text(
                '我们添加了新的编辑功能，立即体验？',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    '稍后再说',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    toEditor(
                      context, // 使用原始上下文
                      groupType ?? EditorType.crop,
                      subGroupId,
                    );
                  },
                  child: const Text(
                    '立即体验',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            );
      },
    );
  }

  Future<void> toEditor(BuildContext context, EditorType type,
      [String? subGroupId]) async {
    saved = false;
    if (type == EditorType.crop) {
      EditorUtil.goCropPage(context, afterPath.value);
    } else if (type == EditorType.colors) {
      BaseUtil.goColorsPage(context, afterPath.value, 0);
    } else if (type == EditorType.filter) {
      if (EditorUtil.filterList.isEmpty) {
        await EditorUtil.fetchFilterList(context);
      }
      final index = EditorUtil.filterList
          .indexWhere((element) => element.id.toString() == subGroupId);
      if (index != -1) {
        EditorUtil.goFilterPage(context, afterPath.value, index);
      } else {
        EditorUtil.goFilterPage(context, afterPath.value);
      }
    } else if (type == EditorType.sticker) {
      EditorUtil.goStickerPage(context, afterPath.value);
    } else if (type == EditorType.text) {
      EditorUtil.goTextPage(context, afterPath.value);
    } else if (type == EditorType.frame) {
      if (EditorUtil.frameList.isEmpty) {
        await EditorUtil.fetchFrameList(context);
      }
      final index = EditorUtil.frameList
          .indexWhere((element) => element.id.toString() == subGroupId);
      if (index != -1) {
        EditorUtil.goFramePage(context, afterPath.value, index);
      } else {
        EditorUtil.goFramePage(context, afterPath.value);
      }
    }
  }
}
