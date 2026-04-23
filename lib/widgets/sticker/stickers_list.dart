import 'package:flutter/material.dart';

import '../../flutter_baji.dart';
import 'sticker_widget.dart';

class StickersList extends StatefulWidget {
  final List<StickDetail> sts;

  final Function({StickDetail? stcikerItem, String? stcikerPath}) onChanged;
  Function()? onScrollNext;
  Function()? onScrollPre;

  StickDetail? usingDetail;

  final Function()? upload;
  final Function(dynamic id)? delete;

  bool isMine;

  StickersList(
      {super.key,
      required this.sts,
      required this.onChanged,
      this.usingDetail,
      this.upload,
      this.delete,
      this.isMine = false});

  @override
  State<StickersList> createState() => _StickersListState();
}

class _StickersListState extends State<StickersList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent + 40) {
        } else if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent - 40) {}
      });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 160,
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          physics: const BouncingScrollPhysics(),
          // 设置为横向滚动
          itemCount: widget.sts.length,
          itemBuilder: (c, i) {
            StickDetail item = widget.sts[i];
            if (item.id == -1) {
              return _upload();
            }
            bool vipSticker = item.isVipSticker;
            Widget child = Stack(
              children: [
                StickerWidget(
                  stickerDetail: item,
                  onSelect: (st, path) {
                    if (st == null) {
                      return;
                    }
                    widget.onChanged.call(stcikerItem: item, stcikerPath: path);
                  },
                ),
                if (vipSticker)
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
                  color: (item.color != null &&
                          '${item.color}'.isNotEmpty &&
                          '${item.color}' != 'null')
                      ? Color(int.parse(item.color)) // example: 0xffababab
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: child,
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 11, crossAxisSpacing: 11),
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
