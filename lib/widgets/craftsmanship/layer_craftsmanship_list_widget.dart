import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/models/craftsmanship_data.dart';
import 'package:flutter_baji/models/layer_data.dart';
import 'package:get/get.dart';

class LayerCraftsmanshipListWidget extends StatefulWidget {
  final Widget fuMoItemWidget;
  final List<LayerData> stickerPreDatas;

  final Function(int)? onLayerTap;
  final bool isSmall;
  final int initLayerIndex;
  final Function(GlobalKey key)? onSave;

  const LayerCraftsmanshipListWidget({
    Key? key,
    required this.stickerPreDatas,
    required this.fuMoItemWidget,
    this.onSave,
    this.onLayerTap,
    this.isSmall = false,
    this.initLayerIndex = 0,
  }) : super(key: key);

  @override
  State<LayerCraftsmanshipListWidget> createState() =>
      _LayerCraftsmanshipListWidgetState();
}

class _LayerCraftsmanshipListWidgetState
    extends State<LayerCraftsmanshipListWidget> {
  late List<LayerData> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.stickerPreDatas.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 10),
      itemCount: _items.length + 1, // 增加1个item用于显示fuMoItemWidget
      itemBuilder: (context, index) {
        if (index == 0) {
          // 在最顶层显示fuMoItemWidget
          return widget.fuMoItemWidget;
        }
        // 其他项显示原有的图层项，注意index需要减1
        return _buildLayerItem(_items[index - 1], _items.length - index);
      },
    );
  }

  Widget _buildLayerItem(LayerData item, int index) {
    bool isSelected = widget.isSmall && (index == widget.initLayerIndex - 1);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          margin: const EdgeInsets.only(left: 10),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              color: isSelected ? Colors.black : Colors.transparent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => widget.onLayerTap?.call(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 51,
                    height: 51,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffE8E8E8),
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
                        : Obx(() => Image.file(
                              width: 51,
                              height: 51,
                              File(item.stickerRmbgPath?.value ?? ''),
                              fit: BoxFit.cover,
                            )),
                  ),
                ),
              ),
              if (!widget.isSmall)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          item.name.value,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ).marginOnly(left: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => widget.onLayerTap?.call(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffB1B1B3), width: 1),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    item.craftsmanshipData?.typeIcon ?? '',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: AutoSizeText(
                                      item.craftsmanshipData?.name ?? '',
                                      style: const TextStyle(
                                        color: Color(0xff1E1925),
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ).marginOnly(left: 12),
                          IconButton(
                              onPressed: (item.craftsmanshipData?.type ==
                                      CraftsmanshipType.none)
                                  ? null
                                  : () {
                                      widget.onSave?.call(item.captureKey);
                                    },
                              icon: (item.craftsmanshipData?.type ==
                                      CraftsmanshipType.none)
                                  ? const SizedBox(
                                      width: 10,
                                    )
                                  : Image.asset(
                                      'download_layer_baji'.imageBjPng,
                                      width: 15,
                                    ))
                        ],
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
        if (item.craftsmanshipData?.type == CraftsmanshipType.golden &&
            !widget.isSmall)
          GestureDetector(
            onTap: () {
              BajiUtil.goldenGyTipClick();
            },
            child: Container(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              margin: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: const Color(0xffFFDBDB),
                  borderRadius: BorderRadius.circular(4)),
              width: double.infinity,
              child: Row(
                children: [
                  Image.asset('icon_dengpao'.imageBjPng, width: 20, height: 20)
                      .marginOnly(right: 11, left: 5),
                  const Flexible(
                      child: Text(
                    '工艺层最后印制会遮盖其他内容，若要避免遮盖可使用“橡皮擦-擦除”工具擦除非工艺区域。',
                    style: TextStyle(color: Color(0xff4C1111), fontSize: 13),
                  ))
                ],
              ),
            ),
          )
      ],
    );
  }
}
