import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

class MainPanelBj extends StatelessWidget {
  final VoidCallback removeBackground;
  final VoidCallback changeBackground;
  final VoidCallback sticker;
  final VoidCallback text;
  final VoidCallback craftsmanship;

  const MainPanelBj(
      {super.key,
      required this.removeBackground,
      required this.changeBackground,
      required this.sticker,
      required this.text,
      required this.craftsmanship});
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton('橡皮擦', 'icon_qubg_baji', removeBackground),
          _buildActionButton('背景色', 'icon_changebg_baji', changeBackground),
          _buildActionButton('贴图', 'icon_sticker_baji', sticker),
          _buildActionButton('文字', 'icon_text_baji', text),
          _buildActionButton('工艺', 'icon_gy_baji', craftsmanship)
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, String iconName, VoidCallback callback) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        callback.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconName.imageBjPng,
            width: 24,
            height: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1925),
            ),
          ),
        ],
      ),
    );
  }
}
