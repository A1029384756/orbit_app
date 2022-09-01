import 'package:flutter/material.dart';

class Readout extends StatelessWidget {
  const Readout(
      {Key? key,
      required this.mode,
      required this.battery,
      required this.rpm,
      required this.increment})
      : super(key: key);
  final String mode;
  final double battery;
  final double rpm;
  final double increment;

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
      case 'Subject':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'RPM', element: rpm)
        ];
        break;
      case 'Timelapse':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          const MotorDisplayColumn(title: 'Rotations', element: 1),
          MotorDisplayColumn(title: 'Hours', element: (1 / rpm).roundToDouble())
        ];
        break;
      case 'Stop-Motion':
        displayedInformation = [
          MotorDisplayColumn(title: 'Battery', element: battery),
          MotorDisplayColumn(title: 'RPM', element: rpm),
          MotorDisplayColumn(title: 'Angle', element: increment!)
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
  final TextStyle titleStyle =
      const TextStyle(fontSize: 12, fontFamily: 'DSEG14Classic');
  final TextStyle infoStyle =
      const TextStyle(fontSize: 24, fontFamily: 'DSEG14Classic');
  final String title;
  final double element;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 128, 187, 181),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                title,
                style: titleStyle,
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(7),
          child: Text(
            element.toString(),
            style: infoStyle,
          ),
        )
      ],
    );
  }
}
