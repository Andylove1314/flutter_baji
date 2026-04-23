part of '../../flutter_baji.dart';

class BajiUtil {
  static SaveCallback? _saveImage;
  static FetchTextureCallback? _textureCallback;
  static EnhanceCallback? _enhanceCallback;
  static UploadMineMaterialCallback? _uploadMineMaterialCallback;
  static MineMaterialDeleteCallback? _mineMaterialDeleteCallback;
  static AiRemoveBgCallback? _aiRemoveBgCallback;
  static FetchBgColorCallback? _bgColorCallback;
  static FetchBgTextureCallback? _bgTextureCallback;
  static FeedbackCallback? _feedbackCallback;
  static UploadBajiCallback? _uploadBajiCallback;
  static ImageShareCallback? _imageShareCallback;
  static FetchFumoCallback? _fumoCallback;
  static PrintGoodsCallback? _printGoodsCallback;
  static BloodTipClickCallback? _bloodTipClickCallback;
  static SaveTemplateCallback? _saveTemplateCallback;
  static UploadTemplateImageCallback? _uploadTemplateImageCallback;
  static CopyTemplateCallback? _copyTemplateCallback;
  static GoldenGyTipClickCallback? _goldenGyTipClickCallback;

  static bool canMakeTemplate = false;
  static TemplateData? templateData;

  static MakeType makeBjType = MakeType.baji;

  static var templateId;

  static void goBaji(
      {required SaveCallback saveImage,
      required FetchTextureCallback textureCallback,
      required EnhanceCallback enhanceCallback,
      required UploadMineMaterialCallback uploadMineMaterialCallback,
      required MineMaterialDeleteCallback mineMaterialDeleteCallback,
      required AiRemoveBgCallback aiRemoveBgCallback,
      required FetchBgColorCallback bgColorCallback,
      required FetchBgTextureCallback bgTextureCallback,
      required FeedbackCallback feedbackCallback,
      required UploadBajiCallback uploadBajiCallback,
      required ImageShareCallback imageShareCallback,
      required FetchFumoCallback fumoCallback,
      required PrintGoodsCallback printGoodsCallback,
      required BloodTipClickCallback bloodTipClickCallback,
      SaveTemplateCallback? saveTemplateCallback,
      CopyTemplateCallback? copyTemplateCallback,
      UploadTemplateImageCallback? uploadTemplateImageCallback,
      GoldenGyTipClickCallback? goldenGyTipClickCallback,
      String? title,
      MakeType makeType = MakeType.allbjType,
      bool showMakeTemplate = false,
      String? imagePath,
      String? templateParams,
      var templateDataId}) {
    _saveImage = saveImage;
    _textureCallback = textureCallback;
    _enhanceCallback = enhanceCallback;
    _uploadMineMaterialCallback = uploadMineMaterialCallback;
    _mineMaterialDeleteCallback = mineMaterialDeleteCallback;
    _aiRemoveBgCallback = aiRemoveBgCallback;
    _bgColorCallback = bgColorCallback;
    _bgTextureCallback = bgTextureCallback;
    _feedbackCallback = feedbackCallback;
    _uploadBajiCallback = uploadBajiCallback;
    _imageShareCallback = imageShareCallback;
    _fumoCallback = fumoCallback;
    _printGoodsCallback = printGoodsCallback;
    _bloodTipClickCallback = bloodTipClickCallback;
    canMakeTemplate = showMakeTemplate;
    _saveTemplateCallback = saveTemplateCallback;
    _copyTemplateCallback = copyTemplateCallback;
    _uploadTemplateImageCallback = uploadTemplateImageCallback;
    _goldenGyTipClickCallback = goldenGyTipClickCallback;
    makeBjType = makeType;
    templateId = templateDataId;
    //去掉小卡入口
    if (makeType == MakeType.allbjType) {
      BadgeConfig.presetSizes = [
        ...BadgeConfig.bajiSizes,
        ...BadgeConfig.xiaokaSizes
      ];
    } else if (makeType == MakeType.xiaoka) {
      BadgeConfig.presetSizes = BadgeConfig.xiaokaSizes;
    } else if (makeType == MakeType.baji) {
      BadgeConfig.presetSizes = BadgeConfig.bajiSizes;
    } else {
      BadgeConfig.presetSizes = [
        ...BadgeConfig.bajiSizes,
        ...BadgeConfig.xiaokaSizes
      ];
    }

    TemplateData? template = _loadTemplate(templateParams);
    templateData = template;

    title ??= '制作吧唧';

    if (template != null) {
      goHome(
          imagePath: '',
          title: title,
          isCircle: template.type == 0,
          size: template.configSize!,
          initLayers: template.layerItems,
          bgColors: template.bgColors,
          bjName: template.type == 0
              ? '圆形吧唧'
              : (template.configSize!.bjWidthPixl /
                          template.configSize!.bjWidthPixl ==
                      1.0
                  ? '方形吧唧'
                  : '小卡'));
    } else {
      Get.to(() => BjStartPage(
            title: title!,
            imagePath: imagePath,
            makeTemplate: showMakeTemplate,
          ));
    }
  }

