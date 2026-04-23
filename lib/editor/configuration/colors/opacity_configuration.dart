part of '../../../flutter_baji.dart';

/// Describes opacity (transparency) manipulations
class OpacityShaderConfiguration extends ShaderConfiguration {
  final NumberParameter _opacity;

  /// Creates a configuration for controlling image opacity.
  ///
  /// The [opacity] value should be between [opacityMin] and [opacityMax],
  /// typically from `0.0` (fully transparent) to `1.0` (fully opaque).
  OpacityShaderConfiguration({
    required double opacity,
    required double opacityMin,
    required double opacityMax,
  })  : _opacity = ShaderRangeNumberParameter(
          'Opacity',
          '透明度',
          opacity,
          0,
          min: opacityMin,
          max: opacityMax,
        ),
        super([opacity]);

  /// Updates the [opacity] value.
  ///
  /// The [value] must be within the valid [opacityMin]–[opacityMax] range.
  set opacity(double value) {
    _opacity.value = value;
    _opacity.update(this);
  }

  @override
  List<ConfigurationParameter> get parameters => [_opacity];
}
