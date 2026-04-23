class StickerColorItem {
  final String type;
  final id;
  final bgimgId;
  final String name;
  final String image;
   String? typeIcon;

  StickerColorItem({
    required this.type,
    required this.id,
    required this.bgimgId,
    required this.name,
    required this.image,
     this.typeIcon,
  });

  // 从 JSON 转换为对象
  factory StickerColorItem.fromJson(Map<String, dynamic> json) {
    return StickerColorItem(
      type: json['type'] as String,
      id: json['id'],
      bgimgId: json['bgimgId'],
      name: json['name'] as String,
      image: json['image'] as String
    );
  }

  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'bgimgId': bgimgId,
      'name': name,
      'image': image
    };
  }
}
