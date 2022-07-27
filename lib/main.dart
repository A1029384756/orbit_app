import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dial.dart';
import 'readout.dart';
import 'bottombar.dart';
import 'wipercontrols.dart';
import 'colorselector.dart';

void main() {
  runApp(const OrbitApp());
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
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://192.168.4.1/ws'));
  final List _modes = ['Product', 'Interview', 'Timelapse', 'Stop-Motion'];
  final List<String> _commandQueue = [];
  late Timer commandTick;

  double _speed = 0;
  double _batteryPercent = 0;
  String _currentMode = 'Product';
  bool _resetMotor = false;

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((event) {
      _decodeStream(event);
    });
    commandTick = Timer.periodic(const Duration(milliseconds: 400), (Timer t) {
      _processCommandQueue();
    });

    //_updateCommandQueue('13');
  }

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
                    Readout(
                      battery: _batteryPercent,
                      rpm: _speed,
                    ),
                    Dial(
                      updateCommandQueue: _updateCommandQueue,
                      resetMotor: () {
                        setState(() {
                          _resetMotor = false;
                        });
                      },
                      resetMotorBool: _resetMotor,
                    ),
                    WiperControls(
                      updateCommandQueue: _updateCommandQueue,
                    ),
                    ColorSelector(
                      updateCommandQueue: _updateCommandQueue,
                    )
                  ]))
        ],
      ),
      bottomNavigationBar: BottomBar(
        changeModes: _changeModes,
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  _decodeStream(String event) {
    List data = event.split(',');
    setState(() {
      _batteryPercent = double.parse(data[0]);
      _speed = double.parse(data[1]);
      _currentMode = _modes[int.parse(data[2]) - 2];
    });
  }

  _changeModes(String clickedMode) {
    int currentModeIndex = _modes.indexOf(_currentMode);
    int newModeIndex = _modes.indexOf(clickedMode);

    if (newModeIndex < currentModeIndex) {
      currentModeIndex -= _modes.length;
    }

    int numSteps = newModeIndex - currentModeIndex;

    for (var i = 0; i < numSteps; i++) {
      _updateCommandQueue('20');
    }
  }

  _updateCommandQueue(String action) {
    _commandQueue.add(action);
  }

  _processCommandQueue() {
    if (_commandQueue.isNotEmpty) {
      String instruction = _commandQueue.first;
      _channel.sink.add("{'action':'$instruction'}");
      _commandQueue.removeAt(0);

      if (instruction == 'wipOnOff') {
        setState(() {
          _resetMotor = true;
        });
      }
    }
  }
}
