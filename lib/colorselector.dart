import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/modeinformation.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({Key? key, required this.updateCommandQueue})
      : super(key: key);
  final Function(String) updateCommandQueue;

  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (String command in colorRGBAInfo.keys)
          ColorButton(
              color: colorRGBAInfo[command]!,
              apiCommand: command,
              updateCommandQueue: updateCommandQueue)
      ],
    ));
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton(
      {Key? key,
      required this.color,
      required this.apiCommand,
      required this.updateCommandQueue})
      : super(key: key);
  final Color color;
  final String apiCommand;
  final Function(String) updateCommandQueue;

  @override
  Widget build(BuildContext context) {
    return (Material(
      color: Colors.transparent,
      child: Ink(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1.0)),
        child: InkWell(
          onTap: () {
            updateCommandQueue(apiCommand);
            HapticFeedback.lightImpact();
          },
          customBorder: const CircleBorder(),
        ),
      ),
    ));
  }
}