  static Future<void> saveImage(String path, bool usePrint, bool isJpg) async {
    _saveImage?.call(path, usePrint, isJpg);
  }

  static Future<String?> uploadBaji(dynamic image) async {
    return _uploadBajiCallback?.call(image, templateId: templateId);
  }

  static Future<void> shareImage(BuildContext context,
      {required Widget bjWidget,
      required dynamic image,
      required String imageUrl,
      required String title,
      required String content}) async {
    _imageShareCallback?.call(
        context, bjWidget, image, imageUrl, title, content);
  }

  static Future<void> goPrintGoods(
      PrintBajiData printBajiData, String type) async {
    _printGoodsCallback?.call(printBajiData, type);
  }

// 从JSON恢复模板
  static TemplateData? _loadTemplate(String? paramString) {
    if (paramString == null) {
      return null;
    }

    Map<String, dynamic> json = jsonDecode(paramString);
    debugPrint('TemplateData: $json');
    final templateData = TemplateData.fromJson(json);

    return templateData;
  }

  static void goHome(
      {required String imagePath,
      List<TemplateLayerItemData> initLayers = const [],
      required bool isCircle,
      required ConfigSize size,
      required String title,
      List<String>? bgColors,
      required String bjName}) {
    if (bgColors == null || bgColors.isEmpty) {
      bgColors = const ['#00000000', '#00000000'];
    }

    Get.to(() => BjHomePage(
        imagePath, isCircle, size, initLayers, bgColors!, title, bjName));
  }

  static void goPreview({
    required image,
    required bool isCircle,
    required ConfigSize size,
    ImageInfo? customBgImage,
    ImageInfo? fumoImage,
    BjFumoData? fumoData,
    List<BjFumoData> fumoDatas = const [],
    Function()? changeGy,
    String? bjName,
  }) {
    Get.to(() => BjCardPreviewPage(
        image: image,
        isCircle: isCircle,
        size: size,
        customBgImage: customBgImage,
        fumoImage: fumoImage,
        fumoData: fumoData,
        fumoDatas: fumoDatas,
        changeGy: changeGy,
        bjName: bjName));
  }

  static Future<List<BjTextureData>?> fetchTextures() async {
    return _textureCallback?.call();
  }

  static Future<List<BjTextureData>?> fetchBgTextures() async {
    return _bgTextureCallback?.call();
  }

  static Future<List<BjColorData>?> fetchBgColors() async {
    return _bgColorCallback?.call();
  }

  static Future<List<BjFumoData>?> fetchFumoLists() async {
    return _fumoCallback?.call();
  }

  static Future<void> bloodTipClick() async {
    return _bloodTipClickCallback?.call();
  }

  static Future<void> goldenGyTipClick() async {
    return _goldenGyTipClickCallback?.call();
  }

  /// 保存模板
  static Future<bool>? saveTemplate(
      {required String maker,
      required String templateImage,
      required String templateName,
      required String templateParam}) {
    return _saveTemplateCallback?.call(
        maker: maker,
        templateImage: templateImage,
        templateName: templateName,
        templateParam: templateParam);
  }

