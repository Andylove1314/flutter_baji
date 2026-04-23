import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:get/get.dart';

import '../../utils/base_util.dart';
import '../bubble_container.dart';
import '../confirm_bar.dart';
import '../custom_slider.dart';

class RemoveBgPanel extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final VoidCallback? removeAd;
  final VoidCallback? adTask;
  final VoidCallback? undo;
  final VoidCallback? reset;

  final Function(double width)? paintWidthCallback;
  final Function(double intensity)? blureCallback;
  final Function(RemoveBgMode)? onModeChange;

  const RemoveBgPanel(
      {Key? key,
      this.onClose,
      this.onConfirm,
      this.removeAd,
      this.adTask,
      this.onModeChange,
      this.undo,
      this.reset,
      this.paintWidthCallback,
      this.blureCallback})
      : super(key: key);

  @override
  State<RemoveBgPanel> createState() => _RemoveBgPanelState();
}

enum RemoveBgMode { ai, erase, recoveryErase }

class _RemoveBgPanelState extends State<RemoveBgPanel> {
  RemoveBgMode _currentMode = RemoveBgMode.erase;
  double _edgeBlur = 50; // 边缘模糊度
  double _brushSize = 200; // 笔刷大小

  @override
  Widget build(BuildContext context) {
    Widget action = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentMode == RemoveBgMode.erase ||
              _currentMode == RemoveBgMode.recoveryErase) ...[
            Row(
              children: [
                const SizedBox(),
                // OutlinedButton(
                //   onPressed: () {
                //     widget.reset?.call();
                //   },
                //   style: OutlinedButton.styleFrom(
                //     side: const BorderSide(color: Color(0xFFDCDEE0)),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     minimumSize: const Size(80, 32),
                //   ),
                //   child: const Text(
                //     '复原',
                //     style: TextStyle(
                //       color: Color(0xFF323233),
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
                // const Spacer(),
                // OutlinedButton(
                //   onPressed: () {
                //     widget.undo?.call();
                //   },
                //   style: OutlinedButton.styleFrom(
                //     side: const BorderSide(color: Color(0xFFDCDEE0)),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     minimumSize: const Size(80, 32),
                //   ),
                //   child: const Text(
                //     '撤销',
                //     style: TextStyle(
                //       color: Color(0xFF323233),
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
              ],
            ),
            // _buildSliderRow('边缘模糊', 0, 100, false, (value) {
            //   _edgeBlur = value;
            //   widget.blureCallback?.call(_edgeBlur);
            // }),
            // const SizedBox(height: 6),
            _buildSliderRow('笔刷大小', 5, 45, true, (value) {
              _brushSize = value;
              widget.paintWidthCallback?.call(_brushSize);
            }),
          ],
          ConfirmBar(
            cancel: widget.onClose,
            confirm: widget.onConfirm,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeButton('AI抠图', RemoveBgMode.ai, true),
                const SizedBox(width: 30),
                // const SizedBox(width: 68),
                _buildModeButton('擦除', RemoveBgMode.erase, false),
                const SizedBox(width: 30),
                // _buildModeButton('恢复', RemoveBgMode.recoveryErase)

                _buildModeButton('复原', RemoveBgMode.recoveryErase, true)
              ],
            ),
          )
        ],
      ),
    );

    if (false) {
      //_currentMode == RemoveBgMode.ai
      action = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BubbleContainer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.removeAd?.call();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF626262),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '去广告',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () => {
                          widget.adTask?.call(),
                        },
                    child: Container(
                      margin: const EdgeInsets.only(left: 22),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:  Color(0xffFF1A5A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        BaseUtil.isMember() ? '免费使用' : '观看广告免费使用',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ))
              ],
            ),
          ).marginOnly(left: 20, bottom: 5),
          action,
        ],
      );
    }

    return action;
  }

  Widget _buildSliderRow(
    String label,
    double min,
    double max,
    bool isShowSmallBig,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF323233),
          ),
        ),
        Expanded(child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            debugPrint("Expanded 宽度: $width");
            return CustomSlider(
              sliderWidth: width,
              isShowSmallBig: isShowSmallBig,
              strokeWmin: min,
              strokeWmax: max,
              onSlide: (value) {
                debugPrint('CustomSlider value: $value');
                onChanged(value);
              },
            );
          },
        )),
        OutlinedButton(
          onPressed: () {
            widget.undo?.call();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFDCDEE0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            minimumSize: const Size(70, 32),
          ),
          child: const Text(
            '撤销',
            style: TextStyle(
              color: Color(0xFF323233),
              fontSize: 14,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildModeButton(String text, RemoveBgMode mode, bool onlyClick) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () {
        if (!onlyClick) {
          setState(() {
            _currentMode = mode;
          });
        }

        widget.onModeChange?.call(mode);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
                color: isSelected
                    ?  Color(0xffFF1A5A)
                    : const Color(0xff969799),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Container(
            width: 10,
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffFF1A5A) : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
