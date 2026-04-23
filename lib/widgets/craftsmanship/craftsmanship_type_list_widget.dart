import 'package:flutter/material.dart';
import '../../models/craftsmanship_data.dart';

class CraftsmanshipTypeListWidget extends StatefulWidget {
  final Function(CraftsmanshipData)? onTap;
  final CraftsmanshipData currentCraftsmanshipData;
  final bool canAddCraft;

  const CraftsmanshipTypeListWidget(
      {super.key,
      required this.currentCraftsmanshipData,
      this.onTap,
      required this.canAddCraft});

  @override
  State<StatefulWidget> createState() {
    return _CraftsmanshipTypeListWidgetState();
  }
}

class _CraftsmanshipTypeListWidgetState
    extends State<CraftsmanshipTypeListWidget> {
  late CraftsmanshipData _currentCraftsmanshipData;

  @override
  void initState() {
    _currentCraftsmanshipData = widget.currentCraftsmanshipData;
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 14),
              itemCount: CraftsmanshipData.craftsmanshipDatas.length,
              itemBuilder: (context, index) {
                CraftsmanshipData data =
                    CraftsmanshipData.craftsmanshipDatas[index];
                bool isSelected = _currentCraftsmanshipData == data;

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
          widget.onTap?.call(_currentCraftsmanshipData);
        },
        child: const Icon(
          Icons.check,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildItem(CraftsmanshipData data, bool isSelected) {
    bool isStampingGoldenOrUV = data.type == CraftsmanshipType.golden ||
        data.type == CraftsmanshipType.uv;

    return GestureDetector(
      onTap: () {
        ///可以设置工艺
        if (!isStampingGoldenOrUV || widget.canAddCraft) {
          if (data == _currentCraftsmanshipData) {
            return;
          }
          setState(() {
            _currentCraftsmanshipData = data;
          });
        }
      },
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Opacity(
              opacity:
                  (!isStampingGoldenOrUV || widget.canAddCraft) ? 1.0 : 0.2,
              child: Container(
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
            ),
            const SizedBox(width: 12),
            Text(
              data.name,
              style: TextStyle(
                fontSize: 14,
                color: (!isStampingGoldenOrUV || widget.canAddCraft)
                    ? Colors.white
                    : Colors.white.withOpacity(0.2),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (data.banner != null)
              SizedBox(
                width: 87,
                height: 38,
                child: Image.asset(
                  data.banner ?? '',
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
