class ZhoubianConfig {
  final String size;

  final int cardWidthPixl;
  final int cardHeightPixl;
  final double ratio;
  final String description;

  // 预设尺寸列表
  static List<ZhoubianConfig> presetSizes = [
    const ZhoubianConfig(
        size: '1080*1920',
        ratio: 9 / 16,
        description: '9:16',
        cardWidthPixl: 1080,
        cardHeightPixl: 1920),
  ];

  const ZhoubianConfig({
    required this.size,
    required this.ratio,
    required this.description,
    required this.cardWidthPixl,
    required this.cardHeightPixl,
  });
}
