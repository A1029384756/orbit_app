import 'package:flutter/cupertino.dart';
import 'package:orbit_app/modeinformation.dart';
import 'package:provider/provider.dart';
import 'package:orbit_app/motorinterface.dart';

import 'package:orbit_app/ui_elements/dial.dart';
import 'package:orbit_app/ui_elements/readout.dart';
import 'package:orbit_app/ui_elements/colorselector.dart';

class StopmotionMode extends StatelessWidget {
  const StopmotionMode({Key? key}) : super(key: key);

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
                    mode: value.currentMode,
                    battery: value.batteryPercent,
                    rpm: value.speed),
              ),
              Consumer<MotorInterface>(
                builder: (context, value, child) => Dial(
                    radius: 150,
                    maxRotation: 2.2,
                    rotationValue: value.dialRotation,
                    arcOffset: 3,
                    numTicks: 5,
                    onOff: value.motorRunning,
                    visorColor: colorRGBAInfo[value.visorColor]!,
                    toggleDial: value.startStop,
                    onDialUpdate: value.updateSpeed),
              ),
              Consumer<MotorInterface>(
                  builder: (context, value, child) =>
                      ColorSelector(updateCommandQueue: value.changeLEDColor))
            ],
          ),
        ),
      ],
    ));
  }
}
