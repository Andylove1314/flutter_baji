import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_baji/constants/constant_editor.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_gpu_filters_interface/flutter_gpu_filters_interface.dart';

class FilterImageWidget extends StatefulWidget {
  final String path;
  final double opacity;
  EffectData? effectData;

  FilterImageWidget({
    super.key,
    required this.path,
    this.effectData,
    this.opacity = 1.0,
  });

  @override
  State<StatefulWidget> createState() {
    return FilterImageWidgetState();
  }
}

class FilterImageWidgetState extends State<FilterImageWidget> {
  TextureSource? _textureSource;
  double _opacity = 1.0;
  final ColorsMulitConfiguration _finalConfig = ColorsMulitConfiguration(
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

  Future<void> _loadSourceImage(String afterPath) async {
    Uint8List fbyte = await BaseUtil.loadSourceImage(afterPath);
    final texture = await TextureSource.fromMemory(fbyte);
    _textureSource = texture;
  }

  @override
  initState() {
    _opacity = widget.opacity;
    _loadSourceImage(widget.path).then((v) {
      _applyEffect(widget.effectData);
      setState(() {});
    });

    super.initState();
  }

  @override
  dispose() {
    _finalConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_textureSource != null)
        ? Opacity(
            opacity: _opacity,
            child: ImageShaderPreview(
              texture: _textureSource!,
              configuration: _finalConfig,
            ),
          )
        : BaseUtil.loadingWidget(isLight: false);
  }

  void _applyEffect(EffectData? effectData) {
    if (effectData != null && effectData.params.isNotEmpty) {
      for (ConfigurationParameter p in _finalConfig.parameters) {
        (p as NumberParameter).value = effectData.paramGroup[p.name] ?? 0.0;
        p.update(_finalConfig);
      }
    } else {
      for (ConfigurationParameter p in _finalConfig.parameters) {
        (p as NumberParameter).value = colorParamInitValues[p.name] ?? 0.0;
        p.update(_finalConfig);
      }
    }
  }

  @override
  void didUpdateWidget(covariant FilterImageWidget oldWidget) {
    if (widget.path != oldWidget.path) {
      _loadSourceImage(widget.path).then((v) {
        _applyEffect(widget.effectData);
        setState(() {});
      });
    } else if (widget.effectData != oldWidget.effectData) {
      _applyEffect(widget.effectData);
      setState(() {});
    } else if (widget.opacity != oldWidget.opacity) {
      _opacity = widget.opacity;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 供外部调用的导出方法
  /// 返回导出的图片路径
  Future<String> exportImage() async {
    if (_textureSource == null) {
      debugPrint('Export failed: TextureSource is null.');
      return '';
    }

    try {
      final exportPath = await BaseUtil.exportFilterImage(
        context,
        // 使用当前 State 中的 Shader Configuration
        _finalConfig,
        // 使用当前 State 中已加载的 TextureSource
        texture: _textureSource,
        // 传递 Opacity 参数（如果 BaseUtil.exportFilterImage 支持）
        opacity: widget.opacity,
      );
      return exportPath;
    } catch (e) {
      debugPrint('Error exporting image: $e');
      return '';
    }
  }
}
