import 'package:flutter/material.dart';

import '../../../flutter_baji.dart';
import 'texture_widget.dart';

class TextureList extends StatefulWidget {
  final List<BjTextureDetail> fons;

  final Function({BjTextureDetail? item, String? texturePath}) onChanged;
  Function()? onScrollNext;
  Function()? onScrollPre;

  BjTextureDetail? fontDetail;

  final Function()? upload;
  final Function(dynamic id)? delete;

  bool isMine;

  TextureList(
      {super.key,
      required this.fons,
      required this.onChanged,
      this.fontDetail,
      this.upload,
      this.delete,
      this.isMine = false});

  @override
  State<TextureList> createState() => _FrameListState();
}

class _FrameListState extends State<TextureList> {
  int currentIndex = -1;

  @override
  void initState() {
    if (widget.fons.contains(widget.fontDetail)) {
      setState(() {
        currentIndex = widget.fons.indexOf(widget.fontDetail!);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 180,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: widget.fons.length,
          itemBuilder: (c, i) {
            bool selected = currentIndex == i;
            BjTextureDetail item = widget.fons[i];

            if (item.id == -1) {
              return _upload();
            }

            bool vipFont = item.isVipFont;
            Widget child = Stack(
              children: [
                TextureWidget(
                  fontDetail: item,
                  onSelect: (st, path) {
                    if (st == null || currentIndex == i) {
                      return;
                    }
                    widget.onChanged.call(item: item, texturePath: path);
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  // ),
                ),
                if (vipFont)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.only(topRight: Radius.circular(4)),
                      child: Image.asset(
                        'icon_vip_lvjing'.imageBjPng,
                        width: 21,
                      ),
                    ),
                  ),
                if (widget.isMine && item.id != -1)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        widget.delete?.call(item.id);
                      },
                      child: Image.asset(
                        'icon_blackclose_pop_2'.imageBjPng,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
              ],
            );

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: selected
                          ?  Color(0xffFF1A5A)
                          : const Color(0xffF4F4F4),
                      width: 1),
                  borderRadius: BorderRadius.circular(7.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: child,
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6),
        ));
  }

  Widget _upload() {
    return GestureDetector(
      onTap: () {
        widget.upload?.call();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xffB1B1B3)),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xffD8D8D8),
        ),
      ),
    );
  }
}
