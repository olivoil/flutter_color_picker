import 'dart:ui';

import 'package:color_picker/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final hsvColorProvider = StateNotifierProvider<HSVColorNotifier, HSVColor>(
    (ref) => HSVColorNotifier());

final hexProvider = Provider<String>((ref) {
  final hsvColor = ref.watch(hsvColorProvider);
  return '#${(hsvColor.toColor().value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFF1F1F1F),
          padding: EdgeInsets.all(40.0),
          child: ColorPicker(),
        ),
      ),
    );
  }
}

class ColorPicker extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final hsvColor = useProvider(hsvColorProvider);
    final hexString = useProvider(hexProvider);

    final hueController =
        useTextEditingController(text: hsvColor.hue.toStringAsFixed(0));
    final saturationController = useTextEditingController(
        text: (hsvColor.saturation * 100).toStringAsFixed(0));
    final valueController = useTextEditingController(
        text: (hsvColor.value * 100).toStringAsFixed(0));

    final redController = useTextEditingController(
        text: hsvColor.toColor().red.toStringAsFixed(0));
    final greenController = useTextEditingController(
        text: hsvColor.toColor().green.toStringAsFixed(0));
    final blueController = useTextEditingController(
        text: hsvColor.toColor().blue.toStringAsFixed(0));

    final hexController = useTextEditingController(text: hexString);

    useEffect(() {
      hueController.text = hsvColor.hue.toStringAsFixed(0);
      saturationController.text =
          (hsvColor.saturation * 100).toStringAsFixed(0);
      valueController.text = (hsvColor.value * 100).toStringAsFixed(0);

      redController.text = hsvColor.toColor().red.toStringAsFixed(0);
      greenController.text = hsvColor.toColor().green.toStringAsFixed(0);
      blueController.text = hsvColor.toColor().blue.toStringAsFixed(0);
    }, [hsvColor]);

    useEffect(() {
      hexController.text = hexString;
    }, [hexString]);

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Color(0xFF333333),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              decoration: BoxDecoration(
                color: hsvColor.toColor(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Container(
                height: double.infinity,
                child: SaturationAndBrightnessPicker(
                  hsvColor: hsvColor,
                  onColorSelected: (HSVColor color) {
                    context.read(hsvColorProvider.notifier).setColor(color);
                  },
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              width: 40.0,
              height: double.infinity,
              child: HuePicker(
                selectedHue: hsvColor.hue,
                onHueSelected: (double hue) {
                  context.read(hsvColorProvider.notifier).setHue(hue);
                },
              ),
            ),
            SizedBox(width: 20.0),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "H:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text("°"),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: hueController,
                        // focusNode: hueFocusNode,
                        onSubmitted: (String hue) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setHue(double.parse(hue));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "S:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              "%",
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: saturationController,
                        onSubmitted: (String saturation) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setSaturation(double.parse(saturation) / 100);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "B:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text("%"),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: valueController,
                        onSubmitted: (String value) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setValue(double.parse(value) / 100);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "R:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: redController,
                        // focusNode: hueFocusNode,
                        onSubmitted: (String red) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setRed(int.parse(red));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "G:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: greenController,
                        onSubmitted: (String green) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setGreen(int.parse(green));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "V:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.number,
                        controller: blueController,
                        onSubmitted: (String blue) {
                          context
                              .read(hsvColorProvider.notifier)
                              .setBlue(int.parse(blue));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        "H:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 0.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                        keyboardType: TextInputType.text,
                        controller: hexController,
                        onSubmitted: (String hex) {
                          context.read(hsvColorProvider.notifier).setHex(hex);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}

class HuePickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final hueGradientShader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 51, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 102, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 153, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 204, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 255, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 306, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 360, 1.0, 1.0).toColor(),
      ],
    ).createShader(rect);

    final paint = Paint()..shader = hueGradientShader;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HuePicker extends StatefulWidget {
  const HuePicker({
    Key? key,
    required this.selectedHue,
    required this.onHueSelected,
  }) : super(key: key);

  final double selectedHue;
  final ValueChanged<double>? onHueSelected;

  @override
  _HuePickerState createState() => _HuePickerState();
}

class _HuePickerState extends State<HuePicker> {
  void _onDragStart(DragStartDetails details) {
    if (widget.onHueSelected == null) {
      return;
    }

    final sliderPercent = _calculateSliderPercent(details.localPosition);
    widget.onHueSelected!(_hueFromSliderPercent(sliderPercent));
  }

  double _calculateSliderPercent(Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return (1.0 - (localPosition.dy / box.size.height)).clamp(0.0, 1.0);
  }

  double _hueFromSliderPercent(double sliderPercent) {
    return sliderPercent * 360.0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.onHueSelected == null) {
      return;
    }

    final sliderPercent = _calculateSliderPercent(details.localPosition);
    widget.onHueSelected!(_hueFromSliderPercent(sliderPercent));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        child: Stack(
          children: [
            CustomPaint(
              painter: HuePickerPainter(),
              size: Size.infinite,
            ),
            _buildSelector(constraints.maxHeight),
          ],
        ),
      );
    });
  }

  Widget _buildSelector(double height) {
    final huePercent = widget.selectedHue / 360;

    return Align(
        alignment: Alignment(0.0, 1.0 - (huePercent * 2)),
        child: Container(
          width: double.infinity,
          height: 3,
          color: Colors.white,
        ));
  }
}

