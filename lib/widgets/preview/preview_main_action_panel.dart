import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import '../../flutter_baji.dart';

class PreviewMainActionPanel extends StatelessWidget {
  final Function() onBgSelected;
  final Function() onPrintGoods;
  final actionHeight;

  final String currentBgImagePath;
  final Color currentBgColor;

  PreviewMainActionPanel(
      {super.key,
      required this.onBgSelected,
      required this.actionHeight,
      required this.onPrintGoods,
      required this.currentBgImagePath,
      required this.currentBgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: actionHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Expanded(
          //     child: GestureDetector(
          //   onTap: () {
          //     onMoSelected();
          //   },
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Text(
          //         currentFumoName.isEmpty ? '覆膜' : currentFumoName,
          //         style: const TextStyle(
          //             fontSize: 14,
          //             fontWeight: FontWeight.w600,
          //             color: Color(0xff1E1925)),
          //       ),
          //       const SizedBox(
          //         width: 7,
          //       ),
          //       Container(
          //         padding: const EdgeInsets.all(0),
          //         decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.white,
          //             border:
          //                 Border.all(color: const Color(0xff979797), width: 1)),
          //         width: 37,
          //         height: 37,
          //         child: ClipOval(
          //           child: currentFumoThumb.isEmpty
          //               ? const SizedBox()
          //               : NetImage(
          //                   url: currentFumoThumb,
          //                   fit: BoxFit.cover,
          //                 ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )),
          // Container(
          //   width: 1,
          //   height: 20,
          //   color: const Color(0xffE8E8E8),
          // ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              onBgSelected();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '背景',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1E1925)),
                ),
                const SizedBox(
                  width: 7,
                ),
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xff979797), width: 1)),
                  width: 37,
                  height: 37,
                  child: ClipOval(
                    child: currentBgColor != Colors.transparent
                        ? Container(
                            color: currentBgColor,
                          )
                        : currentBgImagePath.isEmpty
                            ? Image.asset(
                                'trans_color_icon'.imageBjPng,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(currentBgImagePath),
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ],
            ),
          )),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xffE8E8E8),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              onPrintGoods();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  width: 17,
                  'icon_shop_baji'.imageBjPng,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  width: 7,
                ),
                const Text(
                  '去印谷',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:  Color(0xffFF1A5A)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
      {Color? color,
      VoidCallback? onTap,
      Widget? child,
      bool isSelected = false}) {
    Widget icon = Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
    if (color == Colors.transparent) {
      icon = Image.asset(
        'icon_tm_color'.imageBjPng,
        width: 37,
        height: 37,
        fit: BoxFit.fill,
      );
    } else if (child != null) {
      icon = child;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: isSelected
                          ? const Color(0xffFF1A5A)
                          : Colors.transparent,
                      blurRadius: 5)
                ]),
            width: 37,
            height: 37,
          ),
          icon
        ],
      ),
    );
  }
}
