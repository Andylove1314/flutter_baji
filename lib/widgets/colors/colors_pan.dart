import 'package:flutter/material.dart';
import '../../constants/constant_editor.dart';
import '../../flutter_baji.dart';
import '../../models/action_data.dart';
import '../confirm_bar.dart';
import 'color_class_widget.dart';

class ColorsPan extends StatefulWidget {
  final Function(ActionData data)? onClick;
  final ColorsMulitConfiguration sourceFiltersConfig;
  final Function()? onEffectSave;

  List<ActionData>? tags;

  ColorsPan(
      {required this.sourceFiltersConfig,
      this.onClick,
      this.onEffectSave,
      this.tags});

  @override
  State<ColorsPan> createState() => _ColorsPanState();
}

class _ColorsPanState extends State<ColorsPan> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      widget.onClick?.call(colorActions[1]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 100,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: const Color(0xff19191A).withOpacity(0.1))
                ],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: ColorClassWidget(
              initIndex: 1,
              tags: colorActions,
              onClick: (data) {
                widget.onClick?.call(data);
              },
            )),
        ConfirmBar(
          content: const Center(
            child: Text(
              '调色',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff646466)),
            ),
          ),
          cancel: () {
            Navigator.of(context).pop();
          },
          confirm: () async {
            widget.onEffectSave?.call();
          },
        )
      ],
    );
  }
}
