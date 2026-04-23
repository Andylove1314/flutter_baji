library flutter_baji;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_baji/pages/editor_frame_page.dart';
import 'package:flutter_baji/pages/editor_text_page.dart';
import 'package:flutter_baji/utils/base_util.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/widgets.dart' hide Image;
import 'package:collection/collection.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baji/pages/bj_card_preview_page.dart';
import 'package:flutter_baji/pages/bj_home_page.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gpu_filters_interface/flutter_gpu_filters_interface.dart';
import 'package:path/path.dart' as path;

import 'callbacks/callback_bj.dart';
import 'callbacks/callback_editor.dart';
import 'callbacks/callback_rmbg.dart';
import 'controllers/editor_home_controller.dart';
import 'controllers/bj_home_controller.dart';
import 'controllers/rmbg_home_controller.dart';
import 'flutter_baji_platform_interface.dart';
import 'models/badge_config.dart';
import 'models/craftsmanship_data.dart';
import 'models/sticker_color_item.dart';
import 'models/template_data.dart';
import 'models/template_layer_item_data.dart';
import 'pages/editor_crop_page.dart';
import 'pages/editor_filter_page.dart';
import 'pages/editor_header_crop_page.dart';
import 'pages/editor_home_page.dart';
import 'pages/editor_sticker_page.dart';
import 'pages/bj_start_page.dart';
import 'pages/rmbg_home_page.dart';
import 'pages/rmbg_rm_page.dart';
import 'pages/rmbg_sure_page.dart';
import 'utils/editor_type.dart';
import 'utils/rmbg_type.dart';
import 'widgets/lindi/lindi_controller_2.dart';

export 'flutter_baji_platform_interface.dart';
export 'pages/bj_start_page.dart';

part 'utils/extension_util.dart';

part 'utils/baji_util.dart';

part 'utils/editor_util.dart';

part 'utils/rmbg_util.dart';

part 'models/sticker_data.dart';

part 'models/font_data.dart';

part 'models/bj_texture_data.dart';

part 'models/bj_bg_color_data.dart';

part 'models/bj_fumo_data.dart';

part 'models/effect_data.dart';

part 'utils/make_type.dart';

part 'models/print_baji.dart';

part 'editor/configuration/colors/highlight_configuration.dart';

part 'editor/configuration/colors/hue_configuration.dart';

part 'editor/configuration/colors/colors_mulit_configuration.dart';

part 'editor/configuration/colors/noise_configuration.dart';

part 'editor/configuration/colors/shadow_configuration.dart';

part 'editor/configuration/colors/sharpen_onfiguration.dart';

part 'editor/configuration/colors/temperature_configuration.dart';

part 'editor/configuration/colors/vibrance_configuration.dart';

part 'editor/configuration/colors/vignette_configuration.dart';

part 'editor/configuration/colors/whitebalance_configuration.dart';

part 'editor/configuration/colors/contrast_configuration.dart';

part 'editor/configuration/colors/exposure_configuration2.dart';

part 'editor/configuration/colors/brightness_configuration2.dart';

part 'editor/configuration/colors/saturation_configuration2.dart';

part 'editor/configuration/filters/lookup_configuration2.dart';

part 'editor/configuration/colors/opacity_configuration.dart';

part 'editor/base/configuration.dart';

part 'editor/base/parameters.dart';

part 'editor/base/image_shader_painter.dart';

part 'editor/base/image_shader_preview.dart';

part 'editor/base/pipeline_image_shader_preview.dart';

part 'editor/base/none.dart';

part 'editor/base/texture_source.dart';

part 'models/filter_config_data.dart';

part 'models/frame_data.dart';

part 'models/lut_data.dart';

part 'models/rmbg_bg_data.dart';

Map<Type, Future<FragmentProgram> Function()> _fragmentPrograms = {};

class FlutterBaji {
  Future<String?> getPlatformVersion() {
    return FlutterBajiPlatform.instance.getPlatformVersion();
  }

  Future<String?> saveImageWithDpi({
    required String imagePath,
    required String name,
    int dpi = 300,
    bool isJpg = true,
  }) {
    return FlutterBajiPlatform.instance.saveImageWithDpi(
        imagePath: imagePath, name: name, dpi: dpi, isJpg: isJpg);
  }
}

void register<T extends ShaderConfiguration>(
  Future<FragmentProgram> Function() fragmentProgramProvider, {
  bool override = false,
}) {
  if (override) {
    _fragmentPrograms[T] = fragmentProgramProvider;
  } else {
    _fragmentPrograms.putIfAbsent(
      T,
      () => fragmentProgramProvider,
    );
  }
}
