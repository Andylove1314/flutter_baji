import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../utils/base_util.dart';

class StickerWidgetController extends GetxController {
  final isLoading = false.obs;
  final isCached = false.obs;
  final cachedPath = ''.obs;

  final _imageCacheManager = DefaultCacheManager();
  StickDetail stickDetail;

  StickerWidgetController(this.stickDetail);

  @override
  void onInit() {
    checkCache(stickDetail);
    super.onInit();
  }

  /// 缓存sticker, 离线资源不缓存
  Future<String> cacheSticker(StickDetail stickDetail) async {
    isLoading.value = true;

    try {
      File img;
      if (stickDetail.imgFrom == 0) {
        img = await BaseUtil.saveAssetToFile(stickDetail.image ?? '');
      } else if (stickDetail.imgFrom == 0) {
        img = File(stickDetail.image ?? '');
      } else {
        FileInfo imgInfo =
            await _imageCacheManager.downloadFile(stickDetail.image ?? '');
        img = imgInfo.file;
      }

      cachedPath.value = img.path;
      isCached.value = true;
      return img.path;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkCache(StickDetail stickDetail) async {
    FileInfo? fileInfo =
        await _imageCacheManager.getFileFromCache('${stickDetail.image}');
    if (fileInfo != null) {
      cachedPath.value = fileInfo.file.path;
      isCached.value = true;
    }
  }
}
