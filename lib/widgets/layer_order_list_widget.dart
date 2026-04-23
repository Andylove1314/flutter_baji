import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../models/layer_data.dart';
import 'sticker_pre_view.dart';

class LayerOrderListWidget extends StatefulWidget {
  final List<LayerData> stickerPreDatas;
  final List<Widget> stickerPres;
  final List<Widget> stickerMagnifiers;

  final Function(LayerData item) onDelete;
  final Function(List<LayerData>, List<Widget>, List<Widget>) onReorder;
  final Function(bool lock, int index) onLock;
  final Function(int) onTap;

  const LayerOrderListWidget({
    super.key,
    required this.stickerPreDatas,
    required this.stickerPres,
    required this.stickerMagnifiers,
    required this.onReorder,
    required this.onTap,
    required this.onDelete,
    required this.onLock,
  });

  @override
  State<LayerOrderListWidget> createState() => _LayerOrderListWidgetState();
}

class _LayerOrderListWidgetState extends State<LayerOrderListWidget> {
  late List<LayerData> _items;
  late List<Widget> _stickerPres;
  late List<Widget> _stickerMagnifiers;

  @override
  void initState() {
    super.initState();
    _items = widget.stickerPreDatas.reversed.toList();
    _stickerPres = widget.stickerPres.reversed.toList();
    _stickerMagnifiers = widget.stickerMagnifiers.reversed.toList();
  }

  @override
  void didUpdateWidget(covariant LayerOrderListWidget oldWidget) {
    _items = widget.stickerPreDatas.reversed.toList();
    _stickerPres = widget.stickerPres.reversed.toList();
    _stickerMagnifiers = widget.stickerMagnifiers.reversed.toList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: _items.length,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                color: const Color(0xff3E3E3E),
                elevation: 3,
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);

            final item1 = _stickerPres.removeAt(oldIndex);
            _stickerPres.insert(newIndex, item1);

            final item2 = _stickerMagnifiers.removeAt(oldIndex);
            _stickerMagnifiers.insert(newIndex, item2);

            // 转换回原始顺序并通知外部
            final originalItems = _items.reversed.toList();
            final originalItems1 = _stickerPres.reversed.toList();
            final originalItems2 = _stickerMagnifiers.reversed.toList();
            widget.onReorder(originalItems, originalItems1, originalItems2);
          });
        },
        itemBuilder: (context, index) {
          return _buildLayerItem(_items[index], _stickerPres[index],
              widget.stickerPreDatas.length - 1 - index);
        },
      ),
    );
  }

  Widget _buildLayerItem(LayerData item, Widget pre, int index) {
    return Container(
      key: ValueKey(item.preKey.toString()),
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTap(index),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 51,
                height: 51,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: item.isFont
                    ? Obx(() => Text(
                          '字体',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: item.fontPath?.value ?? '',
                              fontSize: 20),
                        ))
                    : Obx(() =>
                        Image.file(File(item.stickerRmbgPath?.value ?? ''))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                      item.name.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )),
              ),
              IconButton(onPressed: () {
                var stickerPreView =
                    (pre as RepaintBoundary).child as StickerPreView;
                stickerPreView.isLocked.value = !stickerPreView.isLocked.value;
                item.isLocked = !item.isLocked;
                widget.onLock(item.isLocked, index);
              }, icon: Obx(
                () {
                  var stickerPreView =
                      (pre as RepaintBoundary).child as StickerPreView;

                  return Image.asset(
                    stickerPreView.isLocked.value
                        ? 'lock_off'.imageBjPng
                        : 'lock_on'.imageBjPng,
                    width: 15,
                  );
                },
              )),
              ReorderableDragStartListener(
                index: index,
                child: Image.asset(
                  'icon_drag_baji'.imageBjPng,
                  width: 20,
                ),
              ),
              IconButton(
                  onPressed: item.isTarget ? null : () => widget.onDelete(item),
                  icon: item.isTarget
                      ? const SizedBox(
                          width: 15,
                        )
                      : Image.asset(
                          'delete_layer_baji'.imageBjPng,
                          width: 15,
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
