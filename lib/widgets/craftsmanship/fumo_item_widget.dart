import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import 'package:get/get.dart';

import '../../utils/base_util.dart';

class FumoItemWidget extends StatelessWidget {
  BjFumoData? item;
  bool isSmall;
  bool isSelect;
  FumoItemWidget({super.key, this.item, this.isSmall = false, this.isSelect = false});

  @override
  Widget build(BuildContext context) {
    return _buildSelectMoItem(item);
  }

  Widget _buildSelectMoItem(BjFumoData? item) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
      margin: const EdgeInsets.only(left: 10),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
          color: (isSmall && isSelect) ? Colors.black : Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 51,
              height: 51,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xff585858),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item == null
                  ? const SizedBox()
                  : NetImage(
                      url: item.image ?? '',
                      width: 51,
                      height: 51,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (!isSmall)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '覆膜',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ).marginOnly(left: 12),
                  Row(
                    children: [
                      if (item == null) BaseUtil.loadingWidget(size: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xffB1B1B3), width: 1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            item == null
                                ? const SizedBox(
                                    width: 14,
                                  )
                                : NetImage(
                                    url: item.image ?? '',
                                    width: 14,
                                    height: 14,
                                  ),
                            const SizedBox(
                              width: 3,
                            ),
                            SizedBox(
                              width: 50,
                              child: AutoSizeText(
                                item?.name ?? '',
                                style: const TextStyle(
                                  color: Color(0xff1E1925),
                                  fontSize: 14,
                                ),
                                minFontSize: 8,
                                maxFontSize: 14,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ).marginOnly(left: 12),
                      const IconButton(
                          onPressed: null,
                          icon: (SizedBox(
                            width: 10,
                          )))
                    ],
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
