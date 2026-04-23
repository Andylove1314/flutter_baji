import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../models/rmbg_layer_data.dart';

class LayerOrderListRmbgWidget extends StatefulWidget {
  final List<RmbgLayerData> stickerPreDatas;

  final Function(RmbgLayerData item) onDelete;
  final Function(List<RmbgLayerData>) onReorder;
  final Function(bool lock, int index) onLock;
  final Function(int) onTap;

  const LayerOrderListRmbgWidget({
    super.key,
    required this.stickerPreDatas,
    required this.onReorder,
    required this.onTap,
    required this.onDelete,
    required this.onLock,
  });

  @override
  State<LayerOrderListRmbgWidget> createState() => _LayerOrderListWidgetState();
}

class _LayerOrderListWidgetState extends State<LayerOrderListRmbgWidget> {
  late List<RmbgLayerData> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.stickerPreDatas.reversed.toList();
  }

  @override
  void didUpdateWidget(covariant LayerOrderListRmbgWidget oldWidget) {
    _items = widget.stickerPreDatas.reversed.toList();
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

            // 转换回原始顺序并通知外部
            final originalItems = _items.reversed.toList();
            widget.onReorder(originalItems);
          });
        },
        itemBuilder: (context, index) {
          return _buildLayerItem(
              _items[index], widget.stickerPreDatas.length - 1 - index);
        },
      ),
    );
  }

  Widget _buildLayerItem(RmbgLayerData item, int index) {
    return Container(
      key: ValueKey('${index}_${item.stickerPath.value}'),
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
                child: Obx(() => Image.file(File(item.stickerPath.value))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(onPressed: () {
                widget.onLock(!item.locked.value, index);
              }, icon: Obx(
                () {
                  return Image.asset(
                    item.locked.value
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
                  onPressed: () {
                    setState(() {
                      _items.remove(item);
                    });
                    widget.onDelete(item);
                  },
                  icon: Image.asset(
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
