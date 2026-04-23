part of '../../flutter_baji.dart';

class EditorUtil {
  /// 滤镜 action
  static void goFilterPage(
    BuildContext context,
    String afterPath, [
    int? subActionIndex,
  ]) {
    Get.to(
      () => EditorFilterPage(
        subActionIndex: subActionIndex,
        afterPath: afterPath,
      ),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  /// 裁剪 action
  static Future<String?>? goCropPage(
    BuildContext context,
    String afterPath,
  ) async {
    return Get.to(
      () => EditorCropPage(afterPath: afterPath),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  /// 裁剪 header action
  static Future<String?>? goCropHeaderPage(
    BuildContext context,
    String afterPath,
    String title, {
    String? cropTip,
    bool isCircle = true,
    double aspectRatio = 1.0,
    String? maskAsset,
    bool showTipImage = true,
  }) async {
    return Get.to(
      () => EditorHeaderCropPage(
        afterPath: afterPath,
        title: title,
        cropTip: cropTip,
        isCircle: isCircle,
        maskAsset: maskAsset,
        aspectRatio: aspectRatio,
        showTipImage: showTipImage,
      ),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  /// 贴纸 action
  static void goStickerPage(
    BuildContext context,
    String afterPath, [
    int? subActionIndex,
  ]) {
    Get.to(
      () => EditorStickerPage(
        subActionIndex: subActionIndex,
        afterPath: afterPath,
      ),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  /// 贴字 action
  static void goTextPage(
    BuildContext context,
    String afterPath, [
    int? subActionIndex,
  ]) {
    Get.to(
      () =>
          EditorTextPage(subActionIndex: subActionIndex, afterPath: afterPath),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  /// 相框 action
  static void goFramePage(
    BuildContext context,
    String afterPath, [
    int? subActionIndex,
  ]) {
    Get.to(
      () => EditorFramePage(afterPath: afterPath),
      duration: BaseUtil.transDur,
      transition: Transition.size,
    );
  }

  static FiltersCallback? _filtersCallback;
  static FramesCallback? _framesCallback;
  static HomeSavedCallback? _homeSavedCallback;

  static BannerAdWidgetCallback? _bannerAdWidgetCallback;
  static NativeAdWidgetCallback? _nativeAdWidgetCallback;
  static AdShowCallback? _adShowCallback;

  static EditorType? editorType;
  static bool singleEditorSavetoAlbum = true;

  static List<FilterData> filterList = [];
  static List<FrameData> frameList = [];

  /// 编辑页面
  static void goFluEditor(
    BuildContext context, {
    required String orignal,
    required String title,
    EditorType? type,
    bool singleEditorSave = true,
    FiltersCallback? filtersCb,
    FramesCallback? framesCb,
    HomeSavedCallback? homeSavedCb,
    BannerAdWidgetCallback? bannerAdWidgetCb,
    NativeAdWidgetCallback? nativeAdWidgetCb,
    AdShowCallback? adShowWidgetCb,
    bool? showFeatureDialog,
    String? groupName,
    String? subGroupId,
    FeatureDialogBuilder? featureDialogBuilder,
  }) async {
    _filtersCallback = filtersCb;
    _framesCallback = framesCb;
    _homeSavedCallback = homeSavedCb;
    _bannerAdWidgetCallback = bannerAdWidgetCb;
    _nativeAdWidgetCallback = nativeAdWidgetCb;
    _adShowCallback = adShowWidgetCb;

    editorType = type;

    singleEditorSavetoAlbum = singleEditorSave;
    if (EditorType.colors == type) {
      BaseUtil.goColorsPage(context, orignal, 0);
      return;
    }

    if (EditorType.filter == type) {
      if (filterList.isEmpty) {
        await fetchFilterList(context);
      }
      goFilterPage(context, orignal);
      return;
    }

    if (EditorType.crop == type) {
      goCropPage(context, orignal);
      return;
    }

    if (EditorType.sticker == type) {
      goStickerPage(context, orignal);
      return;
    }

    if (EditorType.text == type) {
      goTextPage(context, orignal);
      return;
    }

    if (EditorType.frame == type) {
      if (frameList.isEmpty) {
        await fetchFrameList(context);
      }
      goFramePage(context, orignal);
      return;
    }

    EditorType? groupType = EditorType.fromString(groupName);

    Get.to(
      () => EditorHomePage(
        orignal: orignal,
        showFeatureDialog: showFeatureDialog,
        groupType: groupType,
        subGroupId: subGroupId,
        featureDialogBuilder: featureDialogBuilder,
        title: title,
      ),
    );

    ;
  }

  /// 获取滤镜列表
  static Future<List<FilterData>> fetchFilterList(BuildContext context) async {
    BaseUtil.showLoadingdialog(context);
    var filters = await _filtersCallback?.call() ?? [];

    ///配置滤镜
    filterList = [];
    for (FilterData f in filters) {
      /// 插入空滤镜
      List<FilterDetail> lists = f.list ?? [];
      if (filters.indexOf(f) == 0 && lists.isNotEmpty) {
        lists.insert(
          0,
          FilterDetail(
            id: -1,
            filterImage: 'neutral_color_luts'.lutPng,
            image: lists[0].image,
            name: '无滤镜',
            imgFrom: lists[0].imgFrom,
            lutFrom: 0,
          ),
        );
      }

      f.list = lists;
      filterList.add(f);
    }
    BaseUtil.hideLoadingdialog();
    return filterList;
  }

  /// 获取相框列表
  static Future<List<FrameData>> fetchFrameList(BuildContext context) async {
    BaseUtil.showLoadingdialog(context);
    var frames = await _framesCallback?.call() ?? [];
    frameList = frames;
    BaseUtil.hideLoadingdialog();
    return frameList;
  }

  /// banner ad widget
  static Widget bannerAdWidget(BuildContext context) {
    return _bannerAdWidgetCallback?.call() ?? const SizedBox();
  }

  /// native ad widget
  static Widget nativeAdWidget(BuildContext context) {
    return _nativeAdWidgetCallback?.call() ?? const SizedBox();
  }

  /// showAd
  /// type 0 激励，1 插页，2 插页激励
  static Future<bool?> showAd({int type = 0}) async {
    return _adShowCallback?.call(type);
  }

  /// clean tmp
  static void clearTmpObject(String after) {
    _filtersCallback = null;
    _homeSavedCallback = null;

    _bannerAdWidgetCallback = null;
    _nativeAdWidgetCallback = null;
    _adShowCallback = null;

    editorType == null;
    singleEditorSavetoAlbum = true;

    BaseUtil.closeCallbacks();
  }

  /// 保存图片
  static Future<void> homeSaved(BuildContext context, String lastImage) async {
    return _homeSavedCallback?.call(context, lastImage);
  }

  /// 刷新首页数据
  static void refreshHomeEffect(String? newPath) {
    if (Get.isRegistered<EditorHomeController>()) {
      Get.find<EditorHomeController>().afterPath.value = newPath ?? '';
    }
  }

  /// 裁剪图片
  static Future<String> cropImage(
    ImageEditorController croperController,
  ) async {
    var state = croperController.state;

    if (state == null || state.getCropRect() == null) {
      return '';
    }

    // 仅处理剪裁参数，不涉及 UI 操作
    var cropParams = _prepareCropParams(
      state.rawImageData,
      state.getCropRect()!,
      state.editAction?.rotateDegrees ?? 0.0,
      croperController.editActionDetails?.needFlip ?? false,
    );

    // 在后台 isolate 中执行图片剪裁操作
    var data = await compute(_cropImageWithThread, cropParams);

    File output = await BaseUtil.createTmp(
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await output.writeAsBytes(data!);

    String exportPath = output.path;
    debugPrint('Exported: $exportPath');

    return exportPath;
  }

  // 图片剪裁所需参数的封装
  static Map<String, dynamic> _prepareCropParams(
    Uint8List imageBytes,
    Rect cropRect,
    double degree,
    bool needFlip,
  ) {
    return {
      'imageBytes': imageBytes,
      'rect': cropRect,
      'degree': degree,
      'needFlip': needFlip,
    };
  }

  static Future<Uint8List?> _cropImageWithThread(
    Map<String, dynamic> params,
  ) async {
    Uint8List imageBytes = params['imageBytes'];
    Rect rect = params['rect'];
    double degree = params['degree'];
    bool needFlip = params['needFlip'];

    img.Command cropTask = img.Command();
    cropTask.decodeImage(imageBytes);

    cropTask.copyRotate(angle: degree);
    if (needFlip) {
      cropTask.copyFlip(direction: img.FlipDirection.horizontal);
    }
    cropTask.copyCrop(
      x: rect.topLeft.dx.ceil(),
      y: rect.topLeft.dy.ceil(),
      height: rect.height.ceil(),
      width: rect.width.ceil(),
    );

    img.Command encodeTask = img.Command();
    encodeTask.subCommand = cropTask;
    encodeTask.encodeJpg();

    return encodeTask.getBytesThread();
  }

  static Future<List> fileToUint8ListAndImage(String filePath) async {
    return await compute(_processFile, filePath);
  }

  // 用于 isolate 中运行的函数
  static Future<List> _processFile(String filePath) async {
    File file = File(filePath);
    Uint8List fileBytes = await file.readAsBytes();
    img.Image? image = await _uint8ListToImage(fileBytes);
    return [image, fileBytes];
  }

  static Future<img.Image?> _uint8ListToImage(Uint8List uint8List) async {
    // 解码 Uint8List 为 ui.Image
    img.Image? image = img.decodeImage(uint8List);

    return image;
  }

  /// 相框
  static Future<String> addFrame(
    GlobalKey imgkey,
    String input,
    String frame,
    double frameAspectRatio,
  ) async {
    /// 生成底图
    RenderRepaintBoundary boundary =
        imgkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // 渲染为图片
    ui.Image baseImage = await boundary.toImage(pixelRatio: 3.0);

    /// 获取相框图
    var inputBytes = (await fileToUint8ListAndImage(frame))[1];
    final ui.Codec codec = await ui.instantiateImageCodec(inputBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image frameImage = frameInfo.image;

    /// 获取输入图片的宽高
    final int inputWidth = baseImage.width;
    final int inputHeight = baseImage.height;

    /// 计算画布大小
    double canvasWidth, canvasHeight;
    if (inputWidth / inputHeight > frameAspectRatio) {
      canvasWidth = inputWidth.toDouble();
      canvasHeight = inputWidth / frameAspectRatio;
    } else {
      canvasHeight = inputHeight.toDouble();
      canvasWidth = inputHeight * frameAspectRatio;
    }

    /// 创建画布并绘制图片
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
    );
    final Paint paint = Paint();

    // 计算居中位置
    double inputOffsetX = (canvasWidth - inputWidth) / 2;
    double inputOffsetY = (canvasHeight - inputHeight) / 2;

    // 绘制输入图片
    canvas.drawImage(baseImage, Offset(inputOffsetX, inputOffsetY), paint);

    // 绘制相框图片
    double frameWidth = frameImage.width.toDouble();
    double frameHeight = frameImage.height.toDouble();

    // 将相框适应到画布大小
    final Rect frameRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);
    final Rect srcRect = Rect.fromLTWH(0, 0, frameWidth, frameHeight);

    canvas.drawImageRect(frameImage, srcRect, frameRect, paint);
    canvas.restore();

    /// 将合成的图片保存为PNG格式
    final ui.Image finalImage = await recorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final ByteData? byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    /// 保存图片
    File output = await BaseUtil.createTmp(
      '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await output.writeAsBytes(pngBytes);

    return output.path;
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

  /// 贴纸，贴字
  static Future<String> addSticker(
    String input,
    LindiController2 stickerController,
  ) async {
    // 1. 加载 input 原始图片
    var inputBytes = (await fileToUint8ListAndImage(input))[1];
    final ui.Codec codec = await ui.instantiateImageCodec(inputBytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image baseImage = frame.image;

    // 2. 获取贴纸图片的 Uint8List 数据
    Uint8List? stickerImageBytes = await stickerController.saveAsUint8List();
    if (stickerImageBytes == null) {
      return '';
    }
    final ui.Codec codec2 = await ui.instantiateImageCodec(stickerImageBytes);
    final ui.FrameInfo frame2 = await codec2.getNextFrame();
    final ui.Image stickerImage = frame2.image;

    // 3. 确定画布大小，使用最大尺寸
    final int canvasWidth = baseImage.width > stickerImage.width
        ? baseImage.width
        : stickerImage.width;
    final int canvasHeight = baseImage.height > stickerImage.height
        ? baseImage.height
        : stickerImage.height;

    debugPrint('cavasSize = $canvasWidth x $canvasHeight');

    // 4. 创建画布并合成图片
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint paint = Paint();

    // 将原始图片按比例缩放以适应较大的画布
    final double baseScaleX = canvasWidth / baseImage.width;
    final double baseScaleY = canvasHeight / baseImage.height;
    final double baseScale = baseScaleX < baseScaleY ? baseScaleX : baseScaleY;

    final double stickerScaleX = canvasWidth / stickerImage.width;
    final double stickerScaleY = canvasHeight / stickerImage.height;
    final double stickerScale = stickerScaleX < stickerScaleY
        ? stickerScaleX
        : stickerScaleY;

    // 绘制原始图片
    canvas.drawImageRect(
      baseImage,
      Rect.fromLTWH(
        0,
        0,
        baseImage.width.toDouble(),
        baseImage.height.toDouble(),
      ),
      Rect.fromLTWH(
        0,
        0,
        baseImage.width * baseScale,
        baseImage.height * baseScale,
      ),
      paint,
    );

    // 绘制贴纸图片
    canvas.drawImageRect(
      stickerImage,
      Rect.fromLTWH(
        0,
        0,
        stickerImage.width.toDouble(),
        stickerImage.height.toDouble(),
      ),
      Rect.fromLTWH(
        0,
        0,
        stickerImage.width * stickerScale,
        stickerImage.height * stickerScale,
      ),
      paint,
    );

    canvas.save();

    // 将画布内容转换为图片
    final ui.Image composedImage = await recorder.endRecording().toImage(
      canvasWidth,
      canvasHeight,
    );

    // 4. 将合成后的图像转换为 Uint8List
    final ByteData? byteData = await composedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List composedImageBytes = byteData!.buffer.asUint8List();

    // 5. 保存合成后的图片
    File output = await BaseUtil.createTmp(
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await output.writeAsBytes(composedImageBytes);

    return output.path;
  }
}

/// 功能提示弹窗构建器
typedef FeatureDialogBuilder =
    Widget? Function(BuildContext context, VoidCallback onConfirm);
