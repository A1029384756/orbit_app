import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class Dial extends StatefulWidget {
  const Dial(
      {Key? key,
      required this.updateCommandQueue,
      required this.resetMotor,
      required this.resetMotorBool})
      : super(key: key);
  final Function(String) updateCommandQueue;
  final VoidCallback resetMotor;
  final bool resetMotorBool;

  @override
  State<Dial> createState() => _DialState();
}

class _DialState extends State<Dial> {
  final int radius = 150;
  final double maxRotation = 2.2;
  final int sampleCount = 60;
  late Timer speedTimer;
  int _currentSpeed = 0;
  int _targetSpeed = 0;
  double _currentRotation = 0;
  bool _motorRunning = false;
  bool _dialUpdated = false;

  @override
  void initState() {
    super.initState();
    speedTimer = Timer.periodic(const Duration(milliseconds: 750), (Timer t) {
      _updateSpeed();
      _updateDirection();
      _resetDial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (GestureDetector(
      onPanUpdate: _panHandler,
      child: Stack(alignment: Alignment.center, children: [
        Transform.rotate(
            angle: _currentRotation,
            child: Image(
              image: const AssetImage('assets/Dial.png'),
              width: radius * 2,
              height: radius * 2,
            )),
        Material(
          color: Colors.transparent,
          child: Ink(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
                //color: _motorRunning ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: _motorRunning
                        ? const AssetImage('assets/orbit_start.png')
                        : const AssetImage('assets/orbit_stop.png'))),
            child: InkWell(
              onTap: _startStop,
              radius: radius * 2,
              customBorder: const CircleBorder(),
            ),
          ),
        ),
      ]),
    ));
  }

  @override
  void dispose() {
    speedTimer.cancel();
    super.dispose();
  }

  _panHandler(DragUpdateDetails d) {
    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= radius;
    bool onLeftSide = d.localPosition.dx <= radius;
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

    setState(() {
      double currentRotation = _currentRotation + rotationalChange;

      currentRotation = currentRotation.clamp(-maxRotation, maxRotation);
      if (currentRotation.abs() == maxRotation) {
        HapticFeedback.mediumImpact();
      }

      _currentRotation = currentRotation;
      _dialUpdated = true;
      _targetSpeed = _currentRotation.abs() ~/ (maxRotation / 15);
    });
  }

  _startStop() {
    HapticFeedback.lightImpact();
    widget.updateCommandQueue('96');
    setState(() {
      _motorRunning = !_motorRunning;
    });
  }

  _updateSpeed() {
    if (_motorRunning && (_currentSpeed != _targetSpeed || _dialUpdated)) {
      // Handle motor speed
      if (_currentSpeed > _targetSpeed) {
        widget.updateCommandQueue('13');
        setState(() {
          _currentSpeed -= 1;
        });
      } else if (_currentSpeed < _targetSpeed) {
        widget.updateCommandQueue('12');
        setState(() {
          _currentSpeed += 1;
        });
      }
    }
  }

  _updateDirection() {
    if (_dialUpdated && _motorRunning) {
      if (_currentRotation < 0) {
        widget.updateCommandQueue('98');
      } else if (_currentRotation > 0) {
        widget.updateCommandQueue('97');
      }

      setState(() {
        _dialUpdated = false;
      });
    }
  }

  _resetDial() {
    if (widget.resetMotorBool) {
      setState(() {
        _currentRotation = 0;
        _currentSpeed = 0;
        _targetSpeed = 0;
      });

      widget.resetMotor();
    }
  }
}
