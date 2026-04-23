import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baji/flutter_baji.dart';

const double strokeMin = 0.0;
const double strokeMax = 100.0;

/// CustomSlider
class CustomSlider extends StatefulWidget {
  Function(double strokeWidth)? onSlide;
  double strokeWmin;
  double strokeWmax;
  bool isShowSmallBig;
  double sliderWidth;

  CustomSlider({
    super.key,
    this.onSlide,
    required this.sliderWidth,
    required this.strokeWmin,
    required this.strokeWmax,
    this.isShowSmallBig = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomSliderState();
  }
}

class _CustomSliderState extends State<CustomSlider> {
  var sliderW;
  final sliderSize = 20.0;

  var lineLeft = 0.0;

  var strokeRatio;

  @override
  void initState() {
    sliderW = widget.sliderWidth - 60;
    var l = (sliderW - sliderSize);
    strokeRatio = (widget.strokeWmax - widget.strokeWmin) / l;
    _slide(l / 2, set: true, callback: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                widget.isShowSmallBig ? '小' : '${widget.strokeWmin.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF969799),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              height: 20,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'icon_daxiao'.imageBjPng,
                      width: sliderW,
                      height: 8,
                    ),
                  ),
                  Positioned(
                      left: lineLeft,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails e) {
                          _slide(e.delta.dx);
                        },
                        child: Container(
                          width: sliderSize,
                          height: sliderSize,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(sliderSize / 2),
                              border: Border.all(
                                  color: const Color(0xff565656), width: 3)),
                        ),
                      ))
                ],
              ),
            ),
            // const SizedBox(
            //   width: 5,
            // ),
            SizedBox(
              width: 30,
              child: Text(
                widget.isShowSmallBig ? '大' : '${widget.strokeWmax.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF969799),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // IconButton(
            //   onPressed: () {
            //     _slide((sliderW - sliderSize) / 2, set: true);
            //   },
            //   icon: Image.asset(
            //     'icon_cancel_shadow'.imagePng,
            //     width: 20,
            //   ),
            // )
          ],
        ));
  }

  void _slide(double delta, {bool set = false, bool callback = true}) {
    if (set) {
      lineLeft = delta;
    } else {
      lineLeft += delta;
    }

    ///贴边限制
    if (lineLeft <= 0.0) {
      lineLeft = 0.0;
    }
    if (lineLeft >= sliderW - sliderSize) {
      lineLeft = sliderW - sliderSize;
    }
    if (!set || callback) {
      widget.onSlide?.call(widget.strokeWmin + strokeRatio * lineLeft);
    }

    setState(() {});
  }
}
