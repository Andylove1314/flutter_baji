import 'package:get/get.dart';

import 'badge_config.dart';
import 'template_layer_item_data.dart';

class TemplateData {
  /// 0 圆形 1 矩形
  var type = 0;

  ConfigSize? configSize;

  List<String> bgColors;

  List<TemplateLayerItemData> layerItems = [];

  String? makerName;

  TemplateData({
    this.type = 0,
    this.configSize,
    this.layerItems = const [],
    this.bgColors = const [],
    this.makerName,
  }) {
    makerName ??= '';
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'makerName': makerName,
      'type': type,
      'configSize': configSize?.toJson(),
      'layerItems': layerItems.map((item) => item.toJson()).toList(),
      'bgColors': bgColors.map((item) => item).toList(),
    };
  }

  /// 从JSON创建对象
  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData()
      ..makerName = json['makerName']
      ..type = json['type']
      ..configSize = json['configSize'] != null
          ? ConfigSize.fromJson(json['configSize'] as Map<String, dynamic>)
          : null
      ..bgColors = json['bgColors'] == null
          ? []
          : (json['bgColors'] as List).map((item) => item as String).toList()
      ..layerItems = (json['layerItems'] as List)
          .map((item) =>
              TemplateLayerItemData.fromJson(item as Map<String, dynamic>))
          .toList();
  }
}
