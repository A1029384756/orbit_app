import 'package:flutter/material.dart';

class Readout extends StatefulWidget {
  const Readout({Key? key, required this.battery, required this.rpm})
      : super(key: key);
  final double battery;
  final double rpm;

  @override
  State<Readout> createState() => _ReadoutState();
}

class _ReadoutState extends State<Readout> {
  bool _rpmUnits = true;

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
                Column(children: [
                  ToggleButton(
                    displayText: _rpmUnits ? 'RPM' : 'MPR',
                    toggleDisplay: _toggleRPMMode,
                  ),
                  TextContainer(
                      text: _rpmUnits
                          ? widget.rpm.toString()
                          : (1 / widget.rpm).toStringAsFixed(4)),
                ]),
                Column(
                  children: [
                    const Text(
                      'Battery (%)',
                      style:
                          TextStyle(fontFamily: 'DSEG14Classic', fontSize: 14),
                    ),
                    TextContainer(text: widget.battery.toString()),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  _toggleRPMMode() {
    setState(() {
      _rpmUnits = !_rpmUnits;
    });
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

class ToggleButton extends StatelessWidget {
  const ToggleButton(
      {Key? key, required this.displayText, required this.toggleDisplay})
      : super(key: key);
  final String displayText;
  final Function() toggleDisplay;

  @override
  Widget build(BuildContext context) {
    return (Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 123, 180, 174),
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: toggleDisplay,
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Center(
                child: Text(
              displayText,
              style: const TextStyle(fontFamily: 'DSEG14Classic'),
            )),
          ),
        ),
      ),
    ));
  }
}
