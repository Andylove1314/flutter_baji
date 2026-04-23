import 'dart:math' as math;

class ColorFilterGenerator {
  static List<double> matrix({
    double opacity = 1.0,
    double hue = 0.0,
    double saturation = 0.0,
    double brightness = 0.0,
    double contrast = 0.0,
  }) {
    final List<double> m = List<double>.filled(20, 0.0);

    // 亮度矩阵ok
    final double b = brightness;
    final List<double> brightnessMatrix = [
      1 + b,
      0,
      0,
      0,
      0,
      0,
      1 + b,
      0,
      0,
      0,
      0,
      0,
      1 + b,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // 对比度矩阵
    final double c = contrast;
    final List<double> contrastMatrix = [
      1, 0, 0, 0, 0, // 当contrast=0时，保持原始对比度
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

    if (c != 0) {
      // 只有在需要调整对比度时才修改矩阵
      final double factor = c + 1;
      final double t = -0.5 * c;
      contrastMatrix[0] = factor;
      contrastMatrix[6] = factor;
      contrastMatrix[12] = factor;
      contrastMatrix[4] = t * 255;
      contrastMatrix[9] = t * 255;
      contrastMatrix[14] = t * 255;
    }

    // 饱和度矩阵
    final double s = saturation;
    const double sr = 0.213;
    const double sg = 0.715;
    const double sb = 0.072;
    final List<double> saturationMatrix = [
      (sr * (1 - s) + s),
      sg * (1 - s),
      sb * (1 - s),
      0,
      0,
      sr * (1 - s),
      (sg * (1 - s) + s),
      sb * (1 - s),
      0,
      0,
      sr * (1 - s),
      sg * (1 - s),
      (sb * (1 - s) + s),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // 色相矩阵 - 修正后的计算方式ok
    final double h = hue * math.pi;
    final double cos = math.cos(h);
    final double sin = math.sin(h);
    final List<double> hueMatrix = [
      (sr * (1 - cos) + cos),
      (sg * (1 - cos) - sin),
      (sb * (1 - cos) + sin),
      0,
      0,
      (sr * (1 - cos) + sin),
      (sg * (1 - cos) + cos),
      (sb * (1 - cos) - sin),
      0,
      0,
      (sr * (1 - cos) - sin),
      (sg * (1 - cos) + sin),
      (sb * (1 - cos) + cos),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // 透明度矩阵ok
    final List<double> opacityMatrix = [
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      opacity,
      0,
    ];

    // 合并所有矩阵时加入透明度
    for (int i = 0; i < 20; i++) {
      m[i] = brightnessMatrix[i] *
          contrastMatrix[i] *
          saturationMatrix[i] *
          hueMatrix[i] *
          opacityMatrix[i];
      // m[i] = hueMatrix[i];
      // m[i] = brightnessMatrix[i];
      // m[i] = opacityMatrix[i];
      // m[i] = contrastMatrix[i];
      // m[i] = saturationMatrix[i];
    }

    return m;
  }
}
