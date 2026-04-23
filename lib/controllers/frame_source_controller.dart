import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';

class FrameSourceController extends GetxController {
  final ImageCacheManager imageCacheManager = DefaultCacheManager();

  final framePath = ''.obs;

  final frameStatus = (-1).obs;

  /// 缓存frame, 离线资源不缓存
  Future<String> cacheFrame(FrameDetail frameDetail) async {
    frameStatus.value = 0;
    File img;
    if (frameDetail.imgFrom == 0) {
      img = await EditorUtil.saveAssetToFile(frameDetail.image ?? '');
    } else if (frameDetail.imgFrom == 0) {
      img = File(frameDetail.image ?? '');
    } else {
      FileInfo imgInfo =
          await imageCacheManager.downloadFile(frameDetail.image ?? '');
      img = imgInfo.file;
    }

    framePath.value = img.path;

    frameStatus.value = 1;
    return img.path;
  }

  Future<void> checkCache(FrameDetail frameDetail) async {
    FileInfo? fileInfo =
        await imageCacheManager.getFileFromCache('${frameDetail.image}');
    if (fileInfo != null) {
      framePath.value = fileInfo.file.path;
      frameStatus.value = 1;
    }
  }
}
