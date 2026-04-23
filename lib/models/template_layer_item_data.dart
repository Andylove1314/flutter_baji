//模版存储数据项
class TemplateLayerItemData {
  //贴纸位置大小
  double stickerScale = 1.0;
  List<double> stickerOffset = [0.0, 0.0];
  double stickerRadian = 0.0;

  /// 贴纸透明度
  double opacity = 1.0;

  TemplateLayerText? textSticker;
  TemplateLayerImage? imageSticker;

  var vipData;
  var isTarget;
  var isBig;
  var isFont;
  var isFlip;

  String name;

  TemplateLayerItemData(
      {this.stickerScale = 1.0,
      this.stickerOffset = const [0.0, 0.0],
      this.stickerRadian = 0.0,
      this.opacity = 1.0,
      this.textSticker,
      this.imageSticker,
      this.vipData = 0,
      this.isTarget = 0,
      this.isBig = 0,
      this.isFont = 0,
      this.isFlip = 0,
      this.name = ''});

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'stickerScale': stickerScale,
      'stickerOffset': stickerOffset,
      'stickerRadian': stickerRadian,
      'opacity': opacity,
      'textSticker': textSticker?.toJson(),
      'imageSticker': imageSticker?.toJson(),
      'vipData': vipData,
      'isTarget': isTarget,
      'isBig': isBig,
      'name': name,
      'isFont': isFont,
      'isFlip': isFlip,
    };
  }

  /// 从JSON创建对象
  factory TemplateLayerItemData.fromJson(Map<String, dynamic> json) {
    return TemplateLayerItemData()
      ..stickerScale = json['stickerScale']
      ..stickerOffset = (json['stickerOffset'] as List).cast<double>()
      ..stickerRadian = json['stickerRadian']
      ..opacity = json['opacity'] as double
      ..textSticker = json['textSticker'] != null
          ? TemplateLayerText.fromJson(
              json['textSticker'] as Map<String, dynamic>)
          : null
      ..imageSticker = json['imageSticker'] != null
          ? TemplateLayerImage.fromJson(
              json['imageSticker'] as Map<String, dynamic>)
          : null
      ..isTarget = json['isTarget']
      ..isBig = json['isBig']
      ..vipData = json['vipData']
      ..isFont = json['isFont']
      ..name = json['name']
      ..isFlip = json['isFlip'];
  }
}

/// 文字贴纸
class TemplateLayerText {
  /// 文字专用
  String text;
  String? fontUrl;
  String? color;
  int bold = 0;
  int italic = 0;
  int underline = 0;
  // 0 left 1 center 2 right
  int textAlign = 0;
  double worldSpace = 0.0;
  double lineSpace = 0.0;
  String? strokeColor;
  double curveRadius = 0.0;
  double strokeWidth = 1.0;

  TemplateLayerText({
    this.text = '点击输入文案',
    this.fontUrl,
    this.color,
    this.bold = 0,
    this.italic = 0,
    this.underline = 0,
    this.textAlign = 0,
    this.worldSpace = 0.0,
    this.lineSpace = 0.0,
    this.strokeColor,
    this.curveRadius = 0.0,
    this.strokeWidth = 1.0,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fontUrl': fontUrl,
      'color': color,
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'textAlign': textAlign,
      'worldSpace': worldSpace,
      'lineSpace': lineSpace,
      'strokeColor': strokeColor,
      'curveRadius': curveRadius,
      'strokeWidth': strokeWidth,
    };
  }

  /// 从JSON创建对象
  factory TemplateLayerText.fromJson(Map<String, dynamic> json) {
    return TemplateLayerText()
      ..text = json['text'] as String
      ..fontUrl = json['fontUrl'] as String?
      ..color = json['color'] as String?
      ..bold = json['bold'] as int
      ..italic = json['italic'] as int
      ..underline = json['underline'] as int
      ..textAlign = json['textAlign'] as int
      ..worldSpace = json['worldSpace'] as double
      ..lineSpace = json['lineSpace'] as double
      ..strokeColor = json['strokeColor'] as String?
      ..strokeWidth = json['strokeWidth'] as double
      ..curveRadius = json['curveRadius'] as double;
  }
}

/// 图片贴纸
class TemplateLayerImage {
  /// 图片地址
  String? stickerUrl;

  /// 图片颜色
  String? color;

  TemplateLayerImage({
    this.stickerUrl,
    this.color,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'stickerUrl': stickerUrl,
      'color': color,
    };
  }

  /// 从JSON创建对象
  factory TemplateLayerImage.fromJson(Map<String, dynamic> json) {
    return TemplateLayerImage()
      ..color = json['color'] as String?
      ..stickerUrl = json['stickerUrl'] as String?;
  }
}
