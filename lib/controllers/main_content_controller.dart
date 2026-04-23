import 'package:flutter/cupertino.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/badge_config.dart';
import 'package:flutter_baji/models/layer_data.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../models/craftsmanship_data.dart';
import '../utils/base_util.dart';
import '../utils/ui_utils.dart';

class MainContentController extends GetxController {
  GlobalKey cardKey = GlobalKey();
  GlobalKey bgKey = GlobalKey();
  GlobalKey compassKey = GlobalKey();

  bool isCircle = true;
  late ConfigSize configSize;

  void setShape(bool circle, ConfigSize size) {
    isCircle = circle;
    configSize = size;
  }

  /// 保存吧唧图
  Future<String?> saveBjContent() async {
    final image = await BaseUtil.captureImageWithKey(cardKey, Get.pixelRatio);

    if (image == null) return null;

    final cropedImage = await BajiUtil.cropImage(
        image,
        configSize.bjPreMarginLeft,
        configSize.bjPreMarginRight,
        configSize.ratio,
        Get.pixelRatio,
        false,
        isCircle: isCircle,
        radius: configSize.radius);

    final path = await BaseUtil.createNewSize(
        cropedImage,
        configSize.bjWidthPixl,
        configSize.bjHeightPixl,
        configSize.extPixl,
        'badge_${configSize.size}_吧唧图');
    return path;
  }

  /// 保存吧唧血线内图
  Future<dynamic> saveBjBloodInner() async {
    final image = await BaseUtil.captureImageWithKey(cardKey, Get.pixelRatio);

    if (image == null) return null;

    var lineWidth = getBloodViewWidth();

    final cropedImage = await BajiUtil.cropImage(
        image,
        configSize.bjPreMarginLeft + lineWidth,
        configSize.bjPreMarginRight + lineWidth,
        configSize.ratio,
        Get.pixelRatio,
        false,
        isCircle: isCircle,
        radius: configSize.radius);

    return cropedImage;
  }

  /// 保存工艺图层
  Future<List<List<dynamic>>> saveCraftsmanshipLayerImage(
      List<LayerData> stickerPreDatas) async {
    List<List<dynamic>> paths = [];
    try {
      // 按工艺类型分组
      Map<CraftsmanshipType, List<LayerData>> groupedLayers = {};
      for (var layer in stickerPreDatas) {
        if (layer.craftsmanshipData?.type != null &&
            layer.craftsmanshipData?.type != CraftsmanshipType.none) {
          if (!groupedLayers.containsKey(layer.craftsmanshipData!.type)) {
            groupedLayers[layer.craftsmanshipData!.type] = [];
          }
          groupedLayers[layer.craftsmanshipData!.type]!.add(layer);
        }
      }

      for (var entry in groupedLayers.entries) {
        BaseUtil.logEvent('badge_04', params: {
          'badge_type': isCircle ? 'round' : 'square',
          'tech_type': entry.key.name,
        });
      }

      // 处理每个工艺类型的图层组
      for (var entry in groupedLayers.entries) {
        List<ui.Image> images = [];
        for (var layer in entry.value) {
          if (layer.captureKey?.currentContext != null) {
            final image = await BaseUtil.captureImageWithKey(
                layer.captureKey!, Get.pixelRatio);
            if (image != null) {
              images.add(image);
            }
          }
        }

        if (images.isNotEmpty) {
          // 合并同类型的图层
          final mergedImage = await BajiUtil.mergeImages(images);
          final blackImage = await BajiUtil.blackImages(mergedImage);
          if (blackImage != null) {
            final cropedImage = await BajiUtil.cropImage(
                blackImage,
                configSize.bjPreMarginLeft,
                configSize.bjPreMarginRight,
                configSize.ratio,
                Get.pixelRatio,
                false,
                isCircle: isCircle,
                radius: configSize.radius);

            final path = await BaseUtil.createNewSize(
                cropedImage,
                configSize.bjWidthPixl,
                configSize.bjHeightPixl,
                configSize.extPixl,
                'badge_${configSize.size}_${entry.value.first.craftsmanshipData!.name}');

            if (path != null) {
              await BaseUtil.cacheImage(path);
              List data = [path, entry.value.first.craftsmanshipData];
              paths.add(data);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('保存工艺图层失败: $e');
    }
    return paths;
  }

  /// 保存非工艺图层合并图
  Future<String?> saveNormalLayerImage(List<LayerData> stickerPreDatas) async {
    try {
      List<ui.Image> images = [];

      // 先获取背景图层
      final bgImage = await BaseUtil.captureImageWithKey(bgKey, Get.pixelRatio);
      if (bgImage != null) {
        images.add(bgImage);
      }

      // 收集所有非工艺图层
      for (var layer in stickerPreDatas) {
        if (layer.craftsmanshipData?.type == null ||
            layer.craftsmanshipData?.type == CraftsmanshipType.none ||
            layer.craftsmanshipData?.type == CraftsmanshipType.uv ||
            layer.craftsmanshipData?.type == CraftsmanshipType.whiteInk) {
          if (layer.captureKey?.currentContext != null) {
            final image = await BaseUtil.captureImageWithKey(
                layer.captureKey!, Get.pixelRatio);
            if (image != null) {
              images.add(image);
            }
          }
        }
      }

      // 添加指南针图层
      final compassImage =
          await BaseUtil.captureImageWithKey(compassKey, Get.pixelRatio);
      if (compassImage != null) {
        images.add(compassImage);
      }

      if (images.isNotEmpty) {
        // 合并所有图层（背景 + 非工艺图层 + 指南针）
        final mergedImage = await BajiUtil.mergeImages(images);
        if (mergedImage != null) {
          final cropedImage = await BajiUtil.cropImage(
              mergedImage,
              configSize.bjPreMarginLeft,
              configSize.bjPreMarginRight,
              configSize.ratio,
              Get.pixelRatio,
              true,
              isCircle: isCircle,
              radius: configSize.radius);

          final path = await BaseUtil.createNewSize(
              cropedImage,
              configSize.bjWidthPixl,
              configSize.bjHeightPixl,
              configSize.extPixl,
              'badge_${configSize.size}_打印图');

          if (path != null) {
            await BaseUtil.cacheImage(path);
            return path;
          }
        }
      }
    } catch (e) {
      debugPrint('保存非工艺图层合并图失败: $e');
    }
    return null;
  }

  /// 获取血线宽度
  double getBloodViewWidth() {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    double adjustedWidth =
        w - configSize.bjPreMarginLeft - configSize.bjPreMarginRight;
    double bloodRatio =
        configSize.bjBloodLineWidthPixl / configSize.bjWidthPixl;
    double lineWidth = bloodRatio * adjustedWidth / 2;

    return lineWidth;
  }
}
