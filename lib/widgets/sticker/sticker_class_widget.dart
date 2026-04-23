import 'dart:io';

import 'package:flutter/material.dart';

import '../../flutter_baji.dart';
import '../net_image.dart';

class StickerClassWidget extends StatefulWidget {
  TabController tabController;
  List<StickerData> tags;
  bool centerTab;
  int position = 0;

  StickerClassWidget(
      {super.key,
      this.tags = const [],
      required this.tabController,
      this.centerTab = false,
      this.position = 0});

  @override
  State<StatefulWidget> createState() {
    return _StickerClassWidgetState();
  }
}

class _StickerClassWidgetState extends State<StickerClassWidget> {
  int _position = 0;
  @override
  void initState() {
    _position = widget.position;
    widget.tabController.addListener(() {
      setState(() {
        _position = widget.tabController.index;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: TabBar(
          tabAlignment:
              widget.centerTab ? TabAlignment.center : TabAlignment.start,
          controller: widget.tabController,
          indicator: const BoxDecoration(color: Colors.transparent),
          tabs: widget.tags.map((e) {
            bool selected = widget.tags.indexOf(e) == _position;
            return Container(
              padding:
                  const EdgeInsets.only(left: 13, right: 13, top: 0, bottom: 2),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _fetchSrc(e),
                      if (e.isVipGroup)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(4)),
                            child: Image.asset(
                              'icon_vip_lvjing'.imageBjPng,
                              width: 21,
                            ),
                          ),
                        )
                    ],
                  ),
                  Container(
                    height: 2,
                    width: 10,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xff19191A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1.5)),
                  )
                ],
              ),
            );
          }).toList(),
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          onTap: (index) {
            widget.tabController.animateTo(index);
          },
          dividerColor: Colors.transparent,
          indicatorColor: Colors.black,
        ));
  }

  Widget _fetchSrc(StickerData data) {
    if (data.imgFrom == 0) {
      return Image.asset(
        data.groupImage ?? '',
        fit: BoxFit.contain,
        width: 33,
      );
    } else if (data.imgFrom == 1) {
      return Image.file(
        File(data.groupImage ?? ''),
        fit: BoxFit.contain,
        width: 33,
      );
    }
    return NetImage(
      url: data.groupImage ?? '',
      fit: BoxFit.contain,
      width: 33,
    );
  }
}
