import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../flutter_baji.dart';

class FilterSourceController extends GetxController {
  /// 当前滤镜文件
  final filterData = Rx<DataItem?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  /// 导入滤镜底图
  Future<void> loadFiles(FilterDetail filterDetail) async {
    ImageCacheManager imageCacheManager = DefaultCacheManager();

    /// filter
    if (filterDetail.lutFrom == 0) {
      filterData.value = LutAssetDataItem(filterDetail.filterImage ?? '',
          metadata: LutMetadata(64, 8, 8, 8),
          disPlayName: filterDetail.name ?? '');
    } else if (filterDetail.lutFrom == 1) {
      filterData.value = LutFileDataItem(File(filterDetail.filterImage ?? ''),
          metadata: LutMetadata(64, 8, 8, 8),
          disPlayName: filterDetail.name ?? '');
    } else {
      File filterCache =
          await imageCacheManager.getSingleFile(filterDetail.filterImage ?? '');

      filterData.value = LutFileDataItem(filterCache,
          metadata: LutMetadata(64, 8, 8, 8),
          disPlayName: filterDetail.name ?? '');
    }
  }
}
