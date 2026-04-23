import 'package:flutter_baji/flutter_baji.dart';

import '../models/action_data.dart';

final mainRmbgActions = [
  ActionData(type: 0, name: '去背景', icon: 'icon_qubg_baji'.imageBjPng),
  ActionData(type: 1, name: '证件照', icon: 'icon_zkz'.imageRmbgPng),
  ActionData(type: 2, name: '调色', icon: 'icon_color_edit@3x'.imageEditorPng),
  ActionData(type: 3, name: '背景色', icon: 'icon_bjs'.imageRmbgPng),
  ActionData(type: 4, name: '背景图', icon: 'icon_bjt'.imageRmbgPng),
  ActionData(
      type: 5, name: '添加图片', icon: 'icon_tjtp'.imageRmbgPng, requireVip: true)
];
