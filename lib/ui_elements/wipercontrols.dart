import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WiperControls extends StatelessWidget {
  const WiperControls(
      {Key? key,
      required this.updateCommandQueue,
      required this.p1,
      required this.p2})
      : super(key: key);
  final bool p1;
  final bool p2;
  final Function(String) updateCommandQueue;
  final TextStyle buttonFormatting =
      const TextStyle(fontSize: 24, color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        P1P2Button(
          displayText: Text(
            'P1',
            style: buttonFormatting,
          ),
          onPressed: updateCommandQueue,
          active: p1,
          command: 'P1',
        ),
        ClearButton(
          displayText: Text(
            'Clear',
            style: buttonFormatting,
          ),
          onPressed: updateCommandQueue,
          command: 'wipOnOff',
        ),
        P1P2Button(
          displayText: Text(
            'P2',
            style: buttonFormatting,
          ),
          onPressed: updateCommandQueue,
          active: p2,
          command: 'P2',
        ),
      ],
    ));
  }
}

class P1P2Button extends StatelessWidget {
  const P1P2Button(
      {Key? key,
      required this.displayText,
      required this.onPressed,
      required this.active,
      required this.command})
      : super(key: key);
  final Text displayText;
  final Function(String) onPressed;
  final bool active;
  final String command;

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
                onPressed(command);
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
      {Key? key,
      required this.displayText,
      required this.onPressed,
      required this.command})
      : super(key: key);
  final Text displayText;
  final Function(String) onPressed;
  final String command;

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
                onPressed(command);
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
