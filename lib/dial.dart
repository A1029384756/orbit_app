import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class Dial extends StatefulWidget {
  const Dial(
      {Key? key,
      required this.radius,
      required this.maxRotation,
      required this.rotationValue,
      required this.onOff,
      required this.onTap,
      required this.onDialUpdate})
      : super(key: key);
  final int radius;
  final double maxRotation;
  final double rotationValue;
  final bool onOff;
  final VoidCallback onTap;
  final Function(double) onDialUpdate;

  @override
  State<Dial> createState() => _DialState();
}

class _DialState extends State<Dial> {
  @override
  Widget build(BuildContext context) {
    return (GestureDetector(
      onPanUpdate: _panHandler,
      child: Stack(alignment: Alignment.center, children: [
        Transform.rotate(
            angle: widget.rotationValue,
            child: Image(
              image: const AssetImage('assets/Dial.png'),
              width: widget.radius * 2,
              height: widget.radius * 2,
            )),
        Material(
          color: Colors.transparent,
          child: Ink(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: widget.onOff
                        ? const AssetImage('assets/orbit_start.png')
                        : const AssetImage('assets/orbit_stop.png'))),
            child: InkWell(
              onTap: widget.onTap,
              radius: widget.radius * 2,
              customBorder: const CircleBorder(),
            ),
          ),
        ),
      ]),
    ));
  }

  _panHandler(DragUpdateDetails d) {
    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= widget.radius;
    bool onLeftSide = d.localPosition.dx <= widget.radius;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Pan movements
    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    /// Absoulte change on axis
    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    /// Directional change on wheel
    double verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp)
        ? yChange
        : yChange * -1;

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

    // Total computed change
    double rotationalChange =
        (verticalRotation + horizontalRotation) * pi / 360;

    double currentRotation = widget.rotationValue + rotationalChange;

    currentRotation =
        currentRotation.clamp(-widget.maxRotation, widget.maxRotation);
    if (currentRotation.abs() == widget.maxRotation &&
        currentRotation.abs() != widget.rotationValue.abs()) {
      HapticFeedback.mediumImpact();
    } else if (currentRotation == 0 && widget.rotationValue != 0) {
      HapticFeedback.mediumImpact();
    }

    widget.onDialUpdate(widget.rotationValue);
  }
}
