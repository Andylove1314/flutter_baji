import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/controllers/filter_source_controller.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:get/get.dart';
import '../../flutter_baji.dart';
import '../net_image.dart';

class FilterWidget extends StatelessWidget {
  FilterDetail filterDetail;

  Function(DataItem? item)? onSelect;

  FilterWidget({super.key, required this.filterDetail, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterSourceController(),
        tag: '${filterDetail.classId}_${filterDetail.id}');
    controller.loadFiles(filterDetail);
    return Obx(() {
      Widget child = BaseUtil.loadingWidget(isLight: false);

      if (controller.filterData.value != null) {
        child = _fetchSrc();
      }

      return SizedBox(
        height: 73,
        width: 60,
        child: GestureDetector(
          onTap: () {
            DataItem? current = controller.filterData.value;
            debugPrint(current?.disPlayName ?? '');
            onSelect?.call(current);
          },
          child: child,
        ),
      );
    });
  }

  Widget _fetchSrc() {
    if (filterDetail.imgFrom == 0) {
      return Image.asset(
        filterDetail.image ?? '',
        fit: BoxFit.cover,
      );
    } else if (filterDetail.imgFrom == 1) {
      return Image.file(
        File(filterDetail.image ?? ''),
        fit: BoxFit.cover,
      );
    }
    return NetImage(
      url: filterDetail.image ?? '',
      isLight: false,
    );
  }
}
