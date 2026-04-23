part of '../../flutter_baji.dart';

class BjFumoData {
  var id;
  String? name;
  String? imageCircle;
  String? imageSquare;
  String? image;
  int inStampingOrUv;

  /// fromJson 方法
  BjFumoData.fromJson(Map json)
      : id = json['id'],
        name = json['name'] as String?,
        imageCircle = json['imageCircle'] as String?,
        imageSquare = json['imageSquare'] as String?,
        inStampingOrUv = json['inStampingOrUv'],
        image = json['image'] as String?;

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['imageSquare'] = imageSquare;
    data['imageCircle'] = imageCircle;
    data['image'] = image;
    data['inStampingOrUv'] = inStampingOrUv;
    return data;
  }
}
