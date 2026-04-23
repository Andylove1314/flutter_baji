import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'draggable_widget_2.dart';
import 'index_stream_2.dart';
import 'lindi_sticker_icon_2.dart';

enum IconType2 { lock, resize, other }

/// A Dart class LindiController extending ChangeNotifier,
/// used for managing a list of draggable widgets and their properties.
///
class LindiController2 extends ChangeNotifier {
  /// List to store draggable widgets.
  ///
  List<DraggableWidget2> widgets = [];
  List<GlobalKey> globalKeys = [];
  Map<Key, dynamic> dynamicFlagDatas = {};

  /// Color of the border
  ///
  /// Defaults to Colors.blue
  ///
  Color borderColor;

  /// Width of the border
  ///
  /// Defaults to 1.5
  ///
  double borderWidth;

  /// Show All Buttons and Border
  ///
  /// Defaults to true
  ///
  bool showBorders;

  /// Should the widget move
  ///
  /// Defaults to true
  ///
  bool shouldMove;

  /// Should the widget rotate
  ///
  /// Defaults to true
  ///
  bool shouldRotate;

  /// Should the widget scale
  ///
  /// Defaults to true
  ///
  bool shouldScale;

  /// Widget minimum scale
  ///
  /// Defaults 0.5
  ///
  double minScale;

  /// Widget maximum scale
  ///
  /// Defaults 4
  ///
  double maxScale;

  /// Widget inside padding
  ///
  /// Defaults 13
  ///
  double insidePadding;

  /// Stream to listen selected index
  ///
  final IndexStream2<int> _selectedIndex = IndexStream2<int>();
  int _currentIndex = -1;

  bool deleted = false;

  GlobalKey globalKey;

  /// Constructor to initialize properties with default values.
  ///
  LindiController2(
      {required this.globalKey,
      this.borderColor = Colors.white,
      this.borderWidth = 1.5,
      this.showBorders = true,
      this.shouldMove = true,
      this.shouldRotate = true,
      this.shouldScale = true,
      this.minScale = 0.5,
      this.maxScale = 4,
      this.insidePadding = 13}) {
    onPositionChange();
  }

  // Method to add a widget to the list of draggable widgets.
  add(Widget widget, List<LindiStickerIcon2> icons,
      {required Size parentSize,
      double initScale = 1.0,
      double initRadian = 0.0,
      Offset initialRlPosition = Offset.zero,
      Function(double scale, double radian, Offset offset)? onChange,
      dynamic flagData}) {
    // Generate a unique key for the widget.
    Key key = Key('lindi-${DateTime.now().millisecondsSinceEpoch}-${_nrRnd()}');

    // Create a DraggableWidget with specified properties.
    widgets.add(DraggableWidget2(
        key: key,
        globalKey: globalKey,
        icons: icons,
        borderColor: borderColor,
        borderWidth: borderWidth,
        showBorders: showBorders,
        shouldMove: shouldMove,
        shouldRotate: shouldRotate,
        shouldScale: shouldScale,
        minScale: minScale,
        maxScale: maxScale,
        insidePadding: insidePadding,
        initialScale: initScale,
        initialRotation: initRadian,
        initialRlPosition: initialRlPosition,
        onChange: onChange,
        onBorder: (key) {
          _border(key);
        },
        onDelete: (key) {
          _delete(key);
        },
        onLayer: (key) {
          _layer(key);
        },
        parentSize: parentSize,
        child: widget));
    globalKeys.add(globalKey);
    dynamicFlagDatas[key] = flagData;

    // Highlight the border of the added widget.
    _border(key);
  }

  // Adds all the widgets from the given list
  addAll(List<Widget> widgets, List<List<LindiStickerIcon2>> iconss,
      {required Size parentSize}) {
    for (int i = 0; i < widgets.length; i++) {
      add(widgets[i], iconss[i], parentSize: parentSize);
    }
  }

  // Sets up a listener for changes in the selected widget's position.
  // The provided callback function `stream` will be called whenever the position changes.
  onPositionChange([Function(int)? stream]) {
    _selectedIndex.stream.listen((int index) {
      _currentIndex = index;
      if (stream != null) {
        stream(_currentIndex);
      }
    });
  }

  // Returns the currently selected widget based on the _currentIndex.
  // If the _currentIndex is within the valid range, the corresponding widget is returned.
  // Otherwise, it returns null.
  DraggableWidget2? get selectedWidget {
    if (_currentIndex >= 0 && _currentIndex < widgets.length) {
      return widgets[_currentIndex];
    }
    return null;
  }

  dynamic get selectedFlagData {
    if (_currentIndex >= 0 && _currentIndex < dynamicFlagDatas.values.length) {
      return dynamicFlagDatas[dynamicFlagDatas.keys.toList()[_currentIndex]];
    }
    return null;
  }

  // Method to clear borders of all widgets.
  clearAllBorders() {
    _border(const Key('-1'));
  }

  close() {
    _selectedIndex.close();
  }

