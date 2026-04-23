import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/constants/constant_rmbg.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/utils/base_util.dart';

import '../models/action_data.dart';
import 'custom_widget.dart';

class MainPanelRmbg extends StatefulWidget {
  final Function(ActionData data)? onClick;
  final panHeight;

  const MainPanelRmbg({this.onClick, required this.panHeight});

  @override
  State<MainPanelRmbg> createState() => _MainPanState();
}

class _MainPanState extends State<MainPanelRmbg> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.panHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: const Color(0xff19191A).withOpacity(0.1))
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          scrollDirection: Axis.horizontal,
          // 设置为横向滚动
          itemCount: mainRmbgActions.length,
          itemBuilder: _item,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              width: 10,
            );
          },
        ));
  }

  Widget _item(BuildContext context, int index) {
    ActionData data = mainRmbgActions[index];
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (data.requireVip && !BaseUtil.isMember()) {
          showRmbgVipPop(context, onBuy: () {
            BaseUtil.goVipBuy();
          });
          return;
        }

        widget.onClick?.call(data);
      },
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 50, child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                data.icon,
                width: 26,
              ),
              if (data.requireVip)
                Positioned(
                  right: 0,
                  top: 4,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(4)),
                    child: Image.asset(
                      'icon_vip_lvjing'.imageEditorPng,
                      width: 21,
                    ),
                  ),
                ),
            ],
          ),),
          const SizedBox(
            height: 6,
          ),
          AutoSizeText(
            maxLines: 1,
            minFontSize: 8,
            data.name,
            style: const TextStyle(
                color: Color(0xff1E1925),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
