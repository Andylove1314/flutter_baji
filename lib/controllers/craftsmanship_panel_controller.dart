import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_baji/models/badge_config.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';
import '../utils/base_util.dart';

class CraftsmanshipPanelController extends GetxController {
  var currentLayerIndex = 0.obs;
  var craftsmanshipActionIndex = 0.obs;

  ///覆膜相关
  List<BjFumoData> fumos = [];
  final selectedFumoIndex = (-1).obs;

  final _imageCacheManager = DefaultCacheManager();

  Function(List<BjFumoData> fumoDatas, BjFumoData? data, ImageInfo? info)?
      onFumoSelect;
  bool isCircle = false;

  /// 选取监听
  void addlFumoListener(
      bool isCircle,
      Function(List<BjFumoData> fumoDatas, BjFumoData? data, ImageInfo? info)?
          onFumoSelect) {
    this.onFumoSelect = onFumoSelect;
    this.isCircle = isCircle;
  }

  /// 保存工艺单图层
  Future<String?> saveBjGy(
      GlobalKey key, bool isCircle, ConfigSize size, String name) async {
    final image = await BaseUtil.captureImageWithKey(key, Get.pixelRatio);

    final blackImage = await BajiUtil.blackImages(image);

    if (blackImage == null) return null;

    final cropedImage = await BajiUtil.cropImage(
        blackImage,
        size.bjPreMarginLeft,
        size.bjPreMarginRight,
        size.ratio,
        Get.pixelRatio,
        false,
        isCircle: isCircle,
        radius: size.radius);

    final path = await BaseUtil.createNewSize(cropedImage, size.bjWidthPixl,
        size.bjHeightPixl, size.extPixl, 'badge_${size.size}_$name');
    return path;
  }

  Future<void> _fetchFumoLists() async {
    try {
      final result = await BajiUtil.fetchFumoLists();
      if (result != null) {
        fumos = result;
        selectedFumoIndex.value = 0;
      }
    } catch (e) {
      debugPrint('获取覆膜失败: $e');
    }
  }

  Future<String?> _checkCache(String url) async {
    FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(url);
    fileInfo ??= await _imageCacheManager.downloadFile(url);
    return fileInfo.file.path;
  }

  Future<void> _loadFumoImageInfo(BjFumoData fumoData) async {
    String? path = await _checkCache(
        isCircle ? fumoData.imageCircle ?? '' : fumoData.imageSquare ?? '');

    if (path == null) {
      return;
    }

    final image = Image.file(File(path)).image;
    image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      onFumoSelect?.call(fumos, fumoData, info);
    }));
  }

  @override
  void onInit() {
    ever(selectedFumoIndex, (value) {
      if (value >= 0) {
        _loadFumoImageInfo(fumos[value]);
      }
    });
    _fetchFumoLists();
    super.onInit();
  }
}
