import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/ui_utils.dart';

class SaveJpgPngPopWidget extends StatelessWidget {
  Function() onSaveJpg;
  Function() onSavePng;

  SaveJpgPngPopWidget(
      {super.key, required this.onSaveJpg, required this.onSavePng});

  @override
  Widget build(BuildContext context) {
    final w = UIUtils.isSquareScreen ? Get.width / 2 : Get.width;
    return Container(
      width: w - 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 5,
                offset: const Offset(0, 0))
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 30),
            child: Text(
              '选择保存格式',
              style: TextStyle(
                  color: Color(0xff19191A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: w - 140,
            child: OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 30)),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Color(0xff979797), width: 1),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  onSaveJpg.call();
                },
                child: const Text(
                  'JPG格式',
                  style: TextStyle(
                      color: Color(0xff19191A),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: w - 140,
            child: OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 30)),
                  side: WidgetStateProperty.all(
                    const BorderSide(
                        color: Color(0xff979797), width: 1), // 设置边框颜色和宽度
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  onSavePng.call();
                },
                child: const Text(
                  'PNG格式',
                  style: TextStyle(
                      color: Color(0xff19191A),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                )),
          ),
          const SizedBox(
            height: 29,
          ),
        ],
      ),
    );
  }
}
