class BjUploadResp {
  /// 上传成功code
  static const successCode = 200;

  int? code;
  String? message;
  String? url;

  BjUploadResp(this.code, this.message, this.url);

  bool successs() {
    return code == successCode;
  }
}
