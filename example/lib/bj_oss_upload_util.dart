import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

import 'bj_oss_config.dart';
import 'bj_upload_resp.dart';

/// upload oss
Future<BjUploadResp> upload(BjOssConfig config, var source,
    {bool video = false,
    Function(int progress, int total)? onProgress,
    CancelToken? cancelToken,
    bool deleteInput = false}) async {
  Client client = Client.init(
      ossEndpoint: config.endpoint ?? '',
      bucketName: config?.bucket ?? '',
      authGetter: () {
        return Auth(
          accessKey: config.credentials?.accessKeyId ?? '',
          accessSecret: config.credentials?.accessKeySecret ?? '',
          expire: config.credentials?.expiration ?? '',
          secureToken: config.credentials?.securityToken ?? '',
        );
      });

  Response<dynamic>? back;

  try {
    if (source is Uint8List) {
      back = await client.putObject(
        source.toList(),
        cancelToken: cancelToken,
        '${config.key}${DateTime.now().microsecondsSinceEpoch}${video ? '.mp4' : '.jpg'}',
        option: PutRequestOption(onSendProgress: (count, total) {
          debugPrint("sent = $count, total = $total");
          onProgress?.call(count, total);
        }, onReceiveProgress: (count, total) {
          debugPrint("received = $count, total = $total");
        }),
      );
    } else if (source is File) {
      back = await client.putObjectFile(
        source.path,
        cancelToken: cancelToken,
        fileKey:
            '${config.key}${DateTime.now().microsecondsSinceEpoch}${video ? '.mp4' : '.jpg'}',
        option: PutRequestOption(onSendProgress: (count, total) {
          debugPrint("sent = $count, total = $total");
          onProgress?.call(count, total);
        }, onReceiveProgress: (count, total) {
          debugPrint("received = $count, total = $total");
        }),
      );
    } else if (source is String) {
      back = await client.putObjectFile(
        source,
        cancelToken: cancelToken,
        fileKey:
            '${config.key}${DateTime.now().microsecondsSinceEpoch}${video ? '.mp4' : '.jpg'}',
        option: PutRequestOption(onSendProgress: (count, total) {
          debugPrint("sent = $count, total = $total");
          onProgress?.call(count, total);
        }, onReceiveProgress: (count, total) {
          debugPrint("received = $count, total = $total");
        }),
      );
    }
  } catch (e) {
    if (deleteInput) {
      _deleInput(source);
    }

    return BjUploadResp(-1, '$e', '');
  }

  if (deleteInput) {
    _deleInput(source);
  }

  return BjUploadResp(back?.statusCode ?? -1,
      back?.statusMessage ?? 'upload error', '${back?.realUri}');
}

/// 删除临时文件
void _deleInput(var source) {
  if (source is File) {
    source.exists().then((exist) {
      if (exist) {
        source.delete().then((b) {
          debugPrint('上传的临时文件已删除！');
        });
      }
    });
  } else if (source is String) {
    File tmp = File(source);
    tmp.exists().then((exist) {
      if (exist) {
        tmp.delete().then((b) {
          debugPrint('上传的临时文件已删除！');
        });
      }
    });
  }
}
