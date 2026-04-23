import 'package:flutter/material.dart';

import '../flutter_baji.dart';

typedef FetchImageCallback = Future<String?> Function();
typedef Membership = bool Function();
typedef VipBuyCallback = void Function();
typedef FetchStickerCallback = Future<List<StickerData>> Function(int type);
typedef FetchFontCallback = Future<List<FontsData>> Function(int type);
typedef LoadingWidgetCallback = Widget Function(
    bool isLight, double size, double stroke);
typedef ToastActionCallback = void Function(String msg);
typedef LoginCheckCallback = Future<bool> Function();
typedef ShowLoadingCallback = void Function(BuildContext context,
    {String? msg});
typedef HideLoadingCallback = void Function();

typedef DeviceNameCallback = Future<String> Function();

typedef SaveEffectCallback = Future<bool> Function(int type, EffectData effect);
typedef DeleteEffectCallback = Future<bool> Function(
    int type, dynamic effectId);
typedef EffectsCallback = Future<List<EffectData>> Function(int type, int page);
