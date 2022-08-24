import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'modeinformation.dart' as mode_info;

enum MotorDirection { cw, ccw }

class MotorInterface extends ChangeNotifier {
  final String _url;
  final List<String> _commandQueue = [];

  IOWebSocketChannel _channel;
  late Timer pingInterval;
  bool connected = false;
  bool motorRunning = false;

  bool p1 = false;
  bool p2 = false;

  double batteryPercent = 0;
  double dialRotation = 0;
  double speed = 0.0;
  int position = 0;
  String currentMode = 'Product';
  MotorDirection direction = MotorDirection.ccw;

  String visorColor = 'white';

  MotorInterface(String url)
      : _channel = IOWebSocketChannel.connect(url,
            pingInterval: const Duration(milliseconds: 1000)),
        _url = url {
    websocketReconnect();
  }

  websocketReconnect() async {
    _commandQueue.clear();
    await Future.delayed(const Duration(milliseconds: 1000));
    _channel = IOWebSocketChannel.connect(Uri.parse(_url));
    await Future.delayed(const Duration(milliseconds: 2000));
    if (_channel.innerWebSocket == null) {
      debugPrint('Websocket not found');
      websocketReconnect();
    } else {
      debugPrint('Connected');
      connected = true;
      _channel.stream.listen((event) {
        receiveMessage(event);
      }, onError: (e) {
        debugPrint('error!');
      }, onDone: () {
        debugPrint('socket finished!');
        _channel.sink.close();
        resetViewState();
        websocketReconnect();
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      updateCommandQueue("{'action':'setSpeed','speed':'0'}");
      pingInterval = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        sendCommandFromQueue();
      });
    }
  }

  startStop() {
    if (connected) {
      updateCommandQueue("{'action':'96'}");

      if (!motorRunning) {
        if (dialRotation < 0) {
          while (_commandQueue.contains("{'action':'97'}")) {
            _commandQueue.remove("{'action':'97'}");
          }
          direction = MotorDirection.ccw;
          updateCommandQueue("{'action':'98'}");
          updateCommandQueue("{'action':'98'}");
        } else if (dialRotation > 0) {
          while (_commandQueue.contains("{'action':'98'}")) {
            _commandQueue.remove("{'action':'98'}");
          }
          direction = MotorDirection.cw;
          updateCommandQueue("{'action':'97'}");
          updateCommandQueue("{'action':'97'}");
        }
      }
      notifyListeners();
    }
  }

  updateMotorDirection() {
    if (dialRotation < 0 && direction == MotorDirection.cw) {
      while (_commandQueue.contains("{'action':'97'}")) {
        _commandQueue.remove("{'action':'97'}");
      }
      direction = MotorDirection.ccw;
      updateCommandQueue("{'action':'98'}");
      updateCommandQueue("{'action':'98'}");
    } else if (dialRotation > 0 && direction == MotorDirection.ccw) {
      while (_commandQueue.contains("{'action':'98'}")) {
        _commandQueue.remove("{'action':'98'}");
      }
      direction = MotorDirection.cw;
      updateCommandQueue("{'action':'97'}");
      updateCommandQueue("{'action':'97'}");
    }
  }

  updateDialStatus(double rotation) {
    if (connected) {
      dialRotation = rotation;

      updateMotorDirection();

      double targetSpeed = dialRotation.abs() / (2.2 / 10);

      if (_commandQueue.isNotEmpty) {
        if (_commandQueue.last.contains("{'action':'setSpeed'")) {
          _commandQueue.removeLast();
        }
      }
      updateCommandQueue("{'action':'setSpeed','speed':'$targetSpeed'}");

      notifyListeners();
    }
  }

  changeLEDColor(String color) {
    updateCommandQueue("{'action':'$color'}");
    visorColor = color;
  }

  resetViewState() {
    connected = false;
    motorRunning = false;
    batteryPercent = 0;
    dialRotation = 0;
    speed = 0.0;
    position = 0;
    p1 = false;
    p2 = false;

    notifyListeners();
  }

  controlWiperMode(String wiperCommand) {
    debugPrint('wiper command sent');
    switch (wiperCommand) {
      case 'P1':
        p1 = true;
        wiperCommand = '21';
        break;
      case 'P2':
        p2 = true;
        wiperCommand = '22';
        break;
      case 'wipOnOff':
        p1 = p2 = false;
        break;
      default:
        break;
    }

    String formattedCommand = "{'action':'$wiperCommand'}";
    updateCommandQueue(formattedCommand);
  }

  changeMode(String mode) {
    if (connected) {
      int index = mode_info.modes.indexOf(mode) + 2;
      updateCommandQueue("{'action':'setMode','mode':'$index'}");
    }
  }

  receiveMessage(String event) {
    //debugPrint(event);
    List data = event.split(',');
    batteryPercent = double.parse(data[0]);
    speed = double.parse(data[1]);
    currentMode = mode_info.modes[int.parse(data[2]) - 2];
    position = int.parse(data[3]);
    motorRunning = int.parse(data[4]) == 0 ? false : true;
    notifyListeners();
  }

  updateCommandQueue(String command) {
    _commandQueue.add(command);
  }

  sendCommandFromQueue() {
    if (connected) {
      debugPrint(_commandQueue.toString());
      if (_commandQueue.isNotEmpty) {
        _channel.sink.add(_commandQueue.first);
        _commandQueue.removeAt(0);
      } else {
        _channel.sink.add("{'action':'app'}");
      }
    }
  }
}
