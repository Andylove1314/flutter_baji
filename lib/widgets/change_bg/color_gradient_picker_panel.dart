import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';
import 'color_slider_picker.dart';

enum GradientType {
  linear,
  radial,
}

class ColorGradientPickerPanel extends StatefulWidget {
  final Function(GradientType type, List<Color> colors, List<double> stops)?
      onGradientColorChanged; // 颜色改变回调

  const ColorGradientPickerPanel({
    super.key,
    required this.onGradientColorChanged,
  });

  @override
  State<ColorGradientPickerPanel> createState() =>
      _ColorGradientPickerPanelState();
}

class _ColorGradientPickerPanelState extends State<ColorGradientPickerPanel> {
  late GradientType _currentType;
  // 渐变控制点初始化位置
  double _startPosition = 0.0;
  double _endPosition = 1.0;
  // 渐变颜色的占比
  double _startStop = 0.0;
  double _endStop = 1.0;
  // 渐变颜色
  Color _startColor = const Color(0xffeeeeee);
  Color _endColor = const Color(0xffd8d8d8);
  final Color _startInitPositionColor = const Color(0xffeeeeee);
  final Color _endInitPositionColor = const Color(0xffd8d8d8);

  int _editingIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentType = GradientType.linear;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 渐变类型选择
            _typeButtons(),
            // 渐变位置调节
            _gradientSlider().marginOnly(top: 10, bottom: 20),
            // 颜色选择器
            IndexedStack(
              index: _editingIndex,
              children: [
                SliderColorPicker(
                  initialPanelPositionColor: _startInitPositionColor,
                  onColorChanged: (color) {
                    debugPrint('start color: $color');
                    setState(() {
                      _startColor = color;
                    });
                    _refreshGradient();
                  },
                ),
                SliderColorPicker(
                  initialPanelPositionColor: _endInitPositionColor,
                  onColorChanged: (color) {
                    debugPrint('end color: $color');
                    setState(() {
                      _endColor = color;
                    });
                    _refreshGradient();
                  },
                )
              ],
            )
          ],
        ));
  }

  Widget _buildTypeButton(GradientType type, String text) {
    final isSelected = type == _currentType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentType = type;
        });
        _refreshGradient();
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              gradient: type == GradientType.linear
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffEEEEEE), Color(0XFF999999)])
                  : const RadialGradient(
                      center: Alignment.center,
                      radius: 0.7,
                      colors: [Color(0xffEEEEEE), Color(0XFF999999)],
                    ),
              border: Border.all(
                color: isSelected
                    ? Color(0xffFF1A5A)
                    : const Color(0xffB8B8B8),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff969799),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeButton(GradientType.linear, '线性'),
            const SizedBox(width: 32),
            _buildTypeButton(GradientType.radial, '径向')
          ],
        ),
        IconButton(
          onPressed: () {
            //todo
          },
          icon: Image.asset(
            'icon_cancel_shadow'.imageBjPng,
            width: 20,
          ),
        )
      ],
    );
  }

  Widget _gradientSlider() {
    return Container(
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
                  final percentage =
                      (localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);

                  // 根据点击位置更新最近的渐变范围和滑块位置
                  if ((percentage - _startStop).abs() <
                      (percentage - _endStop).abs()) {
                    setState(() {
                      _startStop = percentage;
                      _startPosition = percentage;
                      _editingIndex = 0;
                    });
                  } else {
                    setState(() {
                      _endStop = percentage;
                      _endPosition = percentage;
                      _editingIndex = 1;
                    });
                  }
                  _refreshGradient();
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xff979797), width: 1),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: _startStop <= _endStop
                            ? [_startColor, _endColor]
                            : [_endColor, _startColor],
                        stops: _startStop <= _endStop
                            ? [_startStop, _endStop]
                            : [_endStop, _startStop],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _startStop * maxSliderPosition,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _editingIndex = _startStop <= _endStop ? 0 : 1;
                    });
                  },
                  onPanUpdate: (details) {
                    final newStop =
                        (_startStop + details.delta.dx / constraints.maxWidth)
                            .clamp(0.0, 1.0);
                    setState(() {
                      if (_startStop <= _endStop && newStop > _endStop ||
                          _startStop >= _endStop && newStop < _endStop) {
                        final tempColor = _startColor;
                        _startColor = _endColor;
                        _endColor = tempColor;
                        _editingIndex = _editingIndex == 0 ? 1 : 0;
                      }
                      _startStop = newStop;
                    });
                    _refreshGradient();
                  },
                  child: _pointer(
                      _editingIndex == (_startStop <= _endStop ? 0 : 1),
                      _startStop <= _endStop ? _startColor : _startColor,
                      width: sliderWidth),
                ),
              ),
              Positioned(
                left: _endStop * maxSliderPosition,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _editingIndex = _startStop <= _endStop ? 1 : 0;
                    });
                  },
                  onPanUpdate: (details) {
                    final newStop =
                        (_endStop + details.delta.dx / constraints.maxWidth)
                            .clamp(0.0, 1.0);
                    setState(() {
                      if (_endStop <= _startStop && newStop > _startStop ||
                          _endStop >= _startStop && newStop < _startStop) {
                        final tempColor = _startColor;
                        _startColor = _endColor;
                        _endColor = tempColor;
                        _editingIndex = _editingIndex == 0 ? 1 : 0;
                      }
                      _endStop = newStop;
                    });
                    _refreshGradient();
                  },
                  child: _pointer(
                      _editingIndex == (_startStop <= _endStop ? 1 : 0),
                      _startStop <= _endStop ? _endColor : _endColor,
                      width: sliderWidth),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 刷新外部渐变
  void _refreshGradient() {
    widget.onGradientColorChanged?.call(
      _currentType,
      _startStop <= _endStop
          ? [_startColor, _endColor]
          : [_endColor, _startColor],
      _startStop <= _endStop ? [_startStop, _endStop] : [_endStop, _startStop],
    );
  }
}

Widget _pointer(bool active, Color backgroundColor, {width = 16.0}) {
  return Container(
    width: width,
    height: width,
    decoration: BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 4),
      boxShadow: [
        BoxShadow(
          color: active
              ?  Color(0xffFF1A5A).withOpacity(0.4)
              : const Color(0xffD8D8D8).withOpacity(0.4),
          offset: const Offset(0, 0),
          blurRadius: 2,
        ),
      ],
    ),
  );
}
