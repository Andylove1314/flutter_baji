part of '../../flutter_baji.dart';

class BjTextureData {
  var id;
  String? groupName;
  int? status;
  List<BjTextureDetail>? list;

  BjTextureData({this.id, this.groupName, this.status, this.list});

  /// fromJson 方法
  BjTextureData.fromJson(Map json) {
    if (json.isNotEmpty) {
      id = json['id'];
      groupName = json['groupName'] as String?;
      status = json['status'] as int?;
      list = (json['list'] as List<dynamic>?)
          ?.map((e) => BjTextureDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['groupName'] = groupName;
    data['status'] = status;
    if (list != null) {
      data['list'] = list?.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}

class BjTextureDetail {
  var id;
  String? name;
  int? classId;
  int? vip;
  int? status;
  String? className;
  String? file;
  String? image;
  int? groupId;
  var imgFrom = 2;// 0 asset, 1 file, 2 url
  var ttfFrom = 2;// 0 asset, 1 file, 2 url

  bool get isVipFont => vip == 1;

  BjTextureDetail(
      {this.id,
        this.name,
        this.classId,
        this.vip,
        this.status,
        this.className,
        this.file,
        this.groupId,
      this.image});

  /// fromJson 方法
  BjTextureDetail.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] as String?,
        classId = json['classId'] as int?,
        vip = json['vip'] as int?,
        status = json['status'] as int?,
        className = json['className'] as String?,
        file = json['file'] as String?,
        image = json['image'] as String?,
        groupId = json['groupId'] as int?;

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['classId'] = classId;
    data['vip'] = vip;
    data['status'] = status;
    data['className'] = className;
    data['file'] = file;
    data['groupId'] = groupId;
    data['image'] = image;
    return data;
  }
}