class SaturationAndBrightnessPicker extends StatefulWidget {
  const SaturationAndBrightnessPicker({
    Key? key,
    required this.hsvColor,
    this.onColorSelected,
  }) : super(key: key);

  final HSVColor hsvColor;
  final ValueChanged<HSVColor>? onColorSelected;

  @override
  _SaturationAndBrightnessPickerState createState() =>
      _SaturationAndBrightnessPickerState();
}

class _SaturationAndBrightnessPickerState
    extends State<SaturationAndBrightnessPicker> {
  Offset _calculatePercentOffset(Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    return Offset(
      (localPosition.dx / box.size.width).clamp(0.0, 1.0),
      (1.0 - (localPosition.dy / box.size.height)).clamp(0.0, 1.0),
    );
  }

  HSVColor _hsvColorFromPercentOffset(Offset percentOffset) {
    return HSVColor.fromAHSV(
      widget.hsvColor.alpha,
      widget.hsvColor.hue,
      percentOffset.dx,
      percentOffset.dy,
    );
  }

  void _onDragStart(DragStartDetails details) {
    if (widget.onColorSelected == null) {
      return;
    }

    final percentOffset = _calculatePercentOffset(details.localPosition);
    widget.onColorSelected!(_hsvColorFromPercentOffset(percentOffset));
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.onColorSelected == null) {
      return;
    }

    final percentOffset = _calculatePercentOffset(details.localPosition);
    widget.onColorSelected!(_hsvColorFromPercentOffset(percentOffset));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        child: Stack(
          children: [
            CustomPaint(
              painter: SaturationAndBrightnessPickerPainter(
                hue: widget.hsvColor.hue,
              ),
              size: Size.infinite,
            ),
            _buildSelector(Size(constraints.maxWidth, constraints.maxHeight)),
          ],
        ),
      );
    });
  }

  Widget _buildSelector(Size size) {
    final double saturationPercent = widget.hsvColor.saturation;
    final double darknessPercent = 1.0 - widget.hsvColor.value;

    return Positioned(
      left: lerpDouble(0, size.width, saturationPercent),
      top: lerpDouble(0, size.height, darknessPercent),
      child: FractionalTranslation(
        translation: const Offset(-.5, -.5),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class SaturationAndBrightnessPickerPainter extends CustomPainter {
  SaturationAndBrightnessPickerPainter({required this.hue});

  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final lightShader = LinearGradient(
      colors: [Colors.white, Colors.black],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);

    final lightPaint = Paint()..shader = lightShader;
    canvas.drawRect(rect, lightPaint);

    final saturationShader = LinearGradient(
      colors: [
        HSVColor.fromAHSV(1.0, hue, 0.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect);

    final saturationPaint = Paint()
      ..shader = saturationShader
      ..blendMode = BlendMode.modulate;
    canvas.drawRect(rect, saturationPaint);
  }

  @override
  bool shouldRepaint(SaturationAndBrightnessPickerPainter oldDelegate) {
    return hue != oldDelegate.hue;
  }
}
