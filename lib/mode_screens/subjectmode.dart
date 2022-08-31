import 'package:flutter/cupertino.dart';
import 'package:orbit_app/modeinformation.dart';
import 'package:provider/provider.dart';
import 'package:orbit_app/motorinterface.dart';

import 'package:orbit_app/ui_elements/dial.dart';
import 'package:orbit_app/ui_elements/readout.dart';
import 'package:orbit_app/ui_elements/wipercontrols.dart';
import 'package:orbit_app/ui_elements/colorselector.dart';

class SubjectMode extends StatelessWidget {
  const SubjectMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover)),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 30, top: 80, right: 30, bottom: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Consumer<MotorInterface>(
                builder: (context, value, child) => Readout(
                    mode: modeInformation.keys
                        .elementAt(value.motor.motorState.state['mode'] - 2),
                    battery: value.motor.motorState.state['battery'],
                    rpm: value.motor.motorState.state['speed']),
              ),
              Consumer<MotorInterface>(
                builder: (context, value, child) => Dial(
                    radius: 150,
                    maxRotation: 2.2,
                    rotationValue: value.dialRotation,
                    arcOffset: 3,
                    numTicks: 9,
                    onOff: value.motor.motorState.state['running'],
                    toggleDial: () {
                      value.updateState(
                          'running', !value.motor.motorState.state['running']);
                    },
                    onDialUpdate: value.updateDial),
              ),
              const WiperControls(),
              ColorSelector(updateCommandQueue: (selectedColor) {
                Provider.of<MotorInterface>(context, listen: false)
                    .updateState('visorColor', selectedColor);
              })
            ],
          ),
        ),
      ],
    ));
  }
}
