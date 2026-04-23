import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';

import '../../flutter_baji.dart';
import '../confirm_bar.dart';
import '../custom_widget.dart';
import '../vip_bar.dart';
import 'filter_class_widget.dart';
import 'filters_list.dart';

class FiltersPanel extends StatefulWidget {
  final List<FilterData> fds;

  FilterDetail? usingDetail;

  final Function({FilterDetail? item}) onChanged;

  final SquareLookupTableNoiseShaderConfiguration sourceFiltersConfig;

  final Function() onEffectSave;

  final int? initialIndex;

  FiltersPanel(
      {super.key,
      required this.fds,
      required this.sourceFiltersConfig,
      required this.onChanged,
      required this.onEffectSave,
      this.usingDetail,
      this.initialIndex});

  @override
  State<FiltersPanel> createState() => _FiltersPanState();
}

class _FiltersPanState extends State<FiltersPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool vipFilter = false;

  late int position;

  @override
  void initState() {
    super.initState();
    position = widget.initialIndex ?? 0;

    _tabController = TabController(
        length: widget.fds.length,
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
    bool showVipBg = vipFilter && !BaseUtil.isMember();

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
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 9),
          color: Colors.white,
          child: SizedBox(
            height: 73,
            child: TabBarView(
              controller: _tabController,
              children: widget.fds
                  .map((item) => FiltersList(
                      usingDetail: widget.usingDetail,
                      fds: item.list ?? [],
                      sourceFiltersConfig: widget.sourceFiltersConfig,
                      onScrollNext: () {
                        int index = widget.fds.indexOf(item);
                        if (index < widget.fds.length - 1) {
                          _tabController.animateTo(index + 1);
                        }
                      },
                      onScrollPre: () {
                        int index = widget.fds.indexOf(item);
                        if (index > 0) {
                          _tabController.animateTo(index - 1);
                        }
                      },
                      onChanged: ({FilterDetail? item}) {
                        setState(() {
                          vipFilter = item?.isVipFilter ?? false;
                        });
                        widget.onChanged(item: item);
                      }))
                  .toList(),
            ),
          ),
        ),
        ConfirmBar(
          content: FilterClassWidget(
            position: position,
            tabController: _tabController,
            tags: widget.fds.map((filter) => filter.groupName).toList(),
          ),
          cancel: () {
            Navigator.of(context).pop();
          },
          confirm: () async {
            if (showVipBg) {
              showVipPop(context, content: '您使用了VIP滤镜，请在开通会员后保存滤镜效果？',
                  onBuy: () {
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
