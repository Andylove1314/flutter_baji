//工艺类型
import 'package:flutter_baji/flutter_baji.dart';

enum CraftsmanshipType { none, golden, silver, red, laser, uv, whiteInk }

/// 工艺数据
class CraftsmanshipData {
  String name;

  /// 烫 只能是合并一层，即所有图层只能选择一种烫
  bool isStamping;
  String typeIcon;
  CraftsmanshipType type;
  String? banner;

  CraftsmanshipData(
      {required this.name,
      required this.isStamping,
      required this.typeIcon,
      required this.type,
      this.banner});

  /// 工艺列表
  static List<CraftsmanshipData> craftsmanshipDatas = [
    CraftsmanshipData(
      name: "无工艺",
      isStamping: false,
      typeIcon: "craftsmanship_none".imageBjPng,
      type: CraftsmanshipType.none,
    ),
    CraftsmanshipData(
      name: "烫金",
      isStamping: true,
      typeIcon: "craftsmanship_golden".imageBjPng,
      banner: "craftsmanship_golden_banner".imageBjPng,
      type: CraftsmanshipType.golden,
    ),
    // CraftsmanshipData(
    //   name: "烫银",
    //   isStamping: true,
    //   typeIcon: "craftsmanship_silver".imagePng,
    //   banner: "craftsmanship_silver_banner".imagePng,
    //   type: CraftsmanshipType.silver,
    // ),
    // CraftsmanshipData(
    //   name: "烫红",
    //   isStamping: true,
    //   typeIcon: "craftsmanship_red".imagePng,
    //   banner: "craftsmanship_red_banner".imagePng,
    //   type: CraftsmanshipType.red,
    // ),
    // CraftsmanshipData(
    //   name: "烫镭射",
    //   isStamping: true,
    //   typeIcon: "craftsmanship_laser".imagePng,
    //   banner: "craftsmanship_laser_banner".imagePng,
    //   type: CraftsmanshipType.laser,
    // ),
    CraftsmanshipData(
      name: "UV",
      isStamping: false,
      typeIcon: "craftsmanship_uv".imageBjPng,
      banner: "craftsmanship_uv_banner".imageBjPng,
      type: CraftsmanshipType.uv,
    ),
    CraftsmanshipData(
      name: "白墨",
      isStamping: false,
      typeIcon: "craftsmanship_white_ink".imageBjPng,
      banner: "craftsmanship_white_ink_banner".imageBjPng,
      type: CraftsmanshipType.whiteInk,
    ),
  ];

  Map toJson() {
    return {
      'name': name,
      'isStamping': isStamping,
      'typeIcon': typeIcon,
      'type': type.name,
      'banner': banner,
    };
  }
}
