import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:flutter_baji/widgets/net_image.dart';
import 'package:flutter_baji_example/bj_oss_config.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_baji/flutter_baji.dart';
import 'package:image_picker/image_picker.dart';

import 'bj_oss_upload_util.dart';
import 'bj_upload_resp.dart';
import 'route_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterBajiPlugin = FlutterBaji();
  final _picker = ImagePicker();

  final TextEditingController _templateController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _maker;

  bool _isVipValue = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<String?> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      debugPrint('选择图片成功： ${pickedFile?.path}');
      return pickedFile?.path;
    } catch (e) {
      debugPrint('选择图片失败: $e');
    }

    return null;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _flutterBajiPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 将 MaterialApp 改为 GetMaterialApp
      home: Builder(
          builder: (ctx) => Scaffold(
                appBar: AppBar(
                  title: const Text('编辑类 app'),
                  centerTitle: true,
                ),
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVipValue = !_isVipValue;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _isVipValue,
                              checkColor: Colors.pink,
                              activeColor: Colors.white,
                              onChanged: (v) {
                                setState(() {
                                  _isVipValue = v!;
                                });
                              },
                            ),
                            const Text(
                              '会员身份',
                              style: TextStyle(color: Colors.pink),
                            ),
                          ],
                        ),
                      ).marginSymmetric(vertical: 10),
                      Container(
                          height: 200,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '制作人：',
                                  ),
                                  Text(
                                    _maker ?? '',
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: TextField(
                                controller: _templateController,
                                textInputAction: TextInputAction.done,
                                focusNode: _focusNode,
                                maxLines: null,
                                decoration:
                                    const InputDecoration(hintText: '请输入模版参数'),
                              )),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          minimumSize: const Size(150, 40),
                                        ),
                                        onPressed: () async {
                                          if (_templateController
                                              .text.isEmpty) {
                                            _showToast(ctx, '请输入模版参数');
                                            return;
                                          }
                                          if (!_templateController.text
                                                  .contains('configSize') ||
                                              !_templateController.text
                                                  .contains('layerItems')) {
                                            _showToast(ctx, '模版格式错误');
                                            return;
                                          }
                                          _makeBaji(ctx,
                                              templateParams:
                                                  _templateController.text,
                                              makeTemplate: true,
                                              title: '编辑吧唧模版');
                                        },
                                        child: const Text(
                                          '编辑吧唧模版',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        minimumSize: const Size(150, 40),
                                      ),
                                      onPressed: () async {
                                        if (_templateController.text.isEmpty) {
                                          _showToast(ctx, '请输入模版参数');
                                          return;
                                        }
                                        if (!_templateController.text
                                                .contains('configSize') ||
                                            !_templateController.text
                                                .contains('layerItems')) {
                                          _showToast(ctx, '模版格式错误');
                                          return;
                                        }
                                        //copy
                                        Clipboard.setData(ClipboardData(
                                            text: _templateController.text));
                                        _showToast(ctx, '模板参数已拷贝');
                                      },
                                      child: const Text(
                                        '拷贝模版参数',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () async {
                          String? imagePath;
                          imagePath = await _pickImage();
                          _makeBaji(ctx, imagePath: imagePath);
                        },
                        child: const Text(
                          '制作吧唧',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () async {
                          _makeBaji(ctx, makeTemplate: true, title: '制作模版');
                        },
                        child: const Text(
                          '制作吧唧模版',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(
                              '-------------------------------------------------')
                          .marginAll(10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () async {
                          String? imagePath;
                          imagePath = await _pickImage();
                          _goEditor(ctx, '图片编辑', imagePath!);
                        },
                        child: const Text(
                          '图片编辑',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(
                              '-------------------------------------------------')
                          .marginAll(10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () async {
                          String? imagePath;
                          imagePath = await _pickImage();
                          _goRmbg(ctx, '去背景', imagePath!);
                        },
                        child: const Text(
                          '去背景',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(
                              '-------------------------------------------------')
                          .marginAll(10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () async {
                          String? imagePath;
                          imagePath = await _pickImage();
                          _cropHeader(ctx, imagePath, '裁剪头');
                        },
                        child: const Text(
                          '裁剪头',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
              )),
    );
  }

  Future<List<StickerData>> _fetchStickers(String upath) async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post(upath, data: {});
    debugPrint('online stickers: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<StickerData> groups = [];
      for (var item in lists) {
        StickerData stickerData = StickerData.fromJson(item);
        groups.add(stickerData);
      }

      return groups;
    } else {
      debugPrint('贴纸加载失败');
    }

    return [];
  }

  Future<List<FontsData>> _fetchFonts(String upath) async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-dev.bigwinepot.com/api/'));
    var response = await dio.post(upath, data: {});
    debugPrint('online fonts: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<FontsData> groups = [];
      for (var item in lists) {
        FontsData fontData = FontsData.fromJson(item);
        groups.add(fontData);
      }

      return groups;
    } else {
      debugPrint('字体加载失败');
    }

    return [];
  }

  Future<List<BjTextureData>> _fetchTextures() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/bgimg/in/demo', data: {});
    debugPrint('online fonts: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<BjTextureData> groups = [];
      for (var item in lists) {
        BjTextureData fontData = BjTextureData.fromJson(item);
        groups.add(fontData);
      }

      return groups;
    } else {
      debugPrint('纹理加载失败');
    }

    return [];
  }

  Future<List<BjTextureData>> _fetchBgImgTexture() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-dev.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/bgimg/out/demo', data: {});
    debugPrint('online fonts: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<BjTextureData> groups = [];
      for (var item in lists) {
        BjTextureData fontData = BjTextureData.fromJson(item);
        groups.add(fontData);
      }

      return groups;
    } else {
      debugPrint('背景图加载失败');
    }

    return [];
  }

  Future<List<BjColorData>> _fetchBgColors() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/bgcolor/out/demo', data: {});
    debugPrint('online colors: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'] as List;
      return lists.map((item) => BjColorData.fromJson(item)).toList();
    } else {
      debugPrint('背景色加载失败');
    }

    return [];
  }

  Future<List<BjFumoData>> _fetchFumoLists() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/bg/fumo/demo', data: {});
    debugPrint('online fumos: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'] as List;
      return lists.map((item) => BjFumoData.fromJson(item)).toList();
    } else {
      debugPrint('覆膜加载失败');
    }

    return [];
  }

  Future<bool> _saveTemplate(
      {required String maker,
      required String templateImage,
      required String templateName,
      required String templateParam}) async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/template/save/demo', data: {
      'maker': maker,
      'name': templateName,
      'image': templateImage,
      'params': templateParam
    });
    debugPrint('save template: ${response.toString()}');
    return response.statusCode == 200;
  }

  Future<List<RmbgbgData>> _fetchRmbgbg() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/rmbg/images/demo', data: {});
    debugPrint('online fonts: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<RmbgbgData> datas = [];
      for (var item in lists) {
        RmbgbgData fontData = RmbgbgData.fromJson(item);
        datas.add(fontData);
      }

      return datas;
    } else {
      debugPrint('背景图加载失败');
    }

    return [];
  }

  /// 制作吧唧
  void _makeBaji(
    BuildContext ctx, {
    String? imagePath,
    String? templateParams,
    bool makeTemplate = false,
    String? title,
    MakeType makeType = MakeType.allbjType,
    var templateId,
  }) {
    _initBaseConfig(ctx);
    // 添加导航到预览页面
    BajiUtil.goBaji(
      title: title,
      imagePath: imagePath,
      showMakeTemplate: makeTemplate,
      templateParams: templateParams,
      makeType: makeType,
      saveImage: (String tmp, bool usePrint, bool isJpg) async {
        if (usePrint) {
          String fileName = tmp.split('/').last;
          tmp = await _flutterBajiPlugin.saveImageWithDpi(
                  imagePath: tmp, name: fileName, isJpg: isJpg) ??
              '';
        }

        debugPrint('保存图片成功： $tmp');

        await GallerySaver.saveImage(tmp, albumName: 'Flu-Baji');
      },
      textureCallback: () {
        return _fetchTextures();
      },
      enhanceCallback: (String path, String type) async {
        // 上传图片
        String? url = await _uploadBjSrc(path);
        if (url == null) {
          return '';
        }
        // 发起免费任务
        Map? data = await _freeTask(type, url, 'free');
        if (data.isEmpty) {
          return '';
        }
        var taskId = data['id'];

        // 轮询任务
        String? output = await _freeQuery(taskId);

        return output;
      },
      aiRemoveBgCallback: (String path) async {
        // 上传图片
        String? url = await _uploadBjSrc(path);
        if (url == null) {
          return Future.value('');
        }
        // 发起免费任务
        Map? data = await _freeTask('rmbg', url, 'free');
        if (data.isEmpty) {
          return '';
        }
        var taskId = data['id'];

        // 轮询任务
        String? output = await _freeQuery(taskId);

        return output;
      },
      uploadMineMaterialCallback: (String path, String type) async {
        return Future.value(true);
      },
      mineMaterialDeleteCallback: (id) async {
        return Future.value(true);
      },
      bgColorCallback: () {
        return _fetchBgColors();
      },
      bgTextureCallback: () {
        return _fetchBgImgTexture();
      },
      feedbackCallback: (String content) {
        return Future.value(true);
      },
      uploadBajiCallback: (image, {var templateId}) {
        return Future.value('');
      },
      imageShareCallback: (BuildContext context, Widget bjWidget, image, imgUrl,
          title, content) {
        //分享图片
        debugPrint('分享图片: $image, $imgUrl, $title, $content');
        Get.bottomSheet(Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              bjWidget,
              const SizedBox(
                height: 10,
              ),
              Text(
                '$title \n\n $content',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ));
      },
      fumoCallback: () {
        return _fetchFumoLists();
      },
      printGoodsCallback: (PrintBajiData printBajiData, String type) async {
        debugPrint('打印商品: $printBajiData, $type');
        Get.dialog(Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                color: Colors.white,
                child: Column(
                  children: [
                    if (printBajiData.fumoData != null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 100,
                              height: 100,
                              child: NetImage(
                                  url: printBajiData.fumoData?.image ?? '')),
                          Text(
                            '${printBajiData.fumoData?.name}',
                          )
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: printBajiData.tipPrintBaji!),
                            const Text(
                              '正面',
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: printBajiData.tipPrintBack!),
                            const Text(
                              '背面',
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.file(
                                    File(printBajiData.printBajiPath ?? ''))),
                            Text(
                              printBajiData.name ?? '',
                            )
                          ],
                        ),
                        if (printBajiData.printGyPath != null)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.file(
                                      File(printBajiData.printGyPath ?? ''))),
                              Text(
                                printBajiData.gyName ?? '',
                              )
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
        return Future.value();
      },
      bloodTipClickCallback: () async {
        debugPrint('血线说明');
      },
      goldenGyTipClickCallback: () async {
        debugPrint('烫金说明');
      },
      saveTemplateCallback: (
          {required String maker,
          required String templateImage,
          required String templateName,
          required String templateParam}) {
        debugPrint(
            '保存模板: $maker, $templateImage, $templateName, $templateParam');

        _templateController.text = templateParam;
        setState(() {
          _maker = maker;
        });

        return _saveTemplate(
            maker: maker,
            templateImage: templateImage,
            templateName: templateName,
            templateParam: templateParam);
      },
      copyTemplateCallback: (
          {required String makerName, required String templateParam}) async {
        _templateController.text = templateParam;
        setState(() {
          _maker = makerName;
        });
        Clipboard.setData(ClipboardData(text: templateParam));
        _showToast(ctx, '模板参数已拷贝');
        return true;
      },
      uploadTemplateImageCallback: (imagePath) {
        return _uploadTemplate(imagePath);
      },
    );
  }

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      // 对于 Android
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      }
      // 对于 iOS
      else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;

        return iosInfo.model;
      }
    } catch (e) {}

    return '';
  }

  Future<String?> _uploadTemplate(String imagePath) async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/baji/template/upload/config/demo');

    if (response.statusCode == 200) {
      var data = response.data;
      var config = data['data'];
      debugPrint('upload config: $config');
      BjUploadResp resp = await upload(BjOssConfig.fromJson(config), imagePath);
      return resp.url;
    }

    return '';
  }

  Future<Map<String, dynamic>> _freeTask(
      String taskType, String url, String adType) async {
    var req = {};
    req['taskType'] = taskType;
    req['adType'] = adType;
    req['input'] = [
      {'url': url}
    ];

    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/free/task/create/demo', data: req);
    debugPrint('free task: ${response.data}');
    if (response.statusCode == 200) {
      return response.data['data']['task'];
    }
    return {};
  }

  /// _queryFreeTask
  Future<Map<String, dynamic>> _queryFreeTask(var taskId) async {
    var req = {'taskId': taskId};
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/free/task/info/demo', data: req);
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    return {};
  }

  /// _getOssconfigGuest
  Future<String?> _uploadBjSrc(String imagePath) async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api-test.bigwinepot.com/api/'));
    var response = await dio.post('v1/task/upload/config/guest/demo');
    if (response.statusCode == 200) {
      BjOssConfig config = BjOssConfig.fromJson(response.data['data']);
      BjUploadResp resp = await upload(config, imagePath);
      return resp.url;
    }
    return '';
  }

  Future<String?> _freeQuery(var id) async {
    await Future.delayed(3.seconds);

    var data = await _queryFreeTask(id);

    ///未完成，重试
    if (data == null || data.isEmpty || data['phase'] != 7) {
      return _freeQuery(id);
    }

    return data['outputUrl'];
  }

  _showToast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating, // 可选：让 SnackBar 浮动
        margin: EdgeInsets.only(
            bottom: Get.height - Get.statusBarHeight + 20,
            left: 40,
            right: 40), // 调整顶部边距
      ),
    );
  }

  Future<void> _goEditor(BuildContext ctx, String title, String path) async {
    _initBaseConfig(ctx);
    EditorUtil.goFluEditor(context,
        // type: EditorType.text,
        // singleEditorSave: true,
        showFeatureDialog: true,
        title: title,
        orignal: path, filtersCb: () {
      return _fetchLJ();
    }, framesCb: () {
      return _fetchFrames();
    }, homeSavedCb: (context, after) {
      GallerySaver.saveImage(after, albumName: 'Flu-editor');
      _showToast(context, '保存成功');
    });
  }

  Future<void> _goRmbg(BuildContext ctx, String title, String path) async {
    _initBaseConfig(ctx);
    RmbgUtil.goRmbg(context,
        // type: RmbgType.rmbg,
        title: title,
        orignal: path, saveCb: (context, afterPath) {
      GallerySaver.saveImage(afterPath, albumName: 'Flu-rmbg');
      _showToast(context, '保存成功');
      return Future.value(true);
    }, idphotoCb: (context, afterPath) {
      debugPrint('去证件照');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return RoutePage(
            title: 'idPhoto',
            savedPath: afterPath,
          );
        },
      ));
      return Future.value(true);
    }, aiRemoveBgCb: (String path) async {
// 上传图片
      String? url = await _uploadBjSrc(path);
      if (url == null) {
        return Future.value('');
      }
      // 发起免费任务
      Map? data = await _freeTask('rmbg', url, 'free');
      if (data.isEmpty) {
        return '';
      }
      var taskId = data['id'];

      // 轮询任务
      String? output = await _freeQuery(taskId);

      return output;
    }, fetchRmbgDataCb: () async {
      return await _fetchRmbgbg();
    });
  }

  Future<List<EffectData>> _fetchPF() async {
    return await [
      EffectData.fromJson({
        'name': 'test',
        // 'image':
        //     'https://github.com/Andylove1314/flu_editors/blob/1.0.4/example/assets/effect.jpg',
        'asset': 'assets/effect.jpg',
        'id': 0,
        'params': jsonEncode({
          "Brightness": 0.14719999999999997,
          "Saturation": 1.0,
          "Contrast": 1.0,
          "Sharpen": 0.0,
          "Shadow": 0.0,
          "Temperature": 0.0,
          "Noise": 0.0,
          "Exposure": 0.0,
          "Vibrance": 0.0,
          "Highlight": 0.0,
          "Red": 1.0,
          "Green": 1.0,
          "Blue": 1.0,
          "CenterX": 0.5,
          "CenterY": 0.5,
          "Start": 1.0,
          "End": 1.0
        })
      })
    ];
  }

  Future<List<FilterData>> _fetchLJ() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api.bigwinepot.com/api/'));
    var response = await dio.post('v1/index/filters/demo', data: {});
    debugPrint('online filtes: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<FilterData> groups = [];
      for (var item in lists) {
        FilterData filterData = FilterData.fromJson(item);
        groups.add(filterData);
      }

      return groups;
    } else {
      _showToast(context, '滤镜加载失败');
    }

    return [];
  }

  Future<List<FrameData>> _fetchFrames() async {
    Dio dio = Dio(BaseOptions(
        method: 'post', baseUrl: 'https://nwdn-api.bigwinepot.com/api/'));
    var response = await dio.post('v1/index/frame/demo', data: {});
    debugPrint('online frames: ${response.toString()}');

    if (response.statusCode == 200) {
      var data = response.data;
      var lists = data['data'];

      List<FrameData> groups = [];
      for (var item in lists) {
        FrameData frameData = FrameData.fromJson(item);
        groups.add(frameData);
      }

      return groups;
    } else {
      debugPrint('相框加载失败');
    }

    return [];
  }

  Widget _loadingWidget(BuildContext context, islight, size, stroke) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: islight ? Colors.white : Colors.black,
        strokeWidth: stroke,
      ),
    );
  }

  void _showLoadingPop(BuildContext context, String? msg) {
    Get.dialog(
        barrierDismissible: false,
        Center(
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                if (msg != null)
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      msg,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
              ],
            ),
          ),
        ));
  }

  void _initBaseConfig(BuildContext context) {
    BaseUtil.configCallback(
      logEventCallback: (String name, {Map<String, dynamic>? params}) {
        //打印日志
        debugPrint('logEvent: $name, $params');
      },
      loginCheckCallback: () {
        return Future.value(true);
      },
      pickImage: () {
        return _pickImage();
      },
      showLoadingCallback: (BuildContext context, {String? msg}) {
        _showLoadingPop(context, msg);
      },
      hideLoadingCallback: () {
        Get.back();
      },
      loadingWidgetCallback: (slight, size, stroke) =>
          _loadingWidget(context, slight, size, stroke),
      toastActionCallback: (msg) => _showToast(context, msg),
      membership: () => _isVipValue,
      vipBuyCallback: () {
        debugPrint('去购买会员');
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return RoutePage(
              title: 'Sub page',
            );
          },
        ));
      },
      stickerCallback: (int type) {
        if (type == 0) {
          return _fetchStickers('v1/baji/bg/stickers/demo');
        } else if (type == 1) {
          return _fetchStickers('v1/index/stickers/demo');
        }

        return Future.value([]);
      },
      fontCallback: (int type) {
        if (type == 0) {
          return _fetchFonts('v1/baji/bg/font/demo');
        } else if (type == 1) {
          return _fetchFonts('v1/index/font/demo');
        }
        return Future.value([]);
      },
      deviceNameCallback: () async {
        return _getDeviceName();
      },
      effectsCb: (type, page) async => await _fetchPF(),
      saveEffectCb: (type, effect) async {
        debugPrint('保存配方：${effect.toJson()}');
        return await true;
      },
      deleteEffectCb: (type, id) async {
        debugPrint('删除配方：$id');
        return await true;
      },
    );
  }

  /// 裁剪头
  Future<void> _cropHeader(
      BuildContext context, String? imagePath, String title, {bool showTipImage = true}) async {
    if (imagePath != null) {
      String? afterPath = await EditorUtil.goCropHeaderPage(
        context, imagePath, title,
        // isCircle: true,
        // aspectRatio: 1.0,
        // maskAsset: 'pre_bg'.imageBjPng,
        showTipImage: showTipImage,
      );
      if (afterPath != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return RoutePage(
              title: 'cropHeader',
              savedPath: afterPath,
            );
          },
        ));
      }
    }
  }
}
