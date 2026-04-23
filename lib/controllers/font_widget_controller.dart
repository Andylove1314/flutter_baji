import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../flutter_baji.dart';
import '../utils/base_util.dart';

class FontWidgetController extends GetxController {
  final isLoading = false.obs;
  final isCached = false.obs;
  final cachedPath = ''.obs;

  final _imageCacheManager = DefaultCacheManager();
  FontDetail fontDetail;

  FontWidgetController(this.fontDetail);

  @override
  void onInit() {
    _checkCache(fontDetail);
    super.onInit();
  }

  /// 缓存font, 离线资源不缓存
  Future<String> cacheFont(FontDetail fontDetail) async {
    isLoading.value = true;

    File ttfFile;
    if (fontDetail.ttfFrom == 0) {
      ttfFile = await BaseUtil.saveAssetToFile(fontDetail.file ?? '');
    } else if (fontDetail.ttfFrom == 1) {
      ttfFile = File(fontDetail.file ?? '');
    } else {
      String? cachedPath =
          await BaseUtil.fetchCacheFont(fontDetail.file ?? '', cache: true);
      ttfFile = File(cachedPath ?? '');
    }

    debugPrint('ttf download= ${ttfFile.path}');

    isCached.value = true;
    cachedPath.value = ttfFile.path;
    isLoading.value = false;
    return ttfFile.path;
  }

  Future<void> _checkCache(FontDetail fontDetail) async {
    debugPrint('online ttf = ${fontDetail.file}');
    String? path = await BaseUtil.fetchCacheFont(fontDetail.file ?? '');
    debugPrint('local ttf = $path');
    if (path != null) {
      isCached.value = true;
      cachedPath.value = path;
      isLoading.value = false;
    }
  }
}
