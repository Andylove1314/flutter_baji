import 'package:flutter/material.dart';

import '../../constants/constant.dart';
import '../../constants/constant_bj.dart';
import '../../painters/color_panel_painter.dart';

class SliderColorPicker extends StatefulWidget {
  final Function(Color) onColorChanged;
  final Color? initialPanelColor;
  final Color? initialPanelPositionColor;
  const SliderColorPicker(
      {super.key,
      required this.onColorChanged,
      this.initialPanelColor,
      this.initialPanelPositionColor});

  @override
  State<SliderColorPicker> createState() => _SliderColorPickerState();
}

class _SliderColorPickerState extends State<SliderColorPicker> {
  // 添加新的状态变量
  Offset _colorAreaPosition = const Offset(0, 0);
  Size _areaSize = Size.zero;

  late Color _currentSliderColor;
  double _sliderPosition = 0.0;

  Color _getColorAtPosition(double position, double maxWidth) {
    if (position <= 0) return sliderColors.first;
    if (position >= maxWidth) return sliderColors.last;

    final segmentWidth = maxWidth / (sliderColors.length - 1);
    final segment = (position / segmentWidth).floor();
    final segmentPosition = (position - segment * segmentWidth) / segmentWidth;

    return Color.lerp(
          sliderColors[segment],
          sliderColors[segment + 1],
          segmentPosition,
        ) ??
        Colors.white;
  }

  // 修改颜色计算方法
  Color _getColorFromArea() {
    // 获取基准色的 HSV 值
    HSVColor baseHsv = HSVColor.fromColor(_currentSliderColor);

    // 计算饱和度和明度
    double saturation =
        (_colorAreaPosition.dx / _areaSize.width).clamp(0.0, 1.0);
    double value =
        (1.0 - _colorAreaPosition.dy / _areaSize.height).clamp(0.0, 1.0);

    // 保持色相不变，调整饱和度和明度
    return HSVColor.fromAHSV(
      1.0,
      baseHsv.hue,
      saturation,
      value,
    ).toColor();
  }

  @override
  void initState() {
    super.initState();
    _currentSliderColor = widget.initialPanelColor ?? sliderColors.first;
  }

  bool _isFirstBuild = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 16,
          margin: const EdgeInsets.only(bottom: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const sliderWidth = 16.0;
              final maxSliderPosition = constraints.maxWidth - sliderWidth;

              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(details.globalPosition);
                      final newPosition = (localPosition.dx - sliderWidth / 2)
                          .clamp(0.0, maxSliderPosition);
                      setState(() {
                        _sliderPosition = newPosition;
                        _currentSliderColor = _getColorAtPosition(
                          newPosition,
                          maxSliderPosition,
                        );
                      });
                      widget.onColorChanged(_getColorFromArea());
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: sliderColors,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _sliderPosition.clamp(0, maxSliderPosition),
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _currentSliderColor = _getColorAtPosition(
                              _sliderPosition, maxSliderPosition);
                        });
                        widget.onColorChanged(_getColorFromArea());
                      },
                      onPanUpdate: (details) {
                        final newPosition = (_sliderPosition + details.delta.dx)
                            .clamp(0.0, maxSliderPosition);
                        setState(() {
                          _sliderPosition = newPosition;
                          _currentSliderColor = _getColorAtPosition(
                            newPosition,
                            maxSliderPosition,
                          );
                        });
                        widget.onColorChanged(_getColorFromArea());
                      },
                      child: _pointer(
                          width: sliderWidth,
                          backgroundColor: _currentSliderColor),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 颜色黑白调节区域
        Container(
          height: 111,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const pointerSize = 16.0;
              final maxX = constraints.maxWidth - (pointerSize / 2);
              final maxY = constraints.maxHeight - (pointerSize / 2);
              _areaSize = Size(maxX, maxY);

              // 在第一次布局完成后更新位置
              if (_isFirstBuild && widget.initialPanelPositionColor != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _colorAreaPosition = _fetchColorPositionWithColor(
                        widget.initialPanelPositionColor);
                    _isFirstBuild = false;
                  });
                });
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: ColorPanelPainter(
                      baseColor: _currentSliderColor,
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (details) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(details.globalPosition);
                      setState(() {
                        _colorAreaPosition = Offset(
                          (localPosition.dx - pointerSize / 2)
                              .clamp(-pointerSize / 2, maxX),
                          (localPosition.dy - pointerSize / 2)
                              .clamp(-pointerSize / 2, maxY),
                        );
                      });
                      final color = _getColorFromArea();
                      widget.onColorChanged(color);
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    left: _colorAreaPosition.dx.clamp(-pointerSize / 2, maxX),
                    top: _colorAreaPosition.dy.clamp(-pointerSize / 2, maxY),
                    child: GestureDetector(
                      onPanStart: (details) {
                        final color = _getColorFromArea();
                        widget.onColorChanged(color);
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _colorAreaPosition = Offset(
                            (_colorAreaPosition.dx + details.delta.dx)
                                .clamp(-pointerSize / 2, maxX),
                            (_colorAreaPosition.dy + details.delta.dy)
                                .clamp(-pointerSize / 2, maxY),
                          );
                        });
                        final color = _getColorFromArea();
                        widget.onColorChanged(color);
                      },
                      child: _pointer(
                          width: pointerSize,
                          backgroundColor: _getColorFromArea()),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pointer({width = 16.0, required Color backgroundColor}) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor, // 添加白色背景遮挡内部阴影
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 0, // 控制阴影扩散范围
          ),
        ],
      ),
    );
  }

  /// 根据颜色获取位置
  Offset _fetchColorPositionWithColor(Color? color) {
    if (color == null) return const Offset(0, 0);

    // 转换为 HSV 颜色空间
    HSVColor hsvColor = HSVColor.fromColor(color);
    HSVColor baseColor = HSVColor.fromColor(_currentSliderColor);

    // 计算白色和黑色的混合比例
    double whiteness = 1.0 - hsvColor.saturation;
    double blackness = 1.0 - hsvColor.value;

    // 根据混合比例计算位置
    return Offset(
      _areaSize.width * (1.0 - whiteness),
      _areaSize.height * blackness,
    );
  }
}
