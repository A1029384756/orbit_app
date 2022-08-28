import 'package:flutter/material.dart';

class Readout extends StatelessWidget {
  const Readout({Key? key, required this.battery, required this.rpm})
      : super(key: key);
  final double battery;
  final double rpm;

  @override
  Widget build(BuildContext context) {
    return (Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 159, 231, 224),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(children: [
                    const Text(
                      'RPM',
                      style: TextStyle(fontFamily: 'DSEG14Classic'),
                    ),
                    TextContainer(text: rpm.toString()),
                  ]),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(
                    children: [
                      const Text(
                        'Battery (%)',
                        style: TextStyle(fontFamily: 'DSEG14Classic'),
                      ),
                      TextContainer(text: battery.toString()),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class TextContainer extends StatelessWidget {
  const TextContainer({Key? key, required this.text}) : super(key: key);
  final String text;
  final TextStyle style =
      const TextStyle(fontSize: 24, fontFamily: 'DSEG14Classic');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
