part of '../../flutter_baji.dart';

class RmbgbgData {
  var id;
  var name;
  String? image;
  var vip;

  bool get isVipBg => vip == 1;

  RmbgbgData({this.id, this.name, this.vip, this.image});

  /// fromJson 方法
  RmbgbgData.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        vip = json['vip'],
        image = json['image'] as String?;

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['vip'] = vip;
    data['image'] = image;
    return data;
  }
}
