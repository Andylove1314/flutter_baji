import 'package:flutter/material.dart';

/// 黑化widget
class BlackWidget extends StatelessWidget {
  final bool balck;
  final Widget content;
  const BlackWidget({super.key, required this.balck, required this.content});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: balck
          ? const ColorFilter.matrix([
              0, 0, 0, 0, 0, // R
              0, 0, 0, 0, 0, // G
              0, 0, 0, 0, 0, // B
              0, 0, 0, 1, 0, // A
            ])
          : const ColorFilter.matrix([
              1, 0, 0, 0, 0, // R
              0, 1, 0, 0, 0, // G
              0, 0, 1, 0, 0, // B
              0, 0, 0, 1, 0, // A
            ]),
      child: content,
    );
  }
}
