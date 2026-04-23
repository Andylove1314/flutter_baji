import 'package:flutter/widgets.dart';

import '../flutter_baji.dart';

typedef FiltersCallback = Future<List<FilterData>> Function();
typedef FramesCallback = Future<List<FrameData>> Function();
typedef HomeSavedCallback = void Function(
    BuildContext context, String lastImage);
typedef BannerAdWidgetCallback = Widget Function();
typedef NativeAdWidgetCallback = Widget Function();

/// type 0 激励，1 插页，2 插页激励
typedef AdShowCallback = Future<bool?> Function(int type);
