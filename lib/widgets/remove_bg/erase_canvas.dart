import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../utils/base_util.dart';

class ErasePoint {
  final Offset? point;
  final double width;

  ErasePoint(this.point, this.width);
}

class EraseCanvas extends StatefulWidget {
  final String imagePath;
  final Function(Offset? position)? onEraseStart;
  final VoidCallback? onEraseEnd;
  final Function(PointerEvent event)? onMultiTouch; // 添加多指触摸回调
  final bool enable;
  final bool clearMode;
  final double imageOpacity;
  final Color imgColor;

  const EraseCanvas({
    Key? key,
    required this.imagePath,
    required this.imageOpacity,
    this.onEraseStart,
    this.onEraseEnd,
    this.onMultiTouch,
    this.enable = true,
    this.clearMode = true,
    this.imgColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<EraseCanvas> createState() => EraseCanvasState();
}

class EraseCanvasState extends State<EraseCanvas> {
  ui.Image? _image;
  final List<List<ErasePoint>> _strokes = [];
  final List<List<ErasePoint>> _history = [];
  List<ErasePoint>? _currentStroke;
  Size? imageSize;
  double _clearPainterWidth = 25.0;
  Offset? _currentPosition;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant EraseCanvas oldWidget) {
    if (widget.imagePath != oldWidget.imagePath) {
      _loadImage();
    }
    super.didUpdateWidget(oldWidget);
  }

  void updatePainterWidth(double width) {
    setState(() {
      _clearPainterWidth = width;
    });
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: (ui.window.physicalSize.width * ui.window.devicePixelRatio)
            .toInt());
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());
    });
  }

  void _addPoint(Offset? point) {
    if (!mounted) return;
    setState(() {
      if (point != null) {
        final erasePoint = ErasePoint(point, _clearPainterWidth);
        if (_currentStroke == null) {
          _currentStroke = [];
          _strokes.add(_currentStroke!);
        }
        _currentStroke!.add(erasePoint);
      } else {
        if (_currentStroke != null) {
          _history.add(List.from(_currentStroke!));
          _currentStroke = null;
        }
      }
    });
  }

  void undo() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
        if (_history.isNotEmpty) {
          _history.removeLast();
        }
      }
    });
  }

  bool canUndo() {
    return _strokes.isNotEmpty;
  }

  void reset() {
    setState(() {
      _strokes.clear();
      _history.clear();
      _currentStroke = null;
    });
  }

  Future<ui.Image?> exportImage() async {
    if (_image == null || imageSize == null || context.size == null)
      return null;

    final scale = context.size!.width / imageSize!.width;
    final imageHeight = imageSize!.height * scale;
    final verticalOffset = (context.size!.height - imageHeight) / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final painter = ErasePainter(
      image: _image!,
      strokes: _strokes,
      scale: scale,
      offset: Offset(0, verticalOffset),
      clearMode: widget.clearMode,
      imageOpacity: widget.imageOpacity,
      imgColor: widget.imgColor,
    );

    painter.paint(canvas, context.size!);

    final picture = recorder.endRecording();

    // 将画布导出为图片
    return await picture.toImage(
      (context.size!.width).toInt(),
      (context.size!.height).toInt(),
    );
  }

  /// 导出png
  Future<Uint8List?> exportAsPngBytes() async {
    final image = await exportImage();
    if (image == null) return null;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // 添加触摸点计数
  int _activePointers = 0;

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enable) return;

    // 先增加计数
    _activePointers++;

    // 如果是第一个手指，先不要立即开始绘制，等待一小段时间确认是否有第二个手指
    if (_activePointers == 1) {
      Future.delayed(const Duration(milliseconds: 20), () {
        // 如果仍然是单指触摸，才开始绘制
        if (mounted && _activePointers == 1 && !_isDrawing) {
          _isDrawing = true;
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.globalToLocal(event.position);
          _updateErasePoint(position);
        }
      });
      return;
    }

    // 如果是多指触摸，停止绘制并触发回调
    if (_activePointers > 1) {
      _isDrawing = false;
      setState(() {
        _currentPosition = null;
        _addPoint(null);
      });
      widget.onEraseEnd?.call();
      widget.onMultiTouch?.call(event);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.enable) return;

    // 如果是多指触摸状态，直接触发回调并返回
    if (_activePointers > 1) {
      widget.onMultiTouch?.call(event);
      return;
    }

    // 只有在单指绘制状态下才继续绘制
    if (_isDrawing && _activePointers == 1) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.globalToLocal(event.position);
      _updateErasePoint(position);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.enable) return;

    // 先减少计数
    _activePointers--;

    // 如果还有其他手指在触摸，触发多指回调
    if (_activePointers > 0) {
      widget.onMultiTouch?.call(event);
      return;
    }

    // 只有在之前处于绘制状态时才触发结束回调
    if (_isDrawing) {
      _isDrawing = false;
      setState(() {
        _currentPosition = null;
        _addPoint(null);
      });
      widget.onEraseEnd?.call();
    }
  }

  void _updateErasePoint(Offset position) {
    if (_image == null || imageSize == null) return;
    final scale = context.size!.width / imageSize!.width;
    final imageHeight = imageSize!.height * scale;
    final verticalOffset = (context.size!.height - imageHeight) / 2;
    final localPosition = (position - Offset(0, verticalOffset)) / scale;

    setState(() {
      _currentPosition = position;
      _addPoint(localPosition);
    });
    widget.onEraseStart?.call(_currentPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null || imageSize == null) {
      return Center(child: BaseUtil.loadingWidget());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / imageSize!.width;
        final imageHeight = imageSize!.height * scale;
        final verticalOffset = (constraints.maxHeight - imageHeight) / 2;

        return Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              child: CustomPaint(
                size: constraints.biggest,
                painter: ErasePainter(
                  image: _image!,
                  strokes: _strokes,
                  scale: scale,
                  offset: Offset(0, verticalOffset),
                  clearMode: widget.clearMode,
                  imageOpacity: widget.imageOpacity, // 传入 imageOpacity
                  imgColor: widget.imgColor, // 传入 imgColor
                ),
              ),
            ),
            if (_currentPosition != null)
              Positioned(
                left: _currentPosition!.dx - _clearPainterWidth / 2,
                top: _currentPosition!.dy - _clearPainterWidth / 2,
                child: Container(
                  width: _clearPainterWidth,
                  height: _clearPainterWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void autoErase(Offset position) {
    if (_image == null || imageSize == null) return;
    final scale = context.size!.width / imageSize!.width;
    final imageHeight = imageSize!.height * scale;
    final verticalOffset = (context.size!.height - imageHeight) / 2;
    final localPosition = (position - Offset(0, verticalOffset)) / scale;
    setState(() {
      _currentPosition = position;
      _addPoint(localPosition);
    });
    widget.onEraseStart?.call(_currentPosition);
  }

  void stopErase() {
    if (_image == null || imageSize == null) return;
    setState(() {
      _currentPosition = null;
      _addPoint(null);
    });
    widget.onEraseEnd?.call();
  }
}

class ErasePainter extends CustomPainter {
  final ui.Image image;
  final List<List<ErasePoint>> strokes;
  final double scale;
  final Offset offset;
  final bool clearMode;
  final double imageOpacity; // 新增 imageOpacity 属性
  final Color imgColor;

  ErasePainter({
    required this.image,
    required this.strokes,
    required this.scale,
    required this.offset,
    required this.clearMode,
    required this.imageOpacity, // 新增构造函数参数
    this.imgColor = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, offset.dy);
    canvas.scale(scale);

    final rect =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    canvas.saveLayer(rect, Paint());

    // 修改 imagePaint，添加颜色和透明度控制
    final imagePaint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    // 如果颜色不是透明的，则应用颜色混合
    if (imgColor != Colors.transparent) {
      imagePaint
        ..colorFilter = ColorFilter.mode(imgColor, BlendMode.srcATop)
        ..color = Colors.white.withOpacity(imageOpacity);
    } else {
      // 如果是透明色，只应用透明度
      imagePaint.color = Colors.white.withOpacity(imageOpacity);
    }

    canvas.drawImage(image, Offset.zero, imagePaint);

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length; i++) {
        if (stroke[i].point == null) continue;

        final erasePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = stroke[i].width / scale
          ..strokeCap = StrokeCap.round
          ..blendMode = clearMode ? BlendMode.clear : BlendMode.color;

        canvas.drawCircle(
            stroke[i].point!, stroke[i].width / (2 * scale), erasePaint);

        if (i < stroke.length - 1 && stroke[i + 1].point != null) {
          canvas.drawLine(stroke[i].point!, stroke[i + 1].point!, erasePaint);
        }
      }
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ErasePainter oldDelegate) {
    return true;
  }
}
