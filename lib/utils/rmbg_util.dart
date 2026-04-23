part of '../../flutter_baji.dart';

class RmbgUtil {
  static RmbgType? rmbgType;

  /// 业务回调
  static IdphotoCallback? _idphotoCallback;
  static SaveRmbgCallback? _saveCallback;
  static AiRmbgCallback? _aiRemoveBgCallback;
  static FetchrmbgDataCallback? _fetchRmbgDataCallback;

  /// 去背景页面
  static void goRmbg(
    BuildContext context, {
    required String orignal,
    required String title,
    RmbgType? type,
    IdphotoCallback? idphotoCb,
    SaveRmbgCallback? saveCb,
    AiRmbgCallback? aiRemoveBgCb,
    FetchrmbgDataCallback? fetchRmbgDataCb,
  }) async {
    _idphotoCallback = idphotoCb;
    _aiRemoveBgCallback = aiRemoveBgCb;
    _saveCallback = saveCb;
    _fetchRmbgDataCallback = fetchRmbgDataCb;

    rmbgType = type;

    if (RmbgType.rmbg == type) {
      goRmActionPage(context, orignal);
      return;
    }
    if (RmbgType.idphoto == type) {
      goIdphoto(context, orignal);
      return;
    }
    if (RmbgType.color == type) {
      BaseUtil.goColorsPage(context, orignal, 1);
      return;
    }

    Get.to(() => RmbgHomePage(
          orignal: orignal,
          title: title,
        ));
  }

  static Future<bool?> goRmActionPage(BuildContext context, String path) async {
    Get.to(
        () => RmbgActionPage(
              orignal: path,
              title: '去背景',
            ),
        duration: BaseUtil.transDur,
        transition: Transition.size);
  }

  static Future<String?>? goSurepage(String path) async {
    return Get.to(() => RmbgSurePage(
          orignal: path,
          title: '去背景',
        ));
  }

  static Future<bool?> goIdphoto(BuildContext context, String path) async {
    return _idphotoCallback?.call(context, path);
  }

  static Future<bool?> saveImage(BuildContext context, String path) async {
    return _saveCallback?.call(context, path);
  }

  static Future<String?> aiRemoveBg(String path) async {
    return _aiRemoveBgCallback?.call(path);
  }

  static Future<List<RmbgbgData>?> fetchRmbgDatas() async {
    return _fetchRmbgDataCallback?.call();
  }

  /// 刷新首页数据
  static void refreshHomeLayerEffect(String? newPath) {
    if (Get.isRegistered<RmbgHomeController>()) {
      Get.find<RmbgHomeController>()
          .lindiController
          .selectedFlagData
          .stickerPath
          .value = newPath;
      Get.find<RmbgHomeController>().currentLayer.value?.stickerPath.value =
          newPath ?? '';
    }
  }

  /// clean tmp
  static void clearTmpObject() {
    _idphotoCallback = null;
    _saveCallback = null;
    _aiRemoveBgCallback = null;
    _fetchRmbgDataCallback = null;
    rmbgType == null;

    BaseUtil.closeCallbacks();
  }
}
