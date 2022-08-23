import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'modeinformation.dart' as mode_info;

class MotorInterface extends ChangeNotifier {
  final IOWebSocketChannel _channel;
  final List<String> _commandQueue = [];

  bool connected = false;
  bool motorRunning = false;
  double batteryPercent = 0;
  double dialRotation = 0;
  double speed = 0.0;
  int position = 0;
  String currentMode = 'Product';

  MotorInterface(String url)
      : _channel = IOWebSocketChannel.connect(Uri.parse(url)) {
    if (_channel.innerWebSocket == null) {
      debugPrint('Websocket not found');
    } else {
      debugPrint('Connected');
      _channel.stream.listen((event) {
        receiveMessage(event);
      }, onError: (e) {
        debugPrint('error!');
      }, onDone: () {
        debugPrint('socket finished!');
      });
    }
  }

  startStop() {
    updateCommandQueue("{'action':'96'}");
    motorRunning = !motorRunning;
  }

  updateDialStatus(double rotation) {
    dialRotation = rotation;

    if (motorRunning) {
      if (dialRotation < 0 && !_commandQueue.contains("{'action':'98'}")) {
        updateCommandQueue("{'action':'98'}");
      } else if (dialRotation > 0 &&
          !_commandQueue.contains("{'action':'97'}")) {
        updateCommandQueue("{'action':'97}");
      }
    }

    double targetSpeed = dialRotation.abs() / (2.2 / 10);

    _commandQueue.asMap().forEach((index, command) {
      if (command.split(',')[0] == "{'action':'setSpeed'") {
        _commandQueue.removeAt(index);
      }
    });

    updateCommandQueue("{'action':'setSpeed','speed':'$targetSpeed'}");
  }

  receiveMessage(String event) {
    List data = event.split(',');
    batteryPercent = double.parse(data[0]);
    speed = double.parse(data[1]);
    currentMode = mode_info.modes[int.parse(data[2])];
    position = int.parse(data[3]);
    sendCommandFromQueue();
    notifyListeners();
  }

  updateCommandQueue(String command) {
    _commandQueue.add(command);
  }

  sendCommandFromQueue() {
    if (_commandQueue.isNotEmpty) {
      _channel.sink.add(_commandQueue.first);
      _commandQueue.removeAt(0);
    } else {
      _channel.sink.add("{'action':'status'");
    }
  }
}
