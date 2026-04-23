import 'dart:math';

import 'package:flutter/material.dart';

import 'lindi_controller_2.dart';
import 'lindi_gesture_detector_2.dart';
import 'lindi_sticker_icon_2.dart';
import 'positioned_align_2.dart';

/// A Flutter widget class DraggableWidget for displaying and managing draggable stickers.
///
//ignore: must_be_immutable
class DraggableWidget2 extends StatelessWidget {
  late List<LindiStickerIcon2> _icons;

  /// Properties to customize the appearance and behavior of the widget.
  ///
  Widget child;
  late Color _borderColor;
  late double _borderWidth;
  late bool _showBorders;
  late bool _shouldMove;
  late bool _shouldRotate;
  late bool _shouldScale;
  late double _minScale;
  late double _maxScale;
  late double _insidePadding;

  late bool _initShouldMove;
  late bool _initShouldRotate;
  late bool _initShouldScale;

  /// Internal state [_showBorder].
  ///
  /// Defaults to true
  ///
  bool _showBorder = true;

  /// Internal state[_isFlip].
  ///
  /// Defaults to false
  ///
  bool _isFlip = false;

  /// Internal state[_isLock].
  ///
  /// Defaults to false
  ///
  bool _isLock = false;

  /// Internal state[_isUpdating].
  ///
  /// Defaults to false
  ///
  bool _isUpdating = false;

  /// Internal state[_scale].
  ///
  /// Defaults 1
  ///
  double _scale = 1;

  /// Callback functions for various widget interactions.
  ///
  late Function(Key?) _onBorder;
  late Function(Key?) _onDelete;
  late Function(Key?) _onLayer;

  /// Notifiers for updating the widget when changes occur.
  ///
  final ValueNotifier<Matrix4> _notifier = ValueNotifier(Matrix4.identity());
  final ValueNotifier<bool> _updater = ValueNotifier(true);

  GlobalKey centerKey = GlobalKey();
  GlobalKey globalKey;

  // New properties for initial transformation
  final double initialScale;
  final double initialRotation;
  final Offset initialRlPosition;
  final Size parentSize;
  final Function(double scale, double radian, Offset rlOffset)? onChange;

  DraggableWidget2({
    super.key,
    required icons,
    required this.child,
    required this.parentSize,
    required borderColor,
    required borderWidth,
    required showBorders,
    required shouldMove,
    required shouldRotate,
    required shouldScale,
    required minScale,
    required maxScale,
    required onBorder,
    required onDelete,
    required onLayer,
    required insidePadding,
    required this.globalKey,
    this.initialScale = 1.0, // 初始化缩放大小
    this.initialRotation = 0.0, // 初始化旋转角度（以弧度表示）
    this.initialRlPosition = Offset.zero, // 初始化位置
    this.onChange,
  }) {
    _icons = icons;
    _borderColor = borderColor;
    _borderWidth = borderWidth;
    _showBorders = showBorders;
    _shouldMove = shouldMove;
    _shouldRotate = shouldRotate;
    _shouldScale = shouldScale;
    _minScale = minScale;
    _maxScale = maxScale;
    _onBorder = onBorder;
    _onDelete = onDelete;
    _onLayer = onLayer;
    _insidePadding = insidePadding;

    _initShouldMove = _shouldMove;
    _initShouldScale = _shouldScale;
    _initShouldRotate = _shouldRotate;

    _initStickerWhere();
  }

  /// 初始化位置，缩放，旋转
  void _initStickerWhere() {
    // Initialize the transformation matrix with initial values

    final childSize =
        (child as Container).constraints?.biggest ?? Size(100, 100);

    // 计算旋转后的实际尺寸
    final scaledWidth = childSize.width * initialScale;
    final scaledHeight = childSize.height * initialScale;

    final rotatedWidth = scaledWidth * cos(initialRotation).abs() +
        scaledHeight * sin(initialRotation).abs();
    final rotatedHeight = scaledHeight * cos(initialRotation).abs() +
        scaledWidth * sin(initialRotation).abs();

    // 计算旋转中心点的偏移
    final centerOffsetX = (rotatedWidth - scaledWidth) / 2;
    final centerOffsetY = (rotatedHeight - scaledHeight) / 2;

    // 调整初始位置以考虑旋转因素
    final adjustedX = initialRlPosition.dx * parentSize.width - centerOffsetX;
    final adjustedY = initialRlPosition.dy * parentSize.height - centerOffsetY;

    // 修改矩阵初始化顺序
    _notifier.value = Matrix4.identity()
      ..scale(initialScale) // 先缩放
      ..rotateZ(initialRotation) // 再旋转
      ..translate(adjustedX, adjustedY); // 最后平移

    onChange?.call(
        initialScale, initialRotation, initialRlPosition); // 回调通知初始状态

    debugPrint('childSize: $childSize');
    debugPrint('initialRlPosition: $initialRlPosition');
    debugPrint(
        'adjustedPosition: (${adjustedX / parentSize.width}, ${adjustedY / parentSize.height})');
    debugPrint('initialScale: $initialScale');
    debugPrint('initialRotation: $initialRotation');
    debugPrint('parentSize: $parentSize');
  }

