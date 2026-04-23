import 'package:flutter/material.dart';
import '../../flutter_baji.dart';
import 'color_solid_picker_panel.dart';
import 'color_gradient_picker_panel.dart';
import '../confirm_bar.dart';
import 'texture_bg_panel.dart';

enum BgColorType {
  solid,
  gradient,
  pattern,
}

class ChangeBgPanel extends StatefulWidget {
  final Function(GradientType type, List<Color> colors, List<double> stops)
      onGradientColorChanged; // 颜色改变回调
  final Function({BjTextureDetail? item, String? imgPath}) onTextureChanged;
  final Function(BgColorType type)? onTypeChanged;

  final VoidCallback? onClose;
  final VoidCallback? onConfirm;

  const ChangeBgPanel({
    Key? key,
    required this.onGradientColorChanged,
    required this.onTextureChanged,
    this.onClose,
    this.onConfirm,
    this.onTypeChanged,
  }) : super(key: key);

  @override
  State<ChangeBgPanel> createState() => _ChangeBgPanelState();
}

class _ChangeBgPanelState extends State<ChangeBgPanel> {
  BgColorType _currentType = BgColorType.solid;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildContent(),
          ConfirmBar(
            cancel: widget.onClose,
            confirm: widget.onConfirm,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _buildTabButton('纹理', BgColorType.pattern),
                _buildTabButton('纯色', BgColorType.solid),
                _buildTabButton('渐变色', BgColorType.gradient),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, BgColorType type) {
    final isSelected = type == _currentType;
    return GestureDetector(
      onTap: () {
        setState(() => _currentType = type);
        widget.onTypeChanged?.call(type);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ?  Color(0xffFF1A5A) : Color(0xff969799),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xffFF1A5A) : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentType) {
      case BgColorType.solid:
        return ColorSolidPickerPanel(
          onColorChanged: (color) {
            widget.onGradientColorChanged
                .call(GradientType.linear, [color, color], [0.0, 1.0]);
          },
        );
      case BgColorType.gradient:
        return ColorGradientPickerPanel(
            onGradientColorChanged: widget.onGradientColorChanged);
      case BgColorType.pattern:
        return TextureBgPanel(onTextureChanged: widget.onTextureChanged);
    }
  }
}
