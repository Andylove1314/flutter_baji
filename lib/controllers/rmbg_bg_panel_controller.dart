import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../flutter_baji.dart';

class RmbgBgPanelController extends GetxController {
  final imageBgs = <RmbgbgData>[].obs;
  final selectedImage = ''.obs;
  final _imageCacheManager = DefaultCacheManager();

  @override
  void onInit() {
    super.onInit();
    fetchColors();
  }

  Future<void> fetchColors() async {
    try {
      final result = await RmbgUtil.fetchRmbgDatas();
      if (result != null) {
        imageBgs.value = result;
      }
    } catch (e) {
      debugPrint('获取背景图失败: $e');
    }
  }

  Future<String?> checkCache(String url) async {
    FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(url);
    fileInfo ??= await _imageCacheManager.downloadFile(url);
    return fileInfo.file.path;
  }
}
