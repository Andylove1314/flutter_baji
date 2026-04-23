import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import '../../models/craftsmanship_data.dart';

class FumoTypeListWidget extends StatefulWidget {
  final Function(BjFumoData)? onTap;
  BjFumoData? currentFumoData;
  Function()? onClose;

  final List<BjFumoData> fumos;

  FumoTypeListWidget(
      {super.key,
      required this.fumos,
      this.currentFumoData,
      this.onTap,
      this.onClose});

  @override
  State<StatefulWidget> createState() {
    return _CraftsmanshipTypeListWidgetState();
  }
}

class _CraftsmanshipTypeListWidgetState extends State<FumoTypeListWidget> {
  BjFumoData? _currentFumoData;

  @override
  void initState() {
    _currentFumoData = widget.currentFumoData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 30),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
              bottomLeft: Radius.circular(8))),
      child: Column(
        children: [
          Expanded(
            child: widget.fumos.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 23, vertical: 14),
                    itemCount: widget.fumos.length,
                    itemBuilder: (context, index) {
                      BjFumoData data = widget.fumos[index];
                      bool isSelected = _currentFumoData == data;

                      return _buildItem(data, isSelected);
                    },
                  ),
          ),
          _confirmBar()
        ],
      ),
    );
  }

  Widget _confirmBar() {
    return Container(
      width: 161,
      height: 31,
      margin: const EdgeInsets.only(bottom: 20),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(31),
            ),
          ),
        ),
        onPressed: () {
          widget.onClose?.call();
        },
        child: const Icon(
          Icons.check,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildItem(BjFumoData data, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (data == _currentFumoData) {
          return;
        }
        setState(() {
          _currentFumoData = data;
        });
        widget.onTap?.call(_currentFumoData!);
      },
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 17,
              height: 17,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      fill: 1,
                      Icons.check,
                      size: 12,
                      color: Colors.black,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              data.name ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (data.image != null)
              SizedBox(
                width: 43,
                height: 43,
                child: NetImage(
                  url: data.image ?? '',
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
