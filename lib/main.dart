import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbit_app/modeinformation.dart';
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
      home: Remote(),
    );
  }
}

class Remote extends StatelessWidget {
  const Remote({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<TabInfo> tabInfo = [
      TabInfo('Product', CupertinoIcons.cube_box,
          modeInformation['Product']!['modeScaler']!),
      TabInfo('Interview', CupertinoIcons.person,
          modeInformation['Interview']!['modeScaler']!),
      TabInfo('Timelapse', CupertinoIcons.time,
          modeInformation['Timelapse']!['modeScaler']!),
      TabInfo('Stopmotion', CupertinoIcons.timer,
          modeInformation['Stopmotion']!['modeScaler']!),
    ];

    return DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              for (final tabInfo in tabInfo)
                BottomNavigationBarItem(
                    icon: Icon(tabInfo.icon), label: tabInfo.title)
            ],
            onTap: (value) {
              Provider.of<MotorInterface>(context, listen: false)
                  .changeMode(modes[value]);
              debugPrint(modes[value]);
            },
          ),
          tabBuilder: ((context, index) {
            return CupertinoTabView(
              restorationScopeId: 'cupertino_tab_view_$index',
              builder: (context) => const ModeScreen(),
            );
          }),
        ));
  }
}

class ModeScreen extends StatelessWidget {
  const ModeScreen({Key? key}) : super(key: key);

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
              const EdgeInsets.only(left: 30, top: 30, right: 30, bottom: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('MARBL ORBIT'),
              Consumer<MotorInterface>(
                builder: (context, value, child) =>
                    Readout(battery: value.batteryPercent, rpm: value.speed),
              ),
              Consumer<MotorInterface>(
                builder: (context, value, child) => Dial(
                    radius: 150,
                    maxRotation: 2.2,
                    rotationValue: value.dialRotation,
                    onOff: value.motorRunning,
                    onTap: value.startStop,
                    onDialUpdate: value.updateDialStatus),
              ),
              Consumer<MotorInterface>(
                  builder: (context, value, child) => WiperControls(
                        updateCommandQueue: value.controlWiperMode,
                        p1: value.p1,
                        p2: value.p2,
                      )),
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
