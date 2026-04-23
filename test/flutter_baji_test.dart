import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:flutter_baji/flutter_baji_platform_interface.dart';
import 'package:flutter_baji/flutter_baji_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBajiPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBajiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> saveImageWithDpi(
      {required String imagePath,
      required String name,
      int dpi = 300,
      bool isJpg = true}) {
    // TODO: implement saveImageWithDpi
    throw UnimplementedError();
  }
}

void main() {
  final FlutterBajiPlatform initialPlatform = FlutterBajiPlatform.instance;

  test('$MethodChannelFlutterBaji is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBaji>());
  });

  test('getPlatformVersion', () async {
    FlutterBaji flutterBajiPlugin = FlutterBaji();
    MockFlutterBajiPlatform fakePlatform = MockFlutterBajiPlatform();
    FlutterBajiPlatform.instance = fakePlatform;

    expect(await flutterBajiPlugin.getPlatformVersion(), '42');
  });
}
