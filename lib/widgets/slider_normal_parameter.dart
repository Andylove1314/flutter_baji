import 'package:flutter/material.dart';

class SliderNormalParameterWidget extends StatefulWidget {
  final Function(double value) onChanged;
  final double initValue;
  final int showNumber;
  final double max;
  final double min;
  final Color lineColor;

  SliderNormalParameterWidget(
      {super.key,
      required this.onChanged,
      this.initValue = 1.0,
      required this.max,
      required this.min,
      this.showNumber = 100,
      this.lineColor = Colors.black});

  @override
  State<StatefulWidget> createState() {
    return _SliderNormalParameterWidgetState();
  }
}

class _SliderNormalParameterWidgetState
    extends State<SliderNormalParameterWidget> {
  final sliderSize = 22.0;
  final _thumbLineHeight = 4.0;

  var _lineLeft;
  var strokeRatio;
  double _sliderW = 0;

  @override
  void didUpdateWidget(covariant SliderNormalParameterWidget oldWidget) {
    // 当初始值发生变化时，更新滑块位置
    if (widget.initValue != oldWidget.initValue) {
      setState(() {
        // 重新计算滑块位置
        strokeRatio = (widget.max - widget.min) / (_sliderW - sliderSize);
        _lineLeft = (widget.initValue - widget.min) / strokeRatio;

        // 确保滑块不会超出边界
        if (_lineLeft < 0) _lineLeft = 0;
        if (_lineLeft > _sliderW - sliderSize)
          _lineLeft = _sliderW - sliderSize;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateSliderMetrics(double width) {
    _sliderW = width;
    if (_lineLeft == null) {
      strokeRatio = (widget.max - widget.min) / (width - sliderSize);
      // 根据初始值计算滑块位置
      _lineLeft = (widget.initValue - widget.min) / strokeRatio;
      if (_lineLeft < 0) _lineLeft = 0;
      if (_lineLeft > width - sliderSize) _lineLeft = width - sliderSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sliderSize,
      width: double.infinity,
      child: LayoutBuilder(builder: (context, constraints) {
        _updateSliderMetrics(constraints.maxWidth);
        return Stack(alignment: Alignment.centerLeft, children: [
          Container(
            height: _thumbLineHeight,
            width: _sliderW,
            decoration: BoxDecoration(
              color: widget.lineColor,
              borderRadius: BorderRadius.circular(_thumbLineHeight),
            ),
          ),
          Positioned(
            left: _lineLeft,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _slide(details.delta.dx);
              },
              child: Container(
                  height: sliderSize,
                  width: sliderSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  )),
            ),
          ),
        ]);
      }),
    );
  }

  void _slide(double delta, {bool set = false}) {
    if (set) {
      _lineLeft = delta;
    } else {
      _lineLeft += delta;
    }

    ///贴边限制
    if (_lineLeft <= 0.0) {
      _lineLeft = 0.0;
    }
    if (_lineLeft >= _sliderW - sliderSize) {
      _lineLeft = _sliderW - sliderSize;
    }
    if (!set) {
      widget.onChanged.call(widget.min + strokeRatio * _lineLeft);
    }

    setState(() {});
  }
}
