import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gpu_filters_interface/flutter_gpu_filters_interface.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../callbacks/callback.dart';
import '../callbacks/callback_bj.dart';
import '../flutter_baji.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import '../pages/filter_colors_page.dart';
import 'package:path/path.dart' as path;

class BaseUtil {
  ///效果临时目录
  static const _tmpEffectDir = '/tmpEffectDir';

  /// 页面切换动画
  static Duration get transDur => const Duration(milliseconds: 200);

  static final _imageCacheManager = DefaultCacheManager();

  static LogEventCallback? _logEventCallback;
  static FetchImageCallback? _pickImage;
  static Membership? _membership;
  static VipBuyCallback? _vipBuyCallback;
  static FetchStickerCallback? _stickerCallback;
  static FetchFontCallback? _fontCallback;
  static LoadingWidgetCallback? _loadingWidgetCallback;
  static ShowLoadingCallback? _showLoadingCallback;
  static HideLoadingCallback? _hideLoadingCallback;
  static ToastActionCallback? _toastActionCallback;
  static LoginCheckCallback? _loginCheckCallback;
  static DeviceNameCallback? _deviceNameCallback;
  static SaveEffectCallback? _saveEffectCallback;
  static DeleteEffectCallback? _deleteEffectCallback;
  static EffectsCallback? _effectsCallback;

  static configCallback({
    required FetchImageCallback pickImage,
    required Membership membership,
    required FetchStickerCallback stickerCallback,
    required FetchFontCallback fontCallback,
    required LoadingWidgetCallback loadingWidgetCallback,
    required ToastActionCallback toastActionCallback,
    required VipBuyCallback vipBuyCallback,
    required LoginCheckCallback loginCheckCallback,
    required ShowLoadingCallback showLoadingCallback,
    required HideLoadingCallback hideLoadingCallback,
    required LogEventCallback logEventCallback,
    SaveEffectCallback? saveEffectCb,
    DeleteEffectCallback? deleteEffectCb,
    EffectsCallback? effectsCb,
    DeviceNameCallback? deviceNameCallback,
  }) {
    _logEventCallback = logEventCallback;
    _pickImage = pickImage;
    _membership = membership;
    _stickerCallback = stickerCallback;
    _fontCallback = fontCallback;
    _loadingWidgetCallback = loadingWidgetCallback;
    _toastActionCallback = toastActionCallback;
    _vipBuyCallback = vipBuyCallback;
    _loginCheckCallback = loginCheckCallback;
    _showLoadingCallback = showLoadingCallback;
    _hideLoadingCallback = hideLoadingCallback;
    _deviceNameCallback = deviceNameCallback;
    _saveEffectCallback = saveEffectCb;
    _deleteEffectCallback = deleteEffectCb;
    _effectsCallback = effectsCb;
    _registerMultGlsl();
  }

  static Future<void> logEvent(
    String name, {
    Map<String, dynamic>? params,
  }) async {
    _logEventCallback?.call(name, params: params);
  }

  /// 调色 action type 0 编辑，1 是 去背景
  static void goColorsPage(BuildContext context, String afterPath, int type) {
    Get.to(
      () => FilterColorsPage(afterPath: afterPath, type: type),
      duration: transDur,
      transition: Transition.size,
    );
  }

  static Future<String?>? pickImage() {
    return _pickImage?.call();
  }

  static bool isMember() {
    return _membership?.call() ?? false;
  }

  static Future<bool?>? isLogin() {
    return _loginCheckCallback?.call();
  }

  static Future<void> goVipBuy() async {
    bool isLogined = (await isLogin()) ?? true;
    if (isLogined) {
      _vipBuyCallback?.call();
    } else {
      debugPrint('请先登录！');
    }
  }

  static Future<String>? fetchDeviceName() {
    return _deviceNameCallback?.call();
  }

  /// type 0 bj, 1 editor
  static Future<List<StickerData>?> fetchStickers(int type) async {
    return _stickerCallback?.call(type);
  }

