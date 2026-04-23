import 'package:flutter/material.dart';

class FontClassWidget extends StatefulWidget {
  TabController tabController;
  List<String> tags;
  int position;
  bool centerTab;
  bool showIndicator;

  FontClassWidget(
      {super.key,
      this.tags = const [],
      required this.tabController,
      this.position = 0,
      this.centerTab = false,
      this.showIndicator = false});

  @override
  State<StatefulWidget> createState() {
    return _FrameClassWidgetState();
  }
}

class _FrameClassWidgetState extends State<FontClassWidget> {
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
        child: TabBar(
      tabAlignment: widget.centerTab ? TabAlignment.center : TabAlignment.start,
      controller: widget.tabController,
      indicator: const BoxDecoration(color: Colors.transparent),
      tabs: widget.tags.map((e) {
        bool selected = widget.tags.indexOf(e) == _position;
        return Container(
          padding:
              const EdgeInsets.only(left: 13, right: 13, top: 15, bottom: 2),
          child: Column(
            children: [
              Text(
                e ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: selected
                        ? const Color(0xff19191A)
                        : const Color(0xff969799)),
              ),
              if (widget.showIndicator)
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
}
