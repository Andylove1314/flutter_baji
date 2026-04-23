class BadgeConfig {
  // 形状类型
  final bool isCircle;

  // 尺寸描述
  final String name;

  final List<ConfigSize> configSizes;

  const BadgeConfig({
    required this.isCircle,
    required this.configSizes,
    required this.name,
  });

  // 预设尺寸列表
  static List<BadgeConfig> presetSizes = [];

  // 预设尺寸列表
  static List<BadgeConfig> bajiSizes = [
    const BadgeConfig(isCircle: true, name: '圆形吧唧', configSizes: [
      ConfigSize(
          size: '58x58mm',
          ratio: 1.0,
          bjWidthPixl: 803,
          bjHeightPixl: 803,
          bjBloodLineWidthPixl: 118,
          description: '常规尺寸',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 95),
      ConfigSize(
          size: '65x65mm',
          ratio: 1.0,
          bjWidthPixl: 886,
          bjHeightPixl: 886,
          bjBloodLineWidthPixl: 118,
          description: '迷你尺寸',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 0),
      ConfigSize(
          size: '75x75mm',
          ratio: 1.0,
          bjWidthPixl: 1004,
          bjHeightPixl: 1004,
          bjBloodLineWidthPixl: 118,
          description: '适合复杂图层',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 0),
    ]),
    const BadgeConfig(isCircle: false, name: '方形吧唧', configSizes: [
      ConfigSize(
          size: '50x50mm',
          ratio: 1.0,
          bjWidthPixl: 709,
          bjHeightPixl: 709,
          bjBloodLineWidthPixl: 118,
          description: '常规尺寸',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 0),
      ConfigSize(
          size: '55x55mm',
          ratio: 1.0,
          bjWidthPixl: 768,
          bjHeightPixl: 768,
          bjBloodLineWidthPixl: 118,
          description: '迷你尺寸',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 0),
      ConfigSize(
          size: '80x80mm',
          ratio: 1.0,
          bjWidthPixl: 1063,
          bjHeightPixl: 1063,
          bjBloodLineWidthPixl: 118,
          description: '适合复杂图层',
          bjPreMarginLeft: 10.0,
          bjPreMarginRight: 10.0,
          radius: 20.0,
          extPixl: 0),
    ])
  ];

  // 预设小卡尺寸列表
  static List<BadgeConfig> xiaokaSizes = const [
    BadgeConfig(
        isCircle: false,
        configSizes: [
          ConfigSize(
              size: '63x88mm',
              ratio: 0.73,
              bjWidthPixl: 862,
              bjHeightPixl: 1157,
              bjBloodLineWidthPixl: 118,
              description: '常规尺寸',
              bjPreMarginLeft: 35.0,
              bjPreMarginRight: 35.0,
              radius: 10.0,
              extPixl: 0),
          ConfigSize(
              size: '57x89mm',
              ratio: 0.64,
              bjWidthPixl: 791,
              bjHeightPixl: 1169,
              bjBloodLineWidthPixl: 118,
              description: '常规尺寸',
              bjPreMarginLeft: 35.0,
              bjPreMarginRight: 35.0,
              radius: 10.0,
              extPixl: 0),
        ],
        name: '小卡'),
  ];
}

class ConfigSize {
  // 尺寸类型（58x58mm, 63x88mm, 57x89mm）
  final String size;
  final int bjWidthPixl;
  final int bjHeightPixl;
  final int bjBloodLineWidthPixl;

  final double bjPreMarginLeft;
  final double bjPreMarginRight;

  // 尺寸比例（58mm/58mm, 63mm/88mm, 57mm/89mm）
  // 用于计算尺寸
  // 58mm/58mm = 1
  // 63mm/88mm = 0.73
  // 57mm/89mm = 0.64
  final double ratio;
  final String description;
  final double radius;

  final int extPixl;

  const ConfigSize(
      {required this.size,
      required this.ratio,
      required this.description,
      required this.bjWidthPixl,
      required this.bjHeightPixl,
      required this.bjBloodLineWidthPixl,
      required this.bjPreMarginLeft,
      required this.bjPreMarginRight,
      required this.radius,
      required this.extPixl});

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'bjWidthPixl': bjWidthPixl,
      'bjHeightPixl': bjHeightPixl,
      'bjBloodLineWidthPixl': bjBloodLineWidthPixl,
      'bjPreMarginLeft': bjPreMarginLeft,
      'bjPreMarginRight': bjPreMarginRight,
      'ratio': ratio,
      'description': description,
      'radius': radius,
      'extPixl': extPixl,
    };
  }

  /// 从JSON创建对象
  factory ConfigSize.fromJson(Map<String, dynamic> json) {
    return ConfigSize(
      size: json['size'] as String,
      bjWidthPixl: json['bjWidthPixl'] as int,
      bjHeightPixl: json['bjHeightPixl'] as int,
      bjBloodLineWidthPixl: json['bjBloodLineWidthPixl'] as int,
      bjPreMarginLeft: json['bjPreMarginLeft'] as double,
      bjPreMarginRight: json['bjPreMarginRight'] as double,
      ratio: json['ratio'] as double,
      description: json['description'] as String,
      radius: json['radius'] as double,
      extPixl: json['extPixl'] as int,
    );
  }
}
