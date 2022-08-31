import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/motorinterface.dart';
import 'package:provider/provider.dart';

class WiperControls extends StatelessWidget {
  const WiperControls({Key? key}) : super(key: key);
  final TextStyle buttonFormatting =
      const TextStyle(fontSize: 24, color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Consumer<MotorInterface>(
          builder: (context, value, child) => P1P2Button(
            displayText: Text(
              'P1',
              style: buttonFormatting,
            ),
            onPressed: () {
              value.updateState('p1', true);
            },
            active: value.motor.motorState.state['p1'],
          ),
        ),
        Consumer<MotorInterface>(
            builder: (context, value, child) => ClearButton(
                displayText: Text('Clear', style: buttonFormatting),
                onPressed: () {
                  value.updateState('p1', false);
                  value.updateState('p2', false);
                })),
        Consumer<MotorInterface>(
          builder: (context, value, child) => P1P2Button(
            displayText: Text(
              'P2',
              style: buttonFormatting,
            ),
            onPressed: () {
              value.updateState('p2', true);
            },
            active: value.motor.motorState.state['p2'],
          ),
        ),
      ],
    ));
  }
}

class P1P2Button extends StatelessWidget {
  const P1P2Button({
    Key? key,
    required this.displayText,
    required this.onPressed,
    required this.active,
  }) : super(key: key);
  final Text displayText;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return (Material(
        color: Colors.transparent,
        child: Ink(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 68, 68, 68),
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2,
                    color: Color.fromARGB(active ? 255 : 0, 182, 241, 178))),
            child: InkWell(
              onTap: () {
                onPressed();
                HapticFeedback.lightImpact();
              },
              customBorder: const CircleBorder(),
              child: Center(
                child: displayText,
              ),
            ))));
  }
}

class ClearButton extends StatelessWidget {
  const ClearButton(
      {Key? key, required this.displayText, required this.onPressed})
      : super(key: key);
  final Text displayText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return (Material(
        color: Colors.transparent,
        child: Ink(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 68, 68, 68),
                borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () {
                onPressed();
                HapticFeedback.lightImpact();
              },
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: displayText,
              ),
            ))));
  }
}
