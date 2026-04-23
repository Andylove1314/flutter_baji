import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/constant_editor.dart';
import '../flutter_baji.dart';
import '../utils/base_util.dart';

class FilterColorsController extends GetxController {
  final textureSource = Rx<TextureSource?>(null);
  final currentParamsList = RxList<String>();
  final refreshParamValue = false.obs;

  Map<String, dynamic> currentParamMap = {};


final ColorsMulitConfiguration finalConfig = ColorsMulitConfiguration(
  /////////////////////////////////#init#/////////////////////////////
  brightness: colorParamInitValues['Brightness'] ?? 0.0,
  saturation: colorParamInitValues['Saturation'] ?? 0.0,
  contrast: colorParamInitValues['Contrast'] ?? 0.0,
  sharpen: colorParamInitValues['Sharpen'] ?? 0.0,
  shadow: colorParamInitValues['Shadow'] ?? 0.0,
  temperature: colorParamInitValues['Temperature'] ?? 0.0,
  noise: colorParamInitValues['Noise'] ?? 0.0,
  exposure: colorParamInitValues['Exposure'] ?? 0.0,
  vibrance: colorParamInitValues['Vibrance'] ?? 0.0,
  highlight: colorParamInitValues['Highlight'] ?? 0.0,
  wbRed: colorParamInitValues['Red'] ?? 0.0,
  wbGreen: colorParamInitValues['Green'] ?? 0.0,
  wbBlue: colorParamInitValues['Blue'] ?? 0.0,
  vigX: colorParamInitValues['CenterX'] ?? 0.0,
  vigY: colorParamInitValues['CenterY'] ?? 0.0,
  vigStart: colorParamInitValues['Start'] ?? 0.0,
  vigEnd: colorParamInitValues['End'] ?? 0.0,
  // hue: _paramInitValues['Hue'] ?? 0.0,
  /// opacity
  // opacity: colorParamInitValues['Opacity'] ?? 1.0,
  /////////////////////////////////#min#/////////////////////////////
  brightnessMin: colorParamMinValues['BrightnessMin'] ?? 0.0,

  /// ok
  saturationMin: colorParamMinValues['SaturationMin'] ?? 0.0,

  /// ok
  contrastMin: colorParamMinValues['ContrastMin'] ?? 0.0,

  /// ok
  sharpenMin: colorParamMinValues['SharpenMin'] ?? 0.0,

  ///ok
  shadowMin: colorParamMinValues['ShadowMin'] ?? 0.0,

  ///ok
  temperatureMin: colorParamMinValues['TemperatureMin'] ?? 0.0,

  ///ok
  noiseMin: colorParamMinValues['NoiseMin'] ?? 0.0,

  ///ok
  exposureMin: colorParamMinValues['ExposureMin'] ?? 0.0,

  /// ok
  vibranceMin: colorParamMinValues['VibranceMin'] ?? 0.0,

  ///ok
  highlightMin: colorParamMinValues['HighlightMin'] ?? 0.0,

  ///ok
  wbRedMin: colorParamMinValues['RedMin'] ?? 0.0,

  ///ok
  wbGreenMin: colorParamMinValues['GreenMin'] ?? 0.0,

  ///ok
  wbBlueMin: colorParamMinValues['BlueMin'] ?? 0.0,

  ///ok
  vigXMin: colorParamMinValues['CenterXMin'] ?? 0.0,

  ///ok
  vigYMin: colorParamMinValues['CenterYMin'] ?? 0.0,

  ///ok
  vigStartMin: colorParamMinValues['StartMin'] ?? 0.0,

  ///ok
  vigEndMin: colorParamMinValues['EndMin'] ?? 0.0,

  ///ok
  // hueMin: colorParamMinValues['HueMin'] ?? 0.0,

  /// opacity
  // opacityMin: colorParamMinValues['OpacityMin'] ?? 0.0,

  /////////////////////////////////#max#/////////////////////////////
  brightnessMax: colorParamMaxValues['BrightnessMax'] ?? 0.0,

  /// ok
  saturationMax: colorParamMaxValues['SaturationMax'] ?? 0.0,

  /// ok
  contrastMax: colorParamMaxValues['ContrastMax'] ?? 0.0,

  /// ok
  sharpenMax: colorParamMaxValues['SharpenMax'] ?? 0.0,

  ///ok
  shadowMax: colorParamMaxValues['ShadowMax'] ?? 0.0,

  ///ok
  temperatureMax: colorParamMaxValues['TemperatureMax'] ?? 0.0,

  ///ok
  noiseMax: colorParamMaxValues['NoiseMax'] ?? 0.0,

  ///ok
  exposureMax: colorParamMaxValues['ExposureMax'] ?? 0.0,

  /// ok
  vibranceMax: colorParamMaxValues['VibranceMax'] ?? 0.0,

  ///ok
  highlightMax: colorParamMaxValues['HighlightMax'] ?? 0.0,

  wbRedMax: colorParamMaxValues['RedMax'] ?? 0.0,

  ///ok
  wbGreenMax: colorParamMaxValues['GreenMax'] ?? 0.0,

  ///ok
  wbBlueMax: colorParamMaxValues['BlueMax'] ?? 0.0,

  ///ok
  vigXMax: colorParamMaxValues['CenterXMax'] ?? 0.0,

  ///ok
  vigYMax: colorParamMaxValues['CenterYMax'] ?? 0.0,

  ///ok
  vigStartMax: colorParamMaxValues['StartMax'] ?? 0.0,

  ///ok
  vigEndMax: colorParamMaxValues['EndMax'] ?? 0.0,

  ///ok
  // hueMax: colorParamMaxValues['HueMax'] ?? 0.0,

  /// opacity
  // opacityMax: colorParamMaxValues['OpacityMax'] ?? 1.0,
);

final ColorsMulitConfiguration finalConfig2 = ColorsMulitConfiguration(
  /////////////////////////////////#init#/////////////////////////////
  brightness: colorParamInitValues['Brightness'] ?? 0.0,
  saturation: colorParamInitValues['Saturation'] ?? 0.0,
  contrast: colorParamInitValues['Contrast'] ?? 0.0,
  sharpen: colorParamInitValues['Sharpen'] ?? 0.0,
  shadow: colorParamInitValues['Shadow'] ?? 0.0,
  temperature: colorParamInitValues['Temperature'] ?? 0.0,
  noise: colorParamInitValues['Noise'] ?? 0.0,
  exposure: colorParamInitValues['Exposure'] ?? 0.0,
  vibrance: colorParamInitValues['Vibrance'] ?? 0.0,
  highlight: colorParamInitValues['Highlight'] ?? 0.0,
  wbRed: colorParamInitValues['Red'] ?? 0.0,
  wbGreen: colorParamInitValues['Green'] ?? 0.0,
  wbBlue: colorParamInitValues['Blue'] ?? 0.0,
  vigX: colorParamInitValues['CenterX'] ?? 0.0,
  vigY: colorParamInitValues['CenterY'] ?? 0.0,
  vigStart: colorParamInitValues['Start'] ?? 0.0,
  vigEnd: colorParamInitValues['End'] ?? 0.0,
  // hue: _paramInitValues['Hue'] ?? 0.0,
  /// opacity
  // opacity: colorParamInitValues['Opacity'] ?? 1.0,
  /////////////////////////////////#min#/////////////////////////////
  brightnessMin: colorParamMinValues['BrightnessMin'] ?? 0.0,

  /// ok
  saturationMin: colorParamMinValues['SaturationMin'] ?? 0.0,

  /// ok
  contrastMin: colorParamMinValues['ContrastMin'] ?? 0.0,

  /// ok
  sharpenMin: colorParamMinValues['SharpenMin'] ?? 0.0,

  ///ok
  shadowMin: colorParamMinValues['ShadowMin'] ?? 0.0,

  ///ok
  temperatureMin: colorParamMinValues['TemperatureMin'] ?? 0.0,

  ///ok
  noiseMin: colorParamMinValues['NoiseMin'] ?? 0.0,

  ///ok
  exposureMin: colorParamMinValues['ExposureMin'] ?? 0.0,

  /// ok
  vibranceMin: colorParamMinValues['VibranceMin'] ?? 0.0,

  ///ok
  highlightMin: colorParamMinValues['HighlightMin'] ?? 0.0,

  ///ok
  wbRedMin: colorParamMinValues['RedMin'] ?? 0.0,

  ///ok
  wbGreenMin: colorParamMinValues['GreenMin'] ?? 0.0,

  ///ok
  wbBlueMin: colorParamMinValues['BlueMin'] ?? 0.0,

  ///ok
  vigXMin: colorParamMinValues['CenterXMin'] ?? 0.0,

  ///ok
  vigYMin: colorParamMinValues['CenterYMin'] ?? 0.0,

  ///ok
  vigStartMin: colorParamMinValues['StartMin'] ?? 0.0,

  ///ok
  vigEndMin: colorParamMinValues['EndMin'] ?? 0.0,

  ///ok
  // hueMin: colorParamMinValues['HueMin'] ?? 0.0,

  /// opacity
  // opacityMin: colorParamMinValues['OpacityMin'] ?? 0.0,

  /////////////////////////////////#max#/////////////////////////////
  brightnessMax: colorParamMaxValues['BrightnessMax'] ?? 0.0,

  /// ok
  saturationMax: colorParamMaxValues['SaturationMax'] ?? 0.0,

  /// ok
  contrastMax: colorParamMaxValues['ContrastMax'] ?? 0.0,

  /// ok
  sharpenMax: colorParamMaxValues['SharpenMax'] ?? 0.0,

  ///ok
  shadowMax: colorParamMaxValues['ShadowMax'] ?? 0.0,

  ///ok
  temperatureMax: colorParamMaxValues['TemperatureMax'] ?? 0.0,

  ///ok
  noiseMax: colorParamMaxValues['NoiseMax'] ?? 0.0,

  ///ok
  exposureMax: colorParamMaxValues['ExposureMax'] ?? 0.0,

  /// ok
  vibranceMax: colorParamMaxValues['VibranceMax'] ?? 0.0,

  ///ok
  highlightMax: colorParamMaxValues['HighlightMax'] ?? 0.0,

  wbRedMax: colorParamMaxValues['RedMax'] ?? 0.0,

  ///ok
  wbGreenMax: colorParamMaxValues['GreenMax'] ?? 0.0,

  ///ok
  wbBlueMax: colorParamMaxValues['BlueMax'] ?? 0.0,

  ///ok
  vigXMax: colorParamMaxValues['CenterXMax'] ?? 0.0,

  ///ok
  vigYMax: colorParamMaxValues['CenterYMax'] ?? 0.0,

  ///ok
  vigStartMax: colorParamMaxValues['StartMax'] ?? 0.0,

  ///ok
  vigEndMax: colorParamMaxValues['EndMax'] ?? 0.0,

  ///ok
  // hueMax: colorParamMaxValues['HueMax'] ?? 0.0,

  /// opacity
  // opacityMax: colorParamMaxValues['OpacityMax'] ?? 1.0,
);


  Future<void> loadSourceImage(String afterPath) async {
    Uint8List fbyte = await BaseUtil.loadSourceImage(afterPath);
    final texture = await TextureSource.fromMemory(fbyte);
    textureSource.value = texture;
  }

  @override
  void onInit() {
    debugPrint('FilterColorsController --init');

    super.onInit();
  }

  @override
  void onClose() {
    finalConfig.dispose();
    super.onClose();
  }
}
