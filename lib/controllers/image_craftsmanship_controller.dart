import 'package:flutter/material.dart';
import 'package:flutter_baji/models/layer_data.dart';
import 'package:get/get.dart';

import '../models/craftsmanship_data.dart';

mixin ImageCraftsmanshipController on GetxController {
  final currentType = CraftsmanshipType.none.obs;

  // 获取分组后的图层数据
  List<List<LayerData>> _getStampingLayers(List<LayerData> layers) {
    Map<CraftsmanshipType, List<LayerData>> groupMap = {};

    // 分组
    for (var i = 0; i < layers.length; i++) {
      var layer = layers[i];
      if (layer.craftsmanshipData?.type != null &&
          layer.craftsmanshipData?.type != CraftsmanshipType.none) {
        if (!groupMap.containsKey(layer.craftsmanshipData?.type)) {
          groupMap[layer.craftsmanshipData!.type] = [];
        }
        groupMap[layer.craftsmanshipData!.type]!.add(layer);
      }
    }

    return groupMap.values.toList();
  }

  /// 图层分组
  Widget layerTypeGroup(List<LayerData> layerDatas,
      {required Null Function(
              List<LayerData> layerDatas, CraftsmanshipType currentType)
          onChangeGy}) {
    final stampingLayers = _getStampingLayers(layerDatas);
    final hasStampingLayer = stampingLayers.isNotEmpty;
    return Container(
      width: double.infinity, // 设置宽度为无穷大，使其水平填充父容器,
      height: 28,
      alignment: Alignment.center,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          GestureDetector(
            onTap: () {
              currentType.value = CraftsmanshipType.none;
              // 更新打印层显示状态
              for (var layer in layerDatas) {
                layer.shouldShow = true;
                layer.blackLayer = false;
              }
              onChangeGy(layerDatas, currentType.value);
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: currentType.value == CraftsmanshipType.none
                    ? Color(0xffFF1A5A)
                    : const Color(0xff666364),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '打印层',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (hasStampingLayer)
            ...stampingLayers.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final layers = entry.value;
              final type = layers.first.craftsmanshipData?.type;
              final name = layers.first.craftsmanshipData?.name;
              return Row(
                children: [
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      currentType.value = type!;
                      // 更新工艺层显示状态
                      for (var layer in layerDatas) {
                        layer.shouldShow =
                            layer.craftsmanshipData?.type == type;
                        layer.blackLayer =
                            layer.craftsmanshipData?.type == type;
                      }
                      onChangeGy(layerDatas, currentType.value);
                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: currentType.value == type
                            ?  Color(0xffFF1A5A)
                            : const Color(0xff666364),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
