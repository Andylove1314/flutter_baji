import 'package:flutter/widgets.dart';

enum RmbgType {
  rmbg,
  idphoto,
  color,
  bgColor,
  bgImage,
  addImage;

  // 获取枚举的字符串表示
  String get name {
    return toString().split('.').last;
  }

  // 静态方法：从字符串获取 EditorType
  static RmbgType? fromString(String? groupName) {
    if (groupName == null) return null;

    switch (groupName.toLowerCase()) {
      case 'crop':
        return RmbgType.rmbg;
      case 'colors':
        return RmbgType.idphoto;
      case 'filter':
        return RmbgType.color;
      case 'blur':
        return RmbgType.bgColor;
      case 'sticker':
        return RmbgType.bgImage;
      case 'text':
        return RmbgType.addImage;

      default:
        debugPrint('未找到匹配的 EditorType: $groupName');
        return null;
    }
  }
}
