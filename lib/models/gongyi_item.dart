import 'craftsmanship_data.dart';

/// 工艺数据
class GyItem {
  String? gyPath;
  CraftsmanshipData? craftsmanshipData;

// 构造函数
  GyItem({this.gyPath, this.craftsmanshipData});

  Map toJson() {
    return {
      'gyPath': gyPath,
      'craftsmanshipData': craftsmanshipData?.toJson(),
    };
  }
}
