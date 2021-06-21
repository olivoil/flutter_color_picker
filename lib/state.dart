import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HSVColorNotifier extends StateNotifier<HSVColor> {
  HSVColorNotifier() : super(HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0));

  void setColor(HSVColor color) {
    state = color;
  }

  void setHue(double hue) {
    if (hue < 0) {
      hue = 0;
    }

    if (hue > 360) {
      hue = 360;
    }

    state = state.withHue(hue);
  }

  void setSaturation(double saturation) {
    state = state.withSaturation(saturation);
  }

  void setValue(double value) {
    state = state.withValue(value);
  }

  void setRed(int r) {
    Color color = state.toColor();
    state = HSVColor.fromColor(color.withRed(r));
  }

  void setGreen(int g) {
    Color color = state.toColor();
    state = HSVColor.fromColor(color.withGreen(g));
  }

  void setBlue(int b) {
    Color color = state.toColor();
    state = HSVColor.fromColor(color.withBlue(b));
  }

  void setHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    Color color = Color(int.parse(buffer.toString(), radix: 16));
    state = HSVColor.fromColor(color);
  }
}
