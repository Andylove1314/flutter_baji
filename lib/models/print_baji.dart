part of '../../flutter_baji.dart';

/// 打印数据
class PrintBajiData {
  String? printBajiPath;
  String? printGyPath;
  String? name;
  String? gyName;
  CraftsmanshipData? craftsmanData;
  Widget? tipPrintBaji;
  Widget? tipPrintBack;
  BjFumoData? fumoData;
  String? bjName;
  ConfigSize? configSize;

// 构造函数
  PrintBajiData({
    this.printBajiPath,
    this.printGyPath,
    this.name,
    this.gyName,
    this.craftsmanData,
    this.tipPrintBaji,
    this.tipPrintBack,
    this.fumoData,
    this.bjName,
    this.configSize,
  });
}
