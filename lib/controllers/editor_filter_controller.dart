import 'dart:typed_data';

import 'package:get/get.dart';

import '../constants/constant_editor.dart';
import '../flutter_baji.dart';
import '../utils/base_util.dart';

class EditorFilterController extends GetxController {
  final refreshParamValue = false.obs;

  final textureSource = Rx<TextureSource?>(null);

  final ShaderConfiguration none = NoneShaderConfiguration();

  /// filter
  late SquareLookupTableNoiseShaderConfiguration currentConfig =
      SquareLookupTableNoiseShaderConfiguration(
    lookup: filterParamInitValues['Intensity'] ?? 0.0,
    lookupMin: filterParamMinValues['IntensityMin'] ?? 0.0,
    lookupMax: filterParamMaxValues['IntensityMax'] ?? 0.0,
    noise: filterParamInitValues['Noise'] ?? 0.0,
    noiseMin: filterParamMinValues['NoiseMin'] ?? 0.0,
    noiseMax: filterParamMaxValues['NoiseMax'] ?? 0.0,
  );

  /// current config
  final filterDetail = Rx<FilterDetail?>(null);

  Future<void> loadSourceImage(String afterPath) async {
    Uint8List fbyte = await BaseUtil.loadSourceImage(afterPath);
    final texture = await TextureSource.fromMemory(fbyte);
    textureSource.value = texture;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    currentConfig.dispose();
    super.onClose();
  }

  /// 更新滤镜噪点
  void updateFilterNoise() {
    bool needRefreshNoise = filterDetail.value != null &&
        filterDetail.value?.noise != null &&
        (filterDetail.value?.noise ?? 0.0) > 0.0;

    if (needRefreshNoise) {
      double intensityValue = currentConfig.lutIntensity.value * 1.0;
      double maxNoise =
          ((currentConfig.noiseParamter as ShaderRangeNumberParameter).max ??
                  0.2) *
              1.0;
      currentConfig.noiseStrength = (intensityValue * maxNoise) * 1.0;
    } else {
      currentConfig.noiseStrength = 0.0;
    }
  }
}
