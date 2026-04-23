import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';

import '../../flutter_baji.dart';
import '../confirm_bar.dart';
import '../custom_widget.dart';
import '../vip_bar.dart';
import 'frame_class_widget.dart';
import 'frame_list.dart';

class FramePanel extends StatefulWidget {
  final List<FrameData> frs;

  FrameDetail? usingDetail;

  final Function({FrameDetail? item, String? path}) onChanged;

  final Function() onEffectSave;

  final int? initialIndex;

  FramePanel(
      {super.key,
      required this.frs,
      required this.onChanged,
      required this.onEffectSave,
      this.usingDetail,
      this.initialIndex});

  @override
  State<FramePanel> createState() => _FramePanState();
}

class _FramePanState extends State<FramePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool vipSticker = false;

  late int position;

  @override
  void initState() {
    super.initState();
    position = widget.initialIndex ?? 0;
    _tabController = TabController(
        length: widget.frs.length,
        vsync: this,
        initialIndex: widget.initialIndex ?? 0)
      ..addListener(() {
        setState(() {
          position = _tabController.index;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    bool showVipBg = vipSticker && !BaseUtil.isMember();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VipBar(
          showVipbg: showVipBg,
          subAction: () {
            BaseUtil.goVipBuy();
          },
        ),
        Container(
          color: Colors.white,
          height: 170,
          child: TabBarView(
            controller: _tabController,
            children: widget.frs
                .map((item) => FrameList(
                    usingDetail: widget.usingDetail,
                    sts: item.list ?? [],
                    onChanged: ({FrameDetail? item, String? path}) {
                      setState(() {
                        vipSticker = item?.isVipFrame ?? false;
                      });
                      widget.onChanged(item: item, path: path);
                    }))
                .toList(),
          ),
        ),
        ConfirmBar(
          content: FrameClassWidget(
            position: position,
            tabController: _tabController,
            tags: widget.frs,
          ),
          cancel: () {
            Navigator.of(context).pop();
          },
          confirm: () async {
            if (showVipBg) {
              showVipPop(context, content: '您使用了VIP素材，请在开通会员后保存效果？', onBuy: () {
                BaseUtil.goVipBuy();
              }, onCancel: () {});
              return;
            }
            widget.onEffectSave.call();
          },
        )
      ],
    );
  }
}
