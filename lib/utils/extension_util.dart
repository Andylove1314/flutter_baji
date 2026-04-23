part of '../flutter_baji.dart';

extension assets on String {
  String get imageBjPng {
    String _imagesRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_imagesRoot}assets/images-bj/$this.png';
  }

  String get imageBjJpg {
    String _imagesRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_imagesRoot}assets/images-bj/$this.jpg';
  }

  String get imageFontsPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/fonts/$this.png';
  }

  String get imageEditorPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/images-editor/$this.png';
  }

  String get imageColorsPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/images-editor/colors/$this.png';
  }

  String get imageCropPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/images-editor/crop/$this.png';
  }

  String get imageFiltersPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/images-editor/filters/$this.png';
  }

  String get imageFramesPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}assets/images-editor/Frames/$this.png';
  }

  String get lutPng {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}luts/$this.png';
  }

  String get shader {
    String _lutsRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_lutsRoot}shaders/$this.frag';
  }

  String get imageRmbgPng {
    String _imagesRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_imagesRoot}assets/images-rmbg/$this.png';
  }

  String get imageRmbgJpg {
    String _imagesRoot = Platform.environment.containsKey('FLUTTER_TEST')
        ? ''
        : 'packages/flutter_baji/';

    return '${_imagesRoot}assets/images-rmbg/$this.jpg';
  }
}
