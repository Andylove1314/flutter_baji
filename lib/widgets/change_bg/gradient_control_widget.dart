import 'package:flutter/material.dart';

import '../../painters/gradient_control_painter.dart';
import 'color_gradient_picker_panel.dart';

class GradientControlWidget extends StatefulWidget {
  final Function(GradientType type, List<double> stops, Offset gradientStart,
      Offset gradientEnd)? onGradientColorChanged;

  final List<Color> bgColors;
  final List<double> bgStops;
  final double marginLeft;
  final double marginRight;
  final GradientType gradientType;
  final double cardRatio;

  GradientControlWidget({
    Key? key,
    this.onGradientColorChanged,
    required this.bgColors,
    required this.bgStops,
    required this.marginLeft,
    required this.marginRight,
    this.gradientType = GradientType.linear,
    this.cardRatio = 1.0,
  }) : super(key: key);

  @override
  State<GradientControlWidget> createState() => _GradientControlWidgetState();
}

class _GradientControlWidgetState extends State<GradientControlWidget> {
  Offset _startPoint = Offset.zero;
  Offset _endPoint = Offset.zero;
  double _startStop = 0.0;
  double _endStop = 1.0;
  Color _startColor = Colors.transparent;
  Color _endColor = Colors.transparent;
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;
  final _pointSize = 16.0;

  double? _width;
  double? _height;

  void _initPoints() {
    final oldStartPoint = _startPoint;
    final oldEndPoint = _endPoint;
    final oldAngle = _startPoint != Offset.zero
        ? (oldEndPoint - oldStartPoint).direction
        : 0.0;

    final adjustedWidth = _width! - widget.marginLeft - widget.marginRight;
    final adjustedHeight = adjustedWidth / widget.cardRatio;
    final centerX = widget.marginLeft + adjustedWidth / 2;
    final centerY = _height! / 2;

    if (widget.gradientType == GradientType.linear) {
      if (_startPoint == Offset.zero) {
        final startY = centerY + (widget.bgStops[0] - 0.5) * adjustedHeight + _pointSize / 2;
        final endY = centerY + (widget.bgStops[1] - 0.5) * adjustedHeight - _pointSize / 2;
        _startPoint = Offset(centerX, startY);
        _endPoint = Offset(centerX, endY);
      } else if (_startStop != widget.bgStops[0]) {
        final newDistance = (widget.bgStops[1] - widget.bgStops[0]) * adjustedHeight;
        _endPoint = oldEndPoint;
        _startPoint = _endPoint - Offset.fromDirection(oldAngle, newDistance);
        _startStop = widget.bgStops[0];
      } else if (_endStop != widget.bgStops[1]) {
        final newDistance = (widget.bgStops[1] - widget.bgStops[0]) * adjustedHeight;
        _startPoint = oldStartPoint;
        _endPoint = _startPoint + Offset.fromDirection(oldAngle, newDistance);
        _endStop = widget.bgStops[1];
      }
    } else {
      if (_startPoint == Offset.zero) {
        final startY = centerY + (widget.bgStops[0] - 0.5) * adjustedWidth + _pointSize / 2;
        final endY = centerY + (widget.bgStops[1] - 0.5) * adjustedWidth - _pointSize / 2;
        _startPoint = Offset(centerX, startY);
        _endPoint = Offset(centerX, endY);
      } else if (_startStop != widget.bgStops[0]) {
        final newDistance = (widget.bgStops[1] - widget.bgStops[0]) * adjustedWidth;
        _endPoint = oldEndPoint;
        _startPoint = _endPoint - Offset.fromDirection(oldAngle, newDistance);
        _startStop = widget.bgStops[0];
      } else if (_endStop != widget.bgStops[1]) {
        final newDistance = (widget.bgStops[1] - widget.bgStops[0]) * adjustedWidth;
        _startPoint = oldStartPoint;
        _endPoint = _startPoint + Offset.fromDirection(oldAngle, newDistance);
        _endStop = widget.bgStops[1];
      }
    }

    _startColor = widget.bgColors[0];
    _endColor = widget.bgColors[1];
  }

  @override
  void didUpdateWidget(covariant GradientControlWidget oldWidget) {
    if (oldWidget.gradientType != widget.gradientType) {
      if (_startPoint == Offset.zero && _endPoint == Offset.zero) {
        _initPoints();
      }
    } else if (oldWidget.bgStops != widget.bgStops) {
      if (!_isDraggingStart && !_isDraggingEnd) {
        _initPoints();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateStops() {
    final adjustedWidth = _width! - widget.marginLeft - widget.marginRight;
    final adjustedHeight = adjustedWidth / widget.cardRatio;
    final centerY = _height! / 2;
    
    _startStop = ((_startPoint.dy - centerY) / adjustedHeight + 0.5).clamp(0.0, 1.0);
    _endStop = ((_endPoint.dy - centerY) / adjustedHeight + 0.5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('startStop: $_startStop, endStop: $_endStop');
    return LayoutBuilder(builder: (context, constrainedBox) {
      if (_width == null && _height == null) {
        _width = constrainedBox.maxWidth;
        _height = constrainedBox.maxHeight;
        _initPoints();
      }

      return Stack(
        children: [
          CustomPaint(
            painter: GradientControlPainter(
                startPoint: _startPoint, endPoint: _endPoint),
          ),
          Positioned(
            left: _startPoint.dx - 8,
            top: _startPoint.dy - 8,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isDraggingStart = true),
              onPanEnd: (_) => setState(() => _isDraggingStart = false),
              onPanUpdate: (details) {
                setState(() {
                  _startPoint += details.delta;
                  _updateStops();
                });
                _refreshGradient();
              },
              child: _pointer(_isDraggingStart, widget.bgColors[0]),
            ),
          ),
          Positioned(
            left: _endPoint.dx - 8,
            top: _endPoint.dy - 8,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isDraggingEnd = true),
              onPanEnd: (_) => setState(() => _isDraggingEnd = false),
              onPanUpdate: (details) {
                setState(() {
                  _endPoint += details.delta;
                  _updateStops();
                });
                _refreshGradient();
              },
              child: _pointer(_isDraggingEnd, widget.bgColors[1]),
            ),
          ),
        ],
      );
    });
  }

  void _refreshGradient() {
    widget.onGradientColorChanged?.call(
      widget.gradientType,
      _startStop <= _endStop ? [_startStop, _endStop] : [_endStop, _startStop],
      _startPoint,
      _endPoint,
    );
  }

  Widget _pointer(bool active, Color backgroundColor, {double? width}) {
    return Container(
      width: width ?? _pointSize,
      height: width ?? _pointSize,
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
}
