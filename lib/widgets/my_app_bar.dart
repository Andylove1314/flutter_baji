import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar(
      {super.key,
      required this.title,
      required this.action,
      this.onBack,
      this.bgColor,
      this.leadColor});

  final Widget title;
  final Widget action;
  final Color? bgColor;
  final Color? leadColor;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) {
    return _appBar();
  }

  Widget _appBar() {
    return AppBar(
      backgroundColor: bgColor ?? Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: leadColor ?? Colors.black,
          ),
          onPressed: onBack ?? () => {Get.back()}),
      title: title,
      centerTitle: true,
      actions: [
        action.marginOnly(right: 10),
      ],
    );
  }
}
