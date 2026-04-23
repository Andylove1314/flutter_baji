import 'package:get/get.dart';

class RmbgLayerData {
  RxString stickerPath;
  RxBool locked;
  bool isTarget;
  double ratio;
  String name;

  RmbgLayerData(
      {required this.stickerPath,
      required this.locked,
      required this.isTarget,
      required this.ratio,
      required this.name});
}
