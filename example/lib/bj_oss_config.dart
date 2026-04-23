/// oss config
class BjOssConfig {
  String? bucket;
  String? endpoint;
  OssConfigSize? size;
  Credentials? credentials;
  String? key;
  String? type;

  BjOssConfig(
      {this.bucket,
      this.endpoint,
      this.size,
      this.credentials,
      this.key,
      this.type});

  ///火山云
  bool get isVolc => 'volc' == type;

  BjOssConfig.fromJson(dynamic json) {
    bucket = json['bucket'];
    endpoint = json['endpoint'];
    if (json['size'] != null) {
      size = OssConfigSize.fromJson(json['size']);
    }
    if (json['credentials'] != null) {
      credentials = Credentials.fromJson(json['credentials']);
    }
    key = json['key'];

    type = json['type'];
  }

  // tojson
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'endpoint': endpoint,
      'size': size?.toJson(),
      'credentials': credentials?.toJson(),
      'key': key,
      'type': type
    };
  }
}

class Credentials {
  final String accessKeyId;
  final String accessKeySecret;
  final String expiration;
  final String securityToken;

  Credentials({
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.expiration,
    required this.securityToken,
  });

  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      accessKeyId: json['accessKeyId'],
      accessKeySecret: json['accessKeySecret'],
      expiration: json['expiration'],
      securityToken: json['securityToken'],
    );
  }

  // to json
  Map<String, dynamic> toJson() => {
        'accessKeyId': accessKeyId,
        'accessKeySecret': accessKeySecret,
        'expiration': expiration,
        'securityToken': securityToken,
      };
}

class OssConfigSize {
  final int w_h;
  final int w_l;
  final int h_h;
  final int h_l;
  final int size;

  OssConfigSize({
    required this.w_h,
    required this.w_l,
    required this.h_h,
    required this.h_l,
    required this.size,
  });

  factory OssConfigSize.fromJson(dynamic json) {
    return OssConfigSize(
      w_h: json['w_h'],
      w_l: json['w_l'],
      h_h: json['h_h'],
      h_l: json['h_l'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'w_h': w_h,
      'w_l': w_l,
      'h_h': h_h,
      'h_l': h_l,
      'size': size,
    };
  }
}
