import 'package:flutter/material.dart';
import '../confirm_bar.dart';
import '../custom_slider.dart';
import 'rmbg_bg_panel.dart';

class RmbgChangeBgPanel extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final String bgUrl;
  final Function(String path, String bgUrl) onSelected;

  final Function(BgActionMode mode)? onModeChange;

  const RmbgChangeBgPanel(
      {Key? key,
      this.onClose,
      this.onConfirm,
      this.onModeChange,
      required this.onSelected,
      required this.bgUrl})
      : super(key: key);

  @override
  State<RmbgChangeBgPanel> createState() => _RemoveBgPanelState();
}

enum BgActionMode { load, list, remove }

class _RemoveBgPanelState extends State<RmbgChangeBgPanel> {
  BgActionMode _currentMode = BgActionMode.list;

  String _bgUrl = '';

  @override
  void initState() {
    _bgUrl = widget.bgUrl;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RmbgChangeBgPanel oldWidget) {
    _bgUrl = widget.bgUrl;
    debugPrint('RmbgChangeBgPanel didUpdateWidget $_bgUrl');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget action = Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 21),
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
          RmbgBgPanel(
            bgUrl: _bgUrl,
            onSelected: widget.onSelected,
          ),
          ConfirmBar(
            cancel: widget.onClose,
            confirm: widget.onConfirm,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeButton('导入背景', BgActionMode.load, true),
                const SizedBox(width: 30),
                _buildModeButton('背景图', BgActionMode.list, false),
                const SizedBox(width: 30),
                _buildModeButton('删除背景', BgActionMode.remove, true)
              ],
            ),
          )
        ],
      ),
    );
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
      ],
    );
  }

  Widget _buildModeButton(String text, BgActionMode mode, bool onlyClick) {
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
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
          Container(
            width: 10,
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xffFF1A5A) : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
