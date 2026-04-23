import 'package:flutter/material.dart';

import '../flutter_baji.dart';

typedef IdphotoCallback = Future<bool> Function(
    BuildContext context, String afterPath);

typedef SaveRmbgCallback = Future<bool> Function(
    BuildContext context, String afterPath);

typedef AiRmbgCallback = Future<String?> Function(String afterPath);

typedef FetchrmbgDataCallback = Future<List<RmbgbgData>> Function();