  // A reference to the LindiGestureDetector's state
  late LindiGestureDetectorState _gestureDetectorState;

  // Method to update the widget's border visibility.
  showBorder(bool showBorder) {
    _showBorder = showBorder;
    _updater.value = !_updater.value;
  }

  // Method to edit the widget.
  edit(Widget child) {
    this.child = child;
    _updater.value = !_updater.value;
  }

  // Method to flip the widget.
  flip() {
    _isFlip = !_isFlip;
    _updater.value = !_updater.value;
  }

  // Method to mark the widget as "done" and hide its border.
  done() {
    _showBorder = false;
    _updater.value = !_updater.value;
  }

  // Method to delete the widget.
  delete() {
    _onDelete(key);
  }

  // Method to stack, change position.
  stack() {
    _onLayer(key);
  }

  // Method to lock/unlock the widget's interactive features.
  lock() {
    _isLock = !_isLock;
    _shouldScale = _isLock ? false : _initShouldScale;
    _shouldRotate = _isLock ? false : _initShouldRotate;
    _shouldMove = _isLock ? false : _initShouldMove;
    _updater.value = !_updater.value;
  }

  // Method to unlock the widget
  unlock() {
    _isLock = false;
    _shouldScale = _initShouldScale;
    _shouldRotate = _initShouldRotate;
    _shouldMove = _initShouldMove;
    _updater.value = !_updater.value;
  }

  bool isFlip() {
    return _isFlip;
  }

