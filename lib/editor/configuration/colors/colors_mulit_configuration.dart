part of '../../../flutter_baji.dart';

/// Describes brightness, saturation, contrast, sharpen, shadow, temperature,
/// noise, exposure, vibrance, highlight, white balance, vignette and opacity manipulation
class ColorsMulitConfiguration extends ShaderConfiguration {
  final NumberParameter _brightness;
  final NumberParameter _saturation;
  final NumberParameter _contrast;
  final NumberParameter _sharpen;
  final NumberParameter _shadow;
  final NumberParameter _temperature;
  final NumberParameter _noise;
  final NumberParameter _exposure;
  final NumberParameter _vibrance;
  final NumberParameter _highlight;
  final NumberParameter _redBalance;
  final NumberParameter _greenBalance;
  final NumberParameter _blueBalance;
  final NumberParameter _centerX;
  final NumberParameter _centerY;
  final NumberParameter _start;
  final NumberParameter _end;
  // final NumberParameter _opacity; // ✅ 新增透明度参数

  ColorsMulitConfiguration({
    required double brightness,
    required double brightnessMin,
    required double brightnessMax,
    required double saturation,
    required double saturationMin,
    required double saturationMax,
    required double contrast,
    required double contrastMin,
    required double contrastMax,
    required double sharpen,
    required double sharpenMin,
    required double sharpenMax,
    required double shadow,
    required double shadowMin,
    required double shadowMax,
    required double temperature,
    required double temperatureMin,
    required double temperatureMax,
    required double noise,
    required double noiseMin,
    required double noiseMax,
    required double exposure,
    required double exposureMin,
    required double exposureMax,
    required double vibrance,
    required double vibranceMin,
    required double vibranceMax,
    required double highlight,
    required double highlightMin,
    required double highlightMax,
    required double wbRed,
    required double wbRedMin,
    required double wbRedMax,
    required double wbGreen,
    required double wbGreenMin,
    required double wbGreenMax,
    required double wbBlue,
    required double wbBlueMin,
    required double wbBlueMax,
    required double vigX,
    required double vigY,
    required double vigStart,
    required double vigEnd,
    required double vigXMin,
    required double vigYMin,
    required double vigStartMin,
    required double vigEndMin,
    required double vigXMax,
    required double vigYMax,
    required double vigStartMax,
    required double vigEndMax,
    // required double opacity, // ✅ 新增
    // required double opacityMin,
    // required double opacityMax,
  })  : _brightness = ShaderRangeNumberParameter(
          'Brightness', '亮度', brightness, 0,
          min: brightnessMin, max: brightnessMax),
        _saturation = ShaderRangeNumberParameter(
          'Saturation', '饱和度', saturation, 1,
          min: saturationMin, max: saturationMax),
        _contrast = ShaderRangeNumberParameter(
          'Contrast', '对比度', contrast, 2,
          min: contrastMin, max: contrastMax),
        _sharpen = ShaderRangeNumberParameter(
          'Sharpen', '锐化', sharpen, 3,
          min: sharpenMin, max: sharpenMax),
        _shadow = ShaderRangeNumberParameter(
          'Shadow', '阴影', shadow, 4,
          min: shadowMin, max: shadowMax),
        _temperature = ShaderRangeNumberParameter(
          'Temperature', '色温', temperature, 5,
          min: temperatureMin, max: temperatureMax),
        _noise = ShaderRangeNumberParameter(
          'Noise', '噪点', noise, 6,
          min: noiseMin, max: noiseMax),
        _exposure = ShaderRangeNumberParameter(
          'Exposure', '曝光', exposure, 7,
          min: exposureMin, max: exposureMax),
        _vibrance = ShaderRangeNumberParameter(
          'Vibrance', '鲜艳度', vibrance, 8,
          min: vibranceMin, max: vibranceMax),
        _highlight = ShaderRangeNumberParameter(
          'Highlight', '高光', highlight, 9,
          min: highlightMin, max: highlightMax),
        _redBalance = ShaderRangeNumberParameter(
          'Red', '红色平衡', wbRed, 10,
          min: wbRedMin, max: wbRedMax),
        _greenBalance = ShaderRangeNumberParameter(
          'Green', '绿色平衡', wbGreen, 11,
          min: wbGreenMin, max: wbGreenMax),
        _blueBalance = ShaderRangeNumberParameter(
          'Blue', '蓝色平衡', wbBlue, 12,
          min: wbBlueMin, max: wbBlueMax),
        _centerX = ShaderRangeNumberParameter(
          'CenterX', '左右', vigX, 13,
          min: vigXMin, max: vigXMax),
        _centerY = ShaderRangeNumberParameter(
          'CenterY', '上下', vigY, 14,
          min: vigYMin, max: vigYMax),
        _start = ShaderRangeNumberParameter(
          'Start', '大小', vigStart, 15,
          min: vigStartMin, max: vigStartMax),
        _end = ShaderRangeNumberParameter(
          'End', '外延', vigEnd, 16,
          min: vigEndMin, max: vigEndMax),
        // _opacity = ShaderRangeNumberParameter( // ✅ 新增透明度参数
        //   'Opacity', '透明度', opacity, 17,
        //   min: opacityMin, max: opacityMax),
        super([
          brightness,
          saturation,
          contrast,
          sharpen,
          shadow,
          temperature,
          noise,
          exposure,
          vibrance,
          highlight,
          wbRed,
          wbGreen,
          wbBlue,
          vigX,
          vigY,
          vigStart,
          vigEnd,
          // opacity, // ✅ 新增
        ]);

  set brightness(double value) => _setValue(_brightness, value);
  set saturation(double value) => _setValue(_saturation, value);
  set contrast(double value) => _setValue(_contrast, value);
  set sharpen(double value) => _setValue(_sharpen, value);
  set shadow(double value) => _setValue(_shadow, value);
  set temperature(double value) => _setValue(_temperature, value);
  set noise(double value) => _setValue(_noise, value);
  set exposure(double value) => _setValue(_exposure, value);
  set vibrance(double value) => _setValue(_vibrance, value);
  set highlight(double value) => _setValue(_highlight, value);
  set redBalance(double value) => _setValue(_redBalance, value);
  set greenBalance(double value) => _setValue(_greenBalance, value);
  set blueBalance(double value) => _setValue(_blueBalance, value);
  set centerX(double value) => _setValue(_centerX, value);
  set centerY(double value) => _setValue(_centerY, value);
  set start(double value) => _setValue(_start, value);
  set end(double value) => _setValue(_end, value);
  // set opacity(double value) => _setValue(_opacity, value); // ✅ 新增 setter

  void _setValue(NumberParameter param, double value) {
    param.value = value;
    param.update(this);
  }

  @override
  List<ConfigurationParameter> get parameters => [
        _brightness,
        _saturation,
        _contrast,
        _sharpen,
        _shadow,
        _temperature,
        _noise,
        _exposure,
        _vibrance,
        _highlight,
        _redBalance,
        _greenBalance,
        _blueBalance,
        _centerX,
        _centerY,
        _start,
        _end,
        // _opacity, // ✅ 新增到参数列表
      ];
}
