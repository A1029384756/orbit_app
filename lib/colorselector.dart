import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({Key? key, required this.updateCommandQueue})
      : super(key: key);
  final Function(String) updateCommandQueue;

  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ColorButton(
          color: Colors.transparent,
          apiCommand: 'noled',
          updateCommandQueue: updateCommandQueue,
        ),
        ColorButton(
          color: const Color.fromARGB(255, 231, 135, 167),
          apiCommand: 'pink',
          updateCommandQueue: updateCommandQueue,
        ),
        ColorButton(
          color: const Color.fromARGB(255, 184, 54, 54),
          apiCommand: 'red',
          updateCommandQueue: updateCommandQueue,
        ),
        ColorButton(
          color: const Color.fromARGB(255, 238, 129, 56),
          apiCommand: 'orange',
          updateCommandQueue: updateCommandQueue,
        ),
        ColorButton(
          color: const Color.fromARGB(255, 255, 255, 255),
          apiCommand: 'white',
          updateCommandQueue: updateCommandQueue,
        ),
        ColorButton(
          color: const Color.fromARGB(255, 195, 35, 243),
          apiCommand: 'purple',
          updateCommandQueue: updateCommandQueue,
        ),
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
          },
          customBorder: const CircleBorder(),
        ),
      ),
    ));
  }
}