  // Method to highlight the border of a specific widget.
  _border(Key? key) {
    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i].key == key) {
        widgets[i].showBorder(true);
        if (_selectedIndex.current == null ||
            deleted ||
            widgets[_selectedIndex.current!].key != widgets[i].key) {
          if (deleted) deleted = false;
          _selectedIndex.update(i);
        }
      } else {
        widgets[i].showBorder(false);
      }
    }
    notifyListeners();
  }

  // Method to delete a widget from the list.
  _delete(key) {
    widgets.removeWhere((element) {
      return element.key! == key;
    });
    dynamicFlagDatas.removeWhere((k, d) {
      return k == key;
    });
    deleted = true;
    //If widget is deleted, selected index is -1
    _selectedIndex.update(-1);
    notifyListeners();
  }

  // Method to change the layering of a widget.
  _layer(key) {
    int index =
        widgets.indexOf(widgets.firstWhere((element) => element.key == key));
    if (index > 0) {
      DraggableWidget2 item = widgets.removeAt(index);
      _currentIndex = index - 1;
      _selectedIndex.update(_currentIndex);
      widgets.insert(_currentIndex, item);
      notifyListeners();
    }
  }

  // Method to save the widget layout as a Uint8List image.
  Future<Uint8List?> saveAsUint8List() async {
    // Clear all borders before capturing the image.
    clearAllBorders();
    try {
      Uint8List? pngBytes;
      double pixelRatio = 2;
      await Future.delayed(const Duration(milliseconds: 700))
          .then((value) async {
        // Capture the image of the widget.
        RenderRepaintBoundary boundary = globalKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        pngBytes = byteData?.buffer.asUint8List();
      });
      return pngBytes;
    } catch (e) {
      rethrow;
    }
  }

  Alignment _ensureWithinBounds(Alignment position) {
    double x = position.x;
    double y = position.y;

    if (position.x < -1) x = -1;
    if (position.x > 1) x = 1;

    if (position.y < -1) y = -1;
    if (position.y > 1) y = 1;

    return Alignment(x, y);
  }

  // Helper function to generate a random number.
  int _nrRnd() {
    Random rnd;
    int min = 1;
    int max = 100000;
    rnd = Random();
    return min + rnd.nextInt(max - min);
  }

  void delete(Key key) {
    _delete(key);
  }

  void deleteByFlagData(dynamic flagData) {
    _delete(_getKeyByFlagData(flagData));
  }

  /// 将指定 widget 提升一层（向前）
  void bringForward(Key key) {
    int index = widgets.indexWhere((e) => e.key == key);
    if (index >= 0 && index < widgets.length - 1) {
      final widget = widgets.removeAt(index);
      widgets.insert(index + 1, widget);
      _selectedIndex.update(index + 1);
      notifyListeners();
    }
  }

  /// 将指定 widget 降低一层（向后）
  void sendBackward(Key key) {
    int index = widgets.indexWhere((e) => e.key == key);
    if (index > 0) {
      final widget = widgets.removeAt(index);
      widgets.insert(index - 1, widget);
      _selectedIndex.update(index - 1);
      notifyListeners();
    }
  }

  /// 将指定 widget 置于最前层
  void bringToFront(Key key) {
    int index = widgets.indexWhere((e) => e.key == key);
    if (index >= 0 && index < widgets.length - 1) {
      final widget = widgets.removeAt(index);
      widgets.add(widget);
      _selectedIndex.update(widgets.length - 1);
      notifyListeners();
    }
  }

  /// 将指定 widget 置于最底层
  void sendToBack(Key key) {
    int index = widgets.indexWhere((e) => e.key == key);
    if (index > 0) {
      final widget = widgets.removeAt(index);
      widgets.insert(0, widget);
      _selectedIndex.update(0);
      notifyListeners();
    }
  }

  /// 排序 with keys
  void reorderByKeys(List<Key> keys) {
    // 临时列表，用于存放按新顺序排序的组件
    List<DraggableWidget2> reordered = [];

    for (Key key in keys) {
      try {
        final widget = widgets.firstWhere((w) => w.key == key);
        reordered.add(widget);
      } catch (e) {
        // 如果没找到对应 key，可以选择跳过或抛出异常
        debugPrint('Key not found during reordering: $key');
      }
    }

    // 如果你希望保留未被指定的 widgets（可选）
    final leftover = widgets.where((w) => !keys.contains(w.key));
    reordered.addAll(leftover);

    widgets = reordered;
    notifyListeners();
  }

  Key? _getKeyByFlagData(dynamic flagData) {
    try {
      return dynamicFlagDatas.entries
          .firstWhere((entry) => entry.value == flagData)
          .key;
    } catch (e) {
      return null;
    }
  }

  /// 将指定 widget 提升一层（向前） - 通过 flagData
  void bringForwardByFlagData(dynamic flagData) {
    final key = _getKeyByFlagData(flagData);
    if (key != null) bringForward(key);
  }

  /// 将指定 widget 降低一层（向后） - 通过 flagData
  void sendBackwardByFlagData(dynamic flagData) {
    final key = _getKeyByFlagData(flagData);
    if (key != null) sendBackward(key);
  }

  /// 将指定 widget 移至最上层 - 通过 flagData
  void bringToFrontByFlagData(dynamic flagData) {
    final key = _getKeyByFlagData(flagData);
    if (key != null) bringToFront(key);
  }

  /// 将指定 widget 移至最底层 - 通过 flagData
  void sendToBackByFlagData(dynamic flagData) {
    final key = _getKeyByFlagData(flagData);
    if (key != null) sendToBack(key);
  }

  /// 排序 with dataList
  void reorderByFlagDataList(List<dynamic> dataList) {
    List<DraggableWidget2> reordered = [];

    for (var data in dataList) {
      try {
        final key =
            dynamicFlagDatas.entries.firstWhere((e) => e.value == data).key;
        final widget = widgets.firstWhere((w) => w.key == key);
        reordered.add(widget);
      } catch (e) {
        debugPrint('FlagData not found: $data');
      }
    }

    final leftover = widgets.where((w) => !reordered.contains(w));
    reordered.addAll(leftover);

    widgets = reordered;
    notifyListeners();
  }
}
