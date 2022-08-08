import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

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
  final List _modes = ['Product', 'Interview', 'Timelapse', 'Stop-Motion'];
  final List<dynamic> _commandQueue = [];
  final int _queueTickTime = 400;
  late Timer commandTick;
  late IOWebSocketChannel _channel;
  double _speed = 0;
  double _batteryPercent = 0;
  String _currentMode = 'Product';

  @override
  void initState() {
    super.initState();
    _connect();
    commandTick =
        Timer.periodic(Duration(milliseconds: _queueTickTime), (Timer t) {
      _processCommandQueue();
    });
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

  _connect() {
    setState(() {
      _channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.4.1/ws'));
      debugPrint('connected!');
      debugPrint(_channel.innerWebSocket.toString());
    });
    _channel.stream.listen((event) {
      _decodeStream(event);
    }, onError: (e) {
      debugPrint('error!');
      _reconnect();
    }, onDone: () {
      debugPrint('disconnected!');
      _reconnect();
    });
  }

  _reconnect() async {
    setState(() {
      _channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.4.1/ws'));
    });
    await Future.delayed(const Duration(milliseconds: 2000));

    if (_channel.innerWebSocket == null) {
      debugPrint('reconnecting...');
      _reconnect();
    }
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
    if (action.contains(',')) {
      action = "{'action':'$action}";
    } else {
      action = "{'action':'$action'}";
    }
    _commandQueue.add(action);
  }

  _processCommandQueue() {
    if (_commandQueue.isNotEmpty && _channel.innerWebSocket != null) {
      String instruction = _commandQueue.first;
      debugPrint(instruction);
      _channel.sink.add(instruction);
      _commandQueue.removeAt(0);
    } else if (_channel.innerWebSocket == null) {
      _reconnect();
    }
  }
}
