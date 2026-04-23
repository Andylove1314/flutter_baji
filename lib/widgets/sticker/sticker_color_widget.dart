import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

import '../../constants/constant.dart';
import '../../constants/constant_bj.dart';
import '../../models/sticker_color_item.dart';

class StickerColorWidget extends StatefulWidget {
  Color color;

  String stickerType;

  List<StickerColorItem> images;

  StickerColorWidget({
    super.key,
    required this.onColorSelect,
    this.onImageSelect,
    this.color = Colors.transparent,
    this.stickerType = 'none',
    this.images = const [],
  });

  final Function(Color? color) onColorSelect;
  final Function(StickerColorItem? item)? onImageSelect;

  @override
  State<StickerColorWidget> createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<StickerColorWidget> {
  Color? _color;
  StickerColorItem? _selectedImage;

  final _none = StickerColorItem(
    type: 'none',
    id: -1,
    bgimgId: -1,
    name: '无工艺贴纸',
    image: '',
  );

  void _updateSelection() {
    _color = widget.color;
    _selectedImage = widget.images.firstWhere(
      (item) => item.type == widget.stickerType,
      orElse: () => _none,
    );
  }

  @override
  void initState() {
    super.initState();
    _updateSelection(); // 初始化时直接调用，不需要setState
  }

  @override
  void didUpdateWidget(covariant StickerColorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.color != oldWidget.color ||
        widget.stickerType != oldWidget.stickerType) {
      _updateSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 创建一个组合列表，包含颜色和图片
    List<dynamic> items = [_none, ...widget.images, ...presetColors2];

    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _item(context, index, items);
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          width: 15,
        ),
        itemCount: items.length,
      ),
    );
  }

  Widget _item(BuildContext context, int index, List<dynamic> items) {
    final item = items[index];

    // 如果是 StickerColorItem 类型，显示图片
    if (item is StickerColorItem) {
      bool selected = _selectedImage == item; // 修改选中判断逻辑
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedImage = item; // 设置选中的图片
            _color = Colors.transparent; // 清除颜色选择
          });
          widget.onImageSelect?.call(item); // 调用图片选择回调
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Image.asset(
                  _fetchLocalIcon(item.type),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (selected && item.type != 'none')
              SizedBox(
                width: 12,
                height: 12,
                child: Image.asset(
                  'icon_choose_color_2'.imageBjPng,
                  fit: BoxFit.fill,
                ),
              )
          ],
        ),
      );
    }

    // 如果是 Color 类型，显示原有的颜色选择器
    bool selected = _color == item;
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = item;
          _selectedImage = null; // 清除图片选择
        });
        widget.onColorSelect.call(item);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                border: item == Colors.black
                    ? Border.all(color: const Color(0xffE1E2E6), width: 2)
                    : null,
                color: item,
                borderRadius: BorderRadius.circular(25)),
          ),
          if (selected)
            SizedBox(
              width: 12,
              height: 12,
              child: Image.asset(
                'icon_choose_color_2'.imageBjPng,
                fit: BoxFit.fill,
              ),
            )
        ],
      ),
    );
  }

  /// 工艺贴纸
  String _fetchLocalIcon(String type) {
    switch (type) {
      case 'none':
        return 'icon_nocolor_black'.imageBjPng;
      case 'golden':
        return 'craftsmanship_golden'.imageBjPng;
      case 'silver':
        return 'craftsmanship_silver'.imageBjPng;
      case 'red':
        return 'craftsmanship_red'.imageBjPng;
      case 'laser':
        return 'craftsmanship_laser'.imageBjPng;
      case 'whiteInk':
        return 'craftsmanship_white_ink'.imageBjPng; // 暂时使用默认图标，需要添加对应的白墨图标
      default:
        return 'icon_nocolor_black'.imageBjPng;
    }
  }
}
