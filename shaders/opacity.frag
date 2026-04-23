#include <flutter/runtime_effect.glsl>
precision mediump float;

// 控制透明度的输入参数（0.0 ~ 1.0）
layout(location = 0) uniform lowp float inputOpacity;

// 屏幕尺寸，用于归一化纹理坐标
layout(location = 1) uniform vec2 screenSize;

// 输入的纹理
uniform lowp sampler2D inputImageTexture;

// 输出颜色
out vec4 fragColor;

// 应用透明度
vec4 processColor(vec4 sourceColor) {
    // 保持原始颜色的 RGB，只改变 Alpha 通道
    return vec4(sourceColor.rgb, sourceColor.a * inputOpacity);
}

void main() {
    // 获取当前像素对应的纹理坐标
    vec2 textureCoordinate = FlutterFragCoord().xy / screenSize;

    // 采样原始图像颜色
    vec4 textureColor = texture(inputImageTexture, textureCoordinate);

    // 输出结果颜色
    fragColor = processColor(textureColor);
}