  /// copy模板
  static Future<bool>? copyTemplate(
      {required String makerName, required String templateParam}) {
    return _copyTemplateCallback?.call(
        templateParam: templateParam, makerName: makerName);
  }

  /// 上传模板图片
  static Future<String?> uploadTemplateImage(String imagePath) async {
    return _uploadTemplateImageCallback?.call(imagePath);
  }

  static Future<String?> enhance(String path, String type) async {
    return _enhanceCallback?.call(path, type);
  }

  static Future<String?> aiRemoveBg(String path) async {
    return _aiRemoveBgCallback?.call(path);
  }

  static Future<bool> uploadMineMaterial(String path, String type) async {
    return _uploadMineMaterialCallback?.call(path, type) ?? true;
  }

  static Future<bool> deleteMineMaterial(id) async {
    return _mineMaterialDeleteCallback?.call(id) ?? true;
  }

  static Future<bool> feedback(String content) async {
    return _feedbackCallback?.call(content) ?? true;
  }

  static Future<dynamic> cropImage(
    ui.Image image,
    double leftOffset,
    double rightOffset,
    double cardRatio,
    double pixelRatio,
    bool addBlackLine, {
    bool isCircle = false,
    double ellipseRatio = 1.0, // width / height
    double radius = 0.0,
    double topOffset = 0.0,
  }) async {
    try {
      final left = leftOffset * pixelRatio * 2;
      final right = rightOffset * pixelRatio * 2;
      final clipWidth = image.width - left - right;
      final clipHeight = clipWidth / cardRatio;

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final Offset srcCenter = Offset(
        left + clipWidth / 2,
        image.height / 2 - topOffset * pixelRatio * 2,
      );

      canvas.translate(
        -srcCenter.dx + clipWidth / 2,
        -srcCenter.dy + clipHeight / 2,
      );

      // 裁剪区域
      if (isCircle) {
        // 椭圆
        final double ellipseWidth = clipWidth;
        final double ellipseHeight = clipWidth / ellipseRatio;

        final Rect ellipseRect = Rect.fromCenter(
          center: srcCenter,
          width: ellipseWidth,
          height: ellipseHeight,
        );

        final clipPath = Path()..addOval(ellipseRect);
        canvas.clipPath(clipPath);
      } else {
        // 普通矩形
        final clipPath = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: srcCenter,
              width: clipWidth,
              height: clipHeight,
            ),
            Radius.circular(radius),
          ));
        canvas.clipPath(clipPath);
      }

      // 绘制原始图像
      canvas.drawImage(image, Offset.zero, Paint());

      // 添加边框
      if (addBlackLine) {
        final borderPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        if (isCircle) {
          final Rect ellipseRect = Rect.fromCenter(
            center: srcCenter,
            width: clipWidth,
            height: clipWidth / ellipseRatio,
          );
          canvas.drawOval(ellipseRect, borderPaint);
        } else {
          final Rect rect = Rect.fromCenter(
            center: srcCenter,
            width: clipWidth,
            height: clipHeight,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(radius)),
            borderPaint,
          );
        }
      }

      final picture = recorder.endRecording();
      final clippedImage = await picture.toImage(
        clipWidth.toInt(),
        clipHeight.toInt(),
      );

      image.dispose();
      return clippedImage;
    } catch (e) {
      debugPrint('截图失败: $e');
      return null;
    }
  }

  /// 黑化图片非透明部位
  static Future<ui.Image?> blackImages(ui.Image image) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 修改颜色矩阵，使所有非完全透明的部分变为完全不透明的黑色
      const colorFilter = ColorFilter.matrix([
        0, 0, 0, 0, 0, // R = 0
        0, 0, 0, 0, 0, // G = 0
        0, 0, 0, 0, 0, // B = 0
        0, 0, 0, 1, 0, // 保持原始 Alpha 通道
      ]);

      // 先绘制一遍处理 Alpha 通道
      final alphaPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = const ColorFilter.matrix([
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      canvas.drawImage(image, Offset.zero, alphaPaint);

      // 再绘制一遍将所有非透明部分变为黑色
      final blackPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = colorFilter
        ..blendMode = BlendMode.srcIn; // 只影响非透明部分
      canvas.drawImage(image, Offset.zero, blackPaint);

      // 生成新图片
      final picture = recorder.endRecording();
      final blackImage = await picture.toImage(image.width, image.height);

      return blackImage;
    } catch (e) {
      debugPrint('图片黑化失败: $e');
      return null;
    }
  }

  /// 合并多张图片
  static Future<dynamic> mergeImages(List<ui.Image> images) async {
    try {
      if (images.isEmpty) return null;
      if (images.length == 1) return images.first;

      // 创建画布
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 使用第一张图片的尺寸作为基准
      final width = images.first.width.toDouble();
      final height = images.first.height.toDouble();

      // 设置绘制参数
      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true
        ..blendMode = BlendMode.srcOver;

      // 按顺序绘制所有图片
      for (var image in images) {
        canvas.drawImage(image, Offset.zero, paint);
      }

      // 生成合并后的图片
      final picture = recorder.endRecording();
      final mergedImage = await picture.toImage(width.toInt(), height.toInt());

      // 释放原始图片资源
      for (var image in images) {
        image.dispose();
      }

      return mergedImage;
    } catch (e) {
      debugPrint('合并图片失败: $e');
      return null;
    }
  }

  /// 压缩谷子图片到zip包
  static Future<String?> zipGoodsSrcs() async {
    // if (!Get.isRegistered<ImageHomeController>()) {
    //   return null;
    // }
    // ImageHomeController homeController = Get.find();
    // List<String> goodsSrcs =
    //     homeController.gongyiSrcs.map((item) => item.gyPath!).toList();
    // try {
    //   if (goodsSrcs.isEmpty) return null;

    //   // 获取临时目录用于存储 zip 文件
    //   final tempDir = await getTemporaryDirectory();
    //   final zipFileName =
    //       'nwdn_goods_${DateTime.now().millisecondsSinceEpoch}.zip';
    //   final zipFilePath = '${tempDir.path}/$zipFileName';

    //   // 创建 zip 文件
    //   final zipFile = File(zipFilePath);
    //   final archive = Archive();

    //   // 添加所有图片到压缩包
    //   for (int i = 0; i < goodsSrcs.length; i++) {
    //     final imagePath = goodsSrcs[i];
    //     final imageFile = File(imagePath);
    //     if (await imageFile.exists()) {
    //       final imageBytes = await imageFile.readAsBytes();
    //       // 使用源文件的文件名
    //       final fileName = path.basename(imagePath);
    //       debugPrint('压缩图片: $fileName');

    //       // 创建压缩文件条目
    //       final archiveFile = ArchiveFile(
    //         fileName,
    //         imageBytes.length,
    //         imageBytes,
    //       );
    //       archive.addFile(archiveFile);
    //     }
    //   }

    //   // 生成 zip 文件
    //   final zipData = ZipEncoder().encode(archive);
    //   if (zipData != null) {
    //     await zipFile.writeAsBytes(zipData);
    //     return zipFilePath;
    //   }

    //   return null;
    // } catch (e) {
    //   debugPrint('压缩图片失败: $e');
    //   return null;
    // }
  }

  static void closeCallbacks() {
    _saveImage = null;
    _textureCallback = null;
    _enhanceCallback = null;
    _uploadMineMaterialCallback = null;
    _mineMaterialDeleteCallback = null;
    _aiRemoveBgCallback = null;
    _bgColorCallback = null;
    _bgTextureCallback = null;
    _feedbackCallback = null;
    _uploadBajiCallback = null;
    _imageShareCallback = null;
    _fumoCallback = null;
    _printGoodsCallback = null;
    _bloodTipClickCallback = null;
    _saveTemplateCallback = null;
    _uploadTemplateImageCallback = null;
    _copyTemplateCallback = null;
    _uploadBajiCallback = null;
    _goldenGyTipClickCallback = null;

    if (Get.isRegistered<BjHomeController>()) {
      BjHomeController homeController = Get.find();

      for (var item in homeController.stickerPreDatas.value) {
        item.lindiController.dispose();
      }
      homeController.stickerPres.clear();
      homeController.stickerMagnifiers.clear();
      homeController.stickerPreDatas.value.clear();
    }

    BaseUtil.closeCallbacks();
  }
}
