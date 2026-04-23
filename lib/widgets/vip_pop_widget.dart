import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

class VipTipPopWidget extends StatelessWidget {
  Function() onBuy;
  Function() onCancel;
  final String content;

  VipTipPopWidget(
      {super.key,
      required this.onBuy,
      required this.onCancel,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 5, top: 5),
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image.asset(
                      'icon_close_gray'.imageBjPng,
                      width: 18,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 30),
              child: Text(
                content,
                style: const TextStyle(
                    color: Color(0xff19191A),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 29),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 30)),
                          side: WidgetStateProperty.all(
                            const BorderSide(
                                color: Color(0xff979797),
                                width: 1), // 设置边框颜色和宽度
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50), // 设置圆角
                            ),
                          )),
                      onPressed: () {
                        Get.back();
                        onCancel.call();
                      },
                      child: const Text(
                        '放弃效果',
                        style: TextStyle(
                            color: Color(0xff19191A),
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  FilledButton(
                      onPressed: () async {
                        Get.back();
                        onBuy.call();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(const Color(0xffFF799E)),
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 30))),
                      child: const Text(
                        '购买会员',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