  /// type 0 bj, 1 editor
  static Future<List<FontsData>?> fetchFonts(int type) async {
    return _fontCallback?.call(type);
  }

  /// 保存配方 type 0 编辑 1 去背景
  static Future<bool?> saveColorEffectParam(
    int type,
    List<ConfigurationParameter> params,
    String path,
    String name,
  ) async {
    // 创建一个 Map 用于存储参数
    Map<String, dynamic> paramMap = {};
    for (var param in params) {
      paramMap[param.name] = (param as NumberParameter).value * 1.0;
    }

    return await _saveEffectCallback?.call(
      type,
      EffectData(name: name, path: path, params: jsonEncode(paramMap)),
    );
  }

  /// 获取配方列表
  static Future<List<EffectData>> fetchSavedParamList(
    int type,
    int page,
  ) async {
    var effects = await _effectsCallback?.call(type, page) ?? [];

    return effects;
  }

  ///删除配方
  static Future<bool?> deleteEffect(int type, id) async {
    return await _deleteEffectCallback?.call(type, id);
  }

  /// loading widget
  static Widget loadingWidget({
    bool isLight = false,
    double size = 20.0,
    double stroke = 2.0,
  }) {
    return Center(
      child:
          _loadingWidgetCallback?.call(isLight, size, stroke) ??
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(strokeWidth: stroke),
          ),
    );
  }

  static void showLoadingdialog(BuildContext context, {String? msg}) {
    if (_showLoadingCallback == null) {
      _showLoadingPop(context, msg);
      return;
    }
    _showLoadingCallback?.call(context, msg: msg);
  }

  /// 展示默认loading pop
  static void _showLoadingPop(BuildContext context, String? msg) {
    Get.dialog(
      barrierDismissible: false,
      Center(
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              if (msg != null)
                Material(
                  color: Colors.transparent,
                  child: Text(
                    msg,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingdialog() {
    if (_hideLoadingCallback == null) {
      Get.back();
      return;
    }
    _hideLoadingCallback?.call();
  }

  static void showToast(String msg) {
    _toastActionCallback?.call(msg);
  }

  static void closeCallbacks() {
    _logEventCallback = null;
    _pickImage = null;
    _membership = null;
    _vipBuyCallback = null;
    _stickerCallback = null;
    _fontCallback = null;
    _loadingWidgetCallback = null;
    _toastActionCallback = null;
    _loginCheckCallback = null;
    _hideLoadingCallback = null;
    _showLoadingCallback = null;
    _deviceNameCallback = null;
    _saveEffectCallback = null;
    _deleteEffectCallback = null;
    _effectsCallback = null;
  }

  /// 修改尺寸
  static Future<String?> createNewSize(
    ui.Image image,
    int widthPix,
    int heightPix,
    int extPix,
    String fileName, {
    bool isJpg = false,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;

      // 计算新的画布尺寸
      final finalWidth = widthPix + extPix;
      final finalHeight = heightPix + extPix;

      // 计算居中位置
      final left = extPix.toDouble() / 2;
      final top = extPix.toDouble() / 2;

      // 在扩展的画布上绘制图片
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(left, top, widthPix.toDouble(), heightPix.toDouble()),
        paint,
      );

      // 生成最终尺寸的图片
      final scaledImage = await recorder.endRecording().toImage(
        finalWidth,
        finalHeight,
      );
      final byteData = await scaledImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/nwdn_${fileName}_${DateTime.now().millisecondsSinceEpoch}${isJpg ? '.jpg' : '.png'}',
        );
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('保存失败: $e');
      return null;
    }
  }

  /// 截图
  static Future<dynamic> captureImageWithKey(
    GlobalKey capKey,
    double pixelRatio, {
    bool saveFile = false,
  }) async {
    try {
      final boundary =
          capKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final highQualityPixelRatio = pixelRatio * 2;
      final image = await boundary.toImage(pixelRatio: highQualityPixelRatio);

      if (saveFile) {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/nwdn_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await file.writeAsBytes(byteData.buffer.asUint8List());
          return file.path;
        }
      }

      return image;
    } catch (e) {
      debugPrint('截图失败: $e');
      return null;
    }
  }

  /// 将 ui.Image 转换为 File
  static Future<String> image2File(
    ui.Image imageSrc, {
    String ext = '.jpg',
  }) async {
    // 获取临时目录用于存储图片
    final tempDir = await getTemporaryDirectory();
    final imageFileName =
        'nwdn_image_${DateTime.now().millisecondsSinceEpoch}$ext';
    final imageFilePath = '${tempDir.path}/$imageFileName';
    // 将 ui.Image 转换为 ByteData
    final byteData = await imageSrc.toByteData(format: ui.ImageByteFormat.png);
    // 将 ByteData 写入文件
    await File(imageFilePath).writeAsBytes(byteData!.buffer.asUint8List());
    return imageFilePath;
  }

  /// 将 File 转换为 ui.Image
  static Future<ui.Image> file2Image(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  static Future<ui.Image> uint8ListToImage(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// 导出滤镜｜调色 图片
  static Future<String> exportFilterImage(
    BuildContext context,
    ShaderConfiguration configuration, {
    TextureSource? texture,
    double opacity = 1.0,
    int maxDimension = 2048,
    int jpegQuality = 85,
  }) async {
    if (texture == null) {
      return '';
    }

    final image = await configuration.export(
      texture,
      Size(texture.width.toDouble(), texture.height.toDouble()),
    );
    final bytes = await image.toByteData();
    if (bytes == null) {
      throw UnsupportedError('Failed to extract bytes for image');
    }

    var image1 = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: bytes.buffer,
      numChannels: 4,
    );

    if (opacity >= 0.0 && opacity < 1.0) {
      final double clampedOpacity = opacity.clamp(0.0, 1.0);
      for (final p in image1) {
        final int newAlpha = (p.a * clampedOpacity).round();
        p.a = newAlpha.clamp(0, 255);
      }
    }

    if (maxDimension > 0 &&
        (image1.width > maxDimension || image1.height > maxDimension)) {
      final int longSide = image1.width > image1.height ? image1.width : image1.height;
      final double scale = maxDimension / longSide;
      final int newW = (image1.width * scale).round();
      final int newH = (image1.height * scale).round();
      image1 = img.copyResize(image1, width: newW, height: newH);
    }

    // 3. 创建临时文件并保存
    final bool needAlpha = opacity < 1.0 || image1.hasAlpha;
    File output;
    if (needAlpha) {
      output = await createTmp('${DateTime.now().millisecondsSinceEpoch}.png');
      await img.encodePngFile(output.path, image1);
    } else {
      output = await createTmp('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await img.encodeJpgFile(output.path, image1, quality: jpegQuality);
    }

    String exportPath = output.path;
    debugPrint('Exported: $exportPath');

    return exportPath;
  }

  /// 导入图片到Uint8List
  static Future<Uint8List> loadSourceImage(String afterPath) async {
    final fbyte = await compute(_loadFileBytes, afterPath);
    return fbyte;
  }

  // 在后台 isolate 执行文件读取操作
  static Future<Uint8List> _loadFileBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  static Future<File> createTmp(String name) async {
    final directory = await getTemporaryDirectory();
    final tmpdir = Directory('${directory.path}$_tmpEffectDir');
    if (!(await tmpdir.exists())) {
      await tmpdir.create();
    }

    // for (FileSystemEntity entity in tmpdir.listSync()) {
    //   if (entity is File) {
    //     // 删除文件
    //     await entity.delete();
    //     debugPrint('Deleted file: ${entity.path}');
    //   } else if (entity is Directory) {
    //     // 删除子目录及其内容
    //     await entity.delete(recursive: true);
    //     debugPrint('Deleted directory: ${entity.path}');
    //   }
    // }

    final output = File('${tmpdir.path}/$name');
    await output.create();

    return output;
  }

  static Future<ui.Image> loadAssetImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// 颜色组合滤镜 着色器语言
  static void _registerMultGlsl() {
    /// none
    register<NoneShaderConfiguration>(
      () => FragmentProgram.fromAsset('none2'.shader),
    );

    /// filters
    // register<SquareLookupTableShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('lookup2'.shader),
    // );

    register<SquareLookupTableNoiseShaderConfiguration>(
      () => FragmentProgram.fromAsset('lookup_noise'.shader),
    );

    // register<HALDLookupTableShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('hald_lookup2'.shader),
    // );

    /// colors
    register<ColorsMulitConfiguration>(
      () => FragmentProgram.fromAsset('colors_mulit'.shader),
    );

    // register<SharpenShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('sharpen'.shader),
    // );
    //
    // register<TemperatureShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('temperature'.shader),
    // );
    //
    // register<ShadowShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('shadow'.shader),
    // );
    //
    // register<NoiseShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('noise'.shader),
    // );
    //
    // register<VignetteShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('vignette2'.shader),
    // );
    //
    // register<WhiteBalanceShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('whitebalance2'.shader),
    // );
    //
    // register<VibranceShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('vibrance2'.shader),
    // );
    //
    // register<ContrastShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('contrast2'.shader),
    // );
    //
    // register<ExposureShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('exposure2'.shader),
    // );
    //
    // register<BrightnessShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('brightness2'.shader),
    // );
    //
    // register<SaturationShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('saturation2'.shader),
    // );
    //
    // register<HighlightShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('highlight'.shader),
    // );
    //
    // register<HueShaderConfiguration2>(
    //   () => FragmentProgram.fromAsset('hue2'.shader),
    // );
    /// opacity
    // register<OpacityShaderConfiguration>(
    //   () => FragmentProgram.fromAsset('opacity'.shader),
    // );
  }

  static Future<Size> getImageSize(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  /// 缓存 image
  static Future<String?> cacheImage(String url) async {
    try {
      FileInfo imgInfo = await _imageCacheManager.downloadFile(url);
      File img = imgInfo.file;

      return img.path;
    } catch (e) {
      return null;
    }
  }

  /// 获取 缓存image
  static Future<String?> fetchCacheImage(String url) async {
    try {
      FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(url);
      fileInfo ??= await _imageCacheManager.downloadFile(url);
      return fileInfo.file.path;
    } catch (e) {
      return null;
    }
  }

  /// 获取 缓存缓存的字体
  static Future<String?> fetchCacheFont(
    String url, {
    bool cache = false,
  }) async {
    try {
      FileInfo? fileInfo = await _imageCacheManager.getFileFromCache(
        generateMd5(url),
      );
      debugPrint('local ttf = $fileInfo');
      if (fileInfo != null) {
        debugPrint('${fileInfo.file.path} already cached');
        await _loadFont(fileInfo.file.path);
        return fileInfo.file.path;
      } else {
        if (cache) {
          FileInfo ttfinfo = await _imageCacheManager.downloadFile(
            url,
            key: generateMd5(url),
          );
          await _loadFont(ttfinfo.file.path);
          return ttfinfo.file.path;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// asset to file
  static Future<File> saveAssetToFile(String assetPath) async {
    // 获取设备的文档目录（可以根据需要选择其他目录）
    Directory directory = await getApplicationDocumentsDirectory();

    // 定义目标文件路径
    String targetPath = '${directory.path}/${path.basename(assetPath)}';

    // 使用 rootBundle 加载 asset 文件
    ByteData data = await rootBundle.load(assetPath);

    // 将字节数据写入到文件
    File file = File(targetPath);
    await file.writeAsBytes(data.buffer.asUint8List());

    debugPrint('Asset saved to $targetPath');

    return file;
  }

  /// input md5
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  // 从文件获取 ByteData
  static Future<ByteData> _getFileByteData(String path) async {
    final bytes = await File(path).readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  /// 加载字体
  static Future<void> _loadFont(String path) async {
    FontLoader fontLoader = FontLoader(path);
    fontLoader.addFont(_getFileByteData(path));
    await fontLoader.load();
  }
}
