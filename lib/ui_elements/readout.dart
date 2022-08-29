import 'package:flutter/material.dart';

class Readout extends StatelessWidget {
  const Readout(
      {Key? key, required this.mode, required this.battery, required this.rpm})
      : super(key: key);
  final String mode;
  final double battery;
  final double rpm;

  @override
  Widget build(BuildContext context) {
    List<MotorDisplayColumn> displayedInformation = [];

    switch (mode) {
      case 'Product':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'RPM', element: rpm)
        ];
        break;
      case 'Interview':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'RPM', element: rpm)
        ];
        break;
      case 'Timelapse':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'HPR', element: rpm)
        ];
        break;
      case 'Stop-Motion':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'RPM', element: rpm),
          MotorDisplayColumn(title: 'Rotation Angle', element: rpm)
        ];
        break;
      default:
        break;
    }

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
                for (MotorDisplayColumn column in displayedInformation) column
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

class MotorDisplayColumn extends StatelessWidget {
  const MotorDisplayColumn(
      {Key? key, required this.title, required this.element})
      : super(key: key);
  final TextStyle style =
      const TextStyle(fontSize: 24, fontFamily: 'DSEG14Classic');
  final String title;
  final double element;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: style,
        ),
        Text(
          element.toString(),
          style: style,
        )
      ],
    );
  }
}
