part of '../../flutter_baji.dart';

class BjColorData {
  var id;
  String? name;
  String? image;
  String? color;
  int? groupId;
  int? vip;

  bool get isVipFont => vip == 1;

  BjColorData({this.id, this.name, this.vip, this.groupId, this.image});

  /// fromJson 方法
  BjColorData.fromJson(Map json)
      : id = json['id'],
        name = json['name'] as String?,
        vip = json['vip'] as int?,
        color = json['color'],
        image = json['image'] as String?,
        groupId = json['groupId'] as int?;

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color'] = color;
    data['vip'] = vip;
    data['groupId'] = groupId;
    data['image'] = image;
    return data;
  }
}