  @override
  Widget build(BuildContext context) {
    // Build the widget based on ValueListenable for updates.
    return ValueListenableBuilder(
        valueListenable: _updater,
        builder: (_, __, ___) {
          // Calculate sizes and dimensions based on the current scale.
          double marginSize = 12 / _scale.abs();

          // LindiGestureDetector for handling scaling, rotating, and translating the widget.
          return LindiGestureDetector2(
            centerKey: centerKey,
            globalKey: globalKey,
            shouldTranslate: _shouldMove,
            shouldRotate: _shouldRotate,
            shouldScale: _shouldScale,
            minScale: _minScale,
            maxScale: _maxScale,
            initialPosition: Offset(initialRlPosition.dx * parentSize.width,
                initialRlPosition.dy * parentSize.height),
            initialScale: initialScale,
            initialRotation: initialRotation,
            onScaleStart: (bool update) {
              if (update) _isUpdating = true;
              _onBorder(key);
            },
            onScaleEnd: () {
              _isUpdating = false;
              _updater.value = !_updater.value;
            },
            onUpdate: (s, m) {
              _scale = s;
              _notifier.value = m;
              Offset translation = getTranslation(m);
              onChange?.call(
                  getScale(m),
                  getRotation(m),
                  Offset(translation.dx / parentSize.width,
                      translation.dy / parentSize.height));
            },
            child: Builder(builder: (context) {
              _gestureDetectorState =
                  context.findAncestorStateOfType<LindiGestureDetectorState>()!;
              return AnimatedBuilder(
                animation: _notifier,
                builder: (ctx, child) {
                  // Apply the transformation matrix to the child widget.
                  Widget transformChild = Transform(
                    transform: _notifier.value,
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(marginSize),
                            padding:
                                EdgeInsets.all(_insidePadding / _scale.abs()),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: (_showBorders && _showBorder)
                                      ? _borderColor
                                      : Colors.transparent,
                                  width: _borderWidth / _scale.abs()),
                            ),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Transform.flip(
                                  flipX: _isFlip, child: this.child),
                            ),
                          ),
                          // Widgets for interaction (e.g., delete, flip, etc.).
                          for (int i = 0; i < _icons.length; i++) ...[
                            if (_showBorders &&
                                _showBorder &&
                                (!_isLock || _icons[i].type == IconType2.lock))
                              Builder(builder: (context) {
                                bool isLock = _icons[i].type == IconType2.lock;
                                bool isResize =
                                    _icons[i].type == IconType2.resize;
                                LindiStickerIcon2 icon = _icons[i];
                                double circleSize = icon.iconSize + 12;
                                return PositionedAlign2(
                                  alignment: icon.alignment,
                                  child: ScaleTransition(
                                    alignment: icon.alignment,
                                    scale: AlwaysStoppedAnimation(
                                        1 / _scale.abs()),
                                    child: GestureDetector(
                                      onPanUpdate: isResize
                                          ? _gestureDetectorState.onDragUpdate
                                          : null,
                                      onPanStart: isResize
                                          ? _gestureDetectorState.onDragStart
                                          : null,
                                      onPanEnd: isResize
                                          ? _gestureDetectorState.onDragEnd
                                          : null,
                                      onTap: !isResize ? icon.onTap : null,
                                      child: SizedBox(
                                        width: circleSize,
                                        height: circleSize,
                                        child: CircleAvatar(
                                            backgroundColor:
                                                icon.backgroundColor,
                                            child: Icon(
                                              (isLock &&
                                                      icon.lockedIcon != null)
                                                  ? _isLock
                                                      ? icon.lockedIcon
                                                      : icon.icon
                                                  : icon.icon,
                                              size: icon.iconSize,
                                              color: icon.iconColor,
                                            )),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                          SizedBox(key: centerKey)
                        ],
                      ),
                    ),
                  );
                  return _isUpdating
                      ? Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: transformChild)
                      : transformChild;
                },
              );
            }),
          );
        });
  }

  /// 水平垂直居中贴纸
  /// @param parentSize 父容器尺寸
  /// @param isVertical true为垂直居中，false为水平居中
  /// @param stickerSize 贴纸的实际尺寸
  hvCenter(bool isVertical,
      {required Size parentSize, required Size stickerSize}) {
    Matrix4 matrix = _notifier.value;

    // 获取当前变换状态
    final currentRotation = getRotation(matrix);
    final currentScale = getScale(matrix);

    // 计算实际内容尺寸（包括边距和内边距）
    final marginSize = 12 / _scale.abs();
    final paddingSize = _insidePadding / _scale.abs();
    final contentSize = Size(
        stickerSize.width + (marginSize + paddingSize) * 2 + _borderWidth * 3,
        stickerSize.height + (marginSize + paddingSize) * 2 + _borderWidth * 3);

    // 计算缩放后的尺寸
    final scaledWidth = contentSize.width * currentScale;
    final scaledHeight = contentSize.height * currentScale;

    // 计算旋转后的尺寸
    final rotatedWidth = scaledWidth * cos(currentRotation).abs() +
        scaledHeight * sin(currentRotation).abs();
    final rotatedHeight = scaledHeight * cos(currentRotation).abs() +
        scaledWidth * sin(currentRotation).abs();

    // 计算旋转中心点的偏移
    final centerOffsetX = (rotatedWidth - scaledWidth) / 2;
    final centerOffsetY = (rotatedHeight - scaledHeight) / 2;

    // 重置矩阵并按顺序应用变换
    Matrix4 newMatrix = Matrix4.identity()
      ..scale(currentScale)
      ..rotateZ(currentRotation);

    // 计算新的位置
    double newX = isVertical
        ? getTranslation(matrix).dx
        : (parentSize.width - rotatedWidth) / 2 + centerOffsetX;
    double newY = isVertical
        ? (parentSize.height - rotatedHeight) / 2 + centerOffsetY
        : getTranslation(matrix).dy;

    // 应用平移
    newMatrix.setTranslationRaw(newX, newY, 0);

    // 更新矩阵
    _notifier.value = newMatrix;
    _updater.value = !_updater.value;

    // 回调通知位置变化
    onChange?.call(currentScale, currentRotation,
        Offset(newX / parentSize.width, newY / parentSize.height));
  }
}

double getScale(Matrix4 matrix) {
  // 使用欧几里得范数计算实际缩放值
  double scaleX = sqrt(matrix.storage[0] * matrix.storage[0] +
      matrix.storage[1] * matrix.storage[1]);
  return scaleX;
}

double getRotation(Matrix4 matrix) {
  double rotation =
      atan2(matrix.storage[1], matrix.storage[0]); // atan2(m[1], m[0])
  return rotation; // 弧度
}

Offset getTranslation(Matrix4 matrix) {
  double dx = matrix.storage[12]; // m[12]
  double dy = matrix.storage[13]; // m[13]
  return Offset(dx, dy);
}
