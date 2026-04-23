import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_baji_method_channel.dart';

abstract class FlutterBajiPlatform extends PlatformInterface {
  /// Constructs a FlutterBajiPlatform.
  FlutterBajiPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBajiPlatform _instance = MethodChannelFlutterBaji();

  /// The default instance of [FlutterBajiPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBaji].
  static FlutterBajiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBajiPlatform] when
  /// they register themselves.
  static set instance(FlutterBajiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> saveImageWithDpi({
    required String imagePath,
    required String name,
    int dpi = 300,
    bool isJpg = true,
  }) {
    throw UnimplementedError('saveImageWithDpi() has not been implemented.');
  }
}
