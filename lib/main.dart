import 'package:flutter/material.dart';
import 'package:orbit_app/motorinterface.dart';
import 'package:provider/provider.dart';

import 'dial.dart';
import 'readout.dart';
import 'bottombar.dart';
import 'wipercontrols.dart';
import 'colorselector.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MotorInterface('ws://192.168.4.1/ws'),
    child: const OrbitApp(),
  ));
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Orbit App';
    return const MaterialApp(
      title: title,
      home: Remote(
        title: title,
      ),
    );
  }
}

class Remote extends StatefulWidget {
  const Remote({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Remote> createState() => _RemoteState();
}

class _RemoteState extends State<Remote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover))),
          Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'MARBL ORBIT',
                      style: TextStyle(fontSize: 46, color: Colors.white70),
                    ),
                    Consumer<MotorInterface>(
                      builder: (context, motor, child) {
                        return Readout(
                          battery: motor.batteryPercent,
                          rpm: motor.speed,
                        );
                      },
                    ),
                    Consumer<MotorInterface>(
                      builder: (context, motor, child) {
                        return Dial(
                          radius: 150,
                          maxRotation: 2.2,
                          rotationValue: motor.dialRotation,
                          onOff: motor.motorRunning,
                          onTap: motor.startStop,
                          onDialUpdate: motor.updateDialStatus,
                        );
                      },
                    ),
                    WiperControls(updateCommandQueue: ((p0) {})),
                    ColorSelector(
                      updateCommandQueue: ((p0) {}),
                    )
                  ]))
        ],
      ),
      bottomNavigationBar: BottomBar(
        changeModes: ((p0) {}),
      ),
    );
  }
}
