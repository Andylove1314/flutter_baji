import 'package:flutter/material.dart';

import '../flutter_baji.dart';

typedef SaveCallback = Future<void> Function(
    String tmpPath, bool usePrint, bool isJpg);
typedef FetchTextureCallback = Future<List<BjTextureData>> Function();
typedef EnhanceCallback = Future<String?> Function(String path, String type);
typedef UploadMineMaterialCallback = Future<bool> Function(
    String path, String type);
typedef MineMaterialDeleteCallback = Future<bool> Function(dynamic id);
typedef AiRemoveBgCallback = Future<String?> Function(String path);
typedef FetchBgColorCallback = Future<List<BjColorData>> Function();
typedef FetchBgTextureCallback = Future<List<BjTextureData>> Function();
typedef FeedbackCallback = Future<bool> Function(String content);

typedef UploadBajiCallback = Future<String?> Function(dynamic image,
    {dynamic templateId});

typedef LogEventCallback = void Function(String name,
    {Map<String, dynamic>? params});

typedef ImageShareCallback = void Function(
    BuildContext context,
    Widget bjWidget,
    dynamic image,
    String imgUrl,
    String title,
    String content);

typedef FetchFumoCallback = Future<List<BjFumoData>> Function();

typedef PrintGoodsCallback = Future<void> Function(
    PrintBajiData printBajiData, String type);

typedef BloodTipClickCallback = Future<void> Function();

typedef SaveTemplateCallback = Future<bool> Function(
    {required String maker,
    required String templateImage,
    required String templateName,
    required String templateParam});

typedef CopyTemplateCallback = Future<bool> Function(
    {required String makerName, required String templateParam});

typedef UploadTemplateImageCallback = Future<String?> Function(
    String imagePath);

typedef GoldenGyTipClickCallback = Future<void> Function();
