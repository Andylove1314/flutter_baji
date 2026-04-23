import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../flutter_baji.dart';

class ImageFumoActionPanelController extends GetxController {
  final fumos = <BjFumoData>[].obs;
  final selectedFumoIndex = (-1).obs;
  final selectedImage = ''.obs;
  final clickImage = false.obs;
  final _imageCacheManager = DefaultCacheManager();

  @override
  void onInit() {
    super.onInit();
    fetchFumoLists();
  }

  Future<void> fetchFumoLists() async {
    try {
      final result = await BajiUtil.fetchFumoLists();
      if (result != null) {
        fumos.value = result;
      }
    } catch (e) {
      debugPrint('获取覆膜失败: $e');
    }
  }

  Future<String?> checkCache(String url) async {
    FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(url);
    fileInfo ??= await _imageCacheManager.downloadFile(url);
    return fileInfo.file.path;
  }
}
