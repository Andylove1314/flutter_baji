part of '../../flutter_baji.dart';

class StickerData {
  var id;
  String? groupName;
  String? groupImage;
  int? status;
  int? big; // 1 big
  List<StickDetail>? list;
  int? vip;
  var imgFrom = 2; // 0 asset, 1 file, 2 url

  bool get isVipGroup => vip == 1;
  bool get isBigGroup => big == 1;

  StickerData({
    this.id,
    this.groupName,
    this.groupImage,
    this.status,
    this.list,
    this.vip,
    this.big,
  });

  /// fromJson 方法
  StickerData.fromJson(Map json) {
    if (json.isNotEmpty) {
      id = json['id'] as int?;
      big = json['big'] as int?;
      groupName = json['groupName'] as String?;
      groupImage = json['groupImage'] as String?;
      status = json['status'] as int?;
      vip = json['vip'] as int?;
      list = (json['list'] as List<dynamic>?)
          ?.map((e) => StickDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['big'] = big;
    data['groupName'] = groupName;
    data['groupImage'] = groupImage;
    data['status'] = status;
    data['vip'] = vip;
    if (list != null) {
      data['list'] = list?.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}

class StickDetail {
  var id;
  String? name;
  int? classId;
  int? vip;
  int? status;
  String? className;
  String? image;
  int? groupId;
  var color;
  var imgFrom = 2; // 0 asset, 1 file, 2 url
  List<StickerColorItem>? gongyi; // 添加工艺参数

  bool get isVipSticker => vip == 1;

  StickDetail(
      {this.id,
      this.name,
      this.classId,
      this.vip,
      this.status,
      this.className,
      this.image,
      this.groupId,
      this.color,
      this.gongyi}); // 在构造函数中添加参数

  /// fromJson 方法
  StickDetail.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] as String?,
        classId = json['classId'] as int?,
        vip = json['vip'] as int?,
        status = json['status'] as int?,
        className = json['className'] as String?,
        image = json['image'] as String?,
        color = json['color'],
        groupId = json['groupId'] as int? {
    gongyi = (json['gongyi'] as List<dynamic>?)
        ?.map((e) => StickerColorItem.fromJson(e as Map<String, dynamic>))
        .toList(); // 添加 fromJson 解析
  }

  /// toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['classId'] = classId;
    data['vip'] = vip;
    data['status'] = status;
    data['className'] = className;
    data['image'] = image;
    data['groupId'] = groupId;
    data['color'] = color;
    if (gongyi != null) {
      data['gongyi'] = gongyi?.map((v) => v.toJson()).toList(); // 添加 toJson 序列化
    }
    return data;
  }
}
