import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../flutter_baji.dart';

class ImageBgActionPanelController extends GetxController {
  final colors = <BjColorData>[].obs;
  final selectedColorIndex = (-1).obs;
  final selectedImage = ''.obs;
  final clickImage = false.obs;
  final clickTransparent = true.obs;
  final _imageCacheManager = DefaultCacheManager();

  @override
  void onInit() {
    super.onInit();
    fetchColors();
  }

  Future<void> fetchColors() async {
    try {
      final result = await BajiUtil.fetchBgColors();
      if (result != null) {
        colors.value = result;
      }
    } catch (e) {
      debugPrint('获取颜色失败: $e');
    }
  }

  void selectColor(int index) {
    if (index >= 0 && index < colors.length) {
      selectedColorIndex.value = index;
    }
  }

  Future<String?> checkCache(String url) async {
    FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(url);
    fileInfo ??= await _imageCacheManager.downloadFile(url);
    return fileInfo.file.path;
  }
}
