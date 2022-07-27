import 'package:flutter/material.dart';

class WiperControls extends StatefulWidget {
  const WiperControls({Key? key, required this.updateCommandQueue})
      : super(key: key);
  final Function(String) updateCommandQueue;

  @override
  State<WiperControls> createState() => _WiperControlsState();
}

class _WiperControlsState extends State<WiperControls> {
  final TextStyle buttonFormatting =
      const TextStyle(fontSize: 24, color: Colors.white70);
  bool p1 = false;
  bool p2 = false;

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
          onPressed: _pressP1,
          active: p1,
        ),
        ClearButton(
          displayText: Text(
            'Clear',
            style: buttonFormatting,
          ),
          onPressed: _pressClear,
        ),
        P1P2Button(
          displayText: Text(
            'P2',
            style: buttonFormatting,
          ),
          onPressed: _pressP2,
          active: p2,
        ),
      ],
    ));
  }

  _pressP1() {
    widget.updateCommandQueue('21');
    setState(() {
      p1 = true;
    });
  }

  _pressP2() {
    widget.updateCommandQueue('22');
    setState(() {
      p2 = true;
    });
  }

  _pressClear() {
    widget.updateCommandQueue('wipOnOff');
    setState(() {
      p1 = p2 = false;
    });
  }
}

class P1P2Button extends StatelessWidget {
  const P1P2Button(
      {Key? key,
      required this.displayText,
      required this.onPressed,
      required this.active})
      : super(key: key);
  final Text displayText;
  final Function() onPressed;
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
              onTap: onPressed,
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
  final Function() onPressed;

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
              onTap: onPressed,
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: displayText,
              ),
            ))));
  }
}
