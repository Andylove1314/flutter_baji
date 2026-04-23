import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_baji_platform_interface.dart';

/// An implementation of [FlutterBajiPlatform] that uses method channels.
class MethodChannelFlutterBaji extends FlutterBajiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_baji');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<String?> saveImageWithDpi({
    required String imagePath,
    required String name,
    int dpi = 300,
    bool isJpg = true,
  }) async {
    try {
      final String? result =
          await methodChannel.invokeMethod('saveImageWithDpi', {
        'imagePath': imagePath,
        'dpi': dpi,
        'name': name,
        'isJpg': isJpg,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }
}
