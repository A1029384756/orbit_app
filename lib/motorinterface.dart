import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'modeinformation.dart' as mode_info;
import 'modeinformation.dart';

enum MotorDirection { cw, ccw }

enum ConnectionStatus { disconnected, connecting, connected }

class MotorInterface extends ChangeNotifier {
  final String _url;
  final List<String> _commandQueue = [];

  late IOWebSocketChannel _channel;
  late Timer pingInterval;
  ConnectionStatus connected = ConnectionStatus.disconnected;
  bool connectionFailed = false;

  bool motorRunning = false;
  bool p1 = false;
  bool p2 = false;
  bool vfxBeep = false;

  double batteryPercent = 0;
  double dialRotation = 0;
  double speed = 0.0;
  int position = 0;
  String currentMode = 'Product';
  MotorDirection direction = MotorDirection.ccw;

  String visorColor = 'white';

  MotorInterface(String url) : _url = url;

  int maxConnectionAttempts = 5;
  int connectionAttempts = 0;

  connectToOrbit() async {
    if (connected == ConnectionStatus.connected) {
      _channel.sink.close();
    } else if (connectionAttempts < maxConnectionAttempts &&
        connected != ConnectionStatus.connecting) {
      connected = ConnectionStatus.connecting;
      notifyListeners();
      _commandQueue.clear();
      await Future.delayed(const Duration(milliseconds: 1000));
      _channel = IOWebSocketChannel.connect(Uri.parse(_url));
      await Future.delayed(const Duration(milliseconds: 2000));

      if (_channel.innerWebSocket == null) {
        connectionAttempts++;
        debugPrint('Websocket not found');
        connectToOrbit();
      } else {
        debugPrint('Connected');
        connectionAttempts = 0;
        connected = ConnectionStatus.connected;

        _channel.stream.listen((event) {
          receiveMessage(event);
        }, onError: (e) {
          debugPrint('error!');
        }, onDone: () {
          debugPrint('socket finished!');
          connected = ConnectionStatus.disconnected;
          pingInterval.cancel();
          resetViewState();
        });

        await Future.delayed(const Duration(milliseconds: 1000));
        updateCommandQueue(
            "{'action':'setMode','mode':'${mode_info.modes.indexOf(currentMode) + 2}'}");
        updateCommandQueue("{'action':'setSpeed','speed':'0'}");
        pingInterval =
            Timer.periodic(const Duration(milliseconds: 500), (timer) {
          sendCommandFromQueue();
        });

        connectionFailed = false;
      }
    } else {
      debugPrint('Max connection attempts exceeded');
      connectionAttempts = 0;
      connected = ConnectionStatus.disconnected;
      notifyListeners();
      connectionFailed = true;
    }
  }

  startStop() {
    if (connected == ConnectionStatus.connected) {
      updateCommandQueue("{'action':'96'}");

      if (!motorRunning) {
        if (dialRotation < 0) {
          _commandQueue.removeWhere((element) => element == "{'action':'97'}");
          direction = MotorDirection.ccw;
          updateCommandQueue("{'action':'98'}");
        } else if (dialRotation > 0) {
          _commandQueue.removeWhere((element) => element == "{'action':'98'}");
          direction = MotorDirection.cw;
          updateCommandQueue("{'action':'97'}");
        }
      }
    }
  }

  updateDialStatus(double rotation) {
    dialRotation = rotation;
    if (dialRotation < 0 && direction == MotorDirection.cw) {
      _commandQueue.removeWhere((element) => element == "{'action':'97'}");
      direction = MotorDirection.ccw;
      updateCommandQueue("{'action':'98'}");
    } else if (dialRotation > 0 && direction == MotorDirection.ccw) {
      _commandQueue.removeWhere((element) => element == "{'action':'98'}");
      direction = MotorDirection.cw;
      updateCommandQueue("{'action':'97'}");
    }

    double targetSpeed = dialRotation.abs() / (2.2 / 10);

    if (_commandQueue.isNotEmpty) {
      _commandQueue
          .removeWhere((element) => element.contains("{'action':'setSpeed'"));
    }
    updateCommandQueue("{'action':'setSpeed','speed':'$targetSpeed'}");

    notifyListeners();
  }

  changeLEDColor(String color) {
    updateCommandQueue("{'action':'$color'}");
    visorColor = color;
  }

  resetViewState() {
    connected = ConnectionStatus.disconnected;
    motorRunning = false;
    batteryPercent = 0;
    dialRotation = 0;
    speed = 0.0;
    position = 0;
    p1 = false;
    p2 = false;
    vfxBeep = false;
    visorColor = colors[5];

    notifyListeners();
  }

  controlWiperMode(String wiperCommand) {
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
        if (dialRotation < 0) {
          _commandQueue.removeWhere((element) => element == "{'action':'97'}");
          direction = MotorDirection.ccw;
          updateCommandQueue("{'action':'98'}");
        } else if (dialRotation > 0) {
          _commandQueue.removeWhere((element) => element == "{'action':'98'}");
          direction = MotorDirection.cw;
          updateCommandQueue("{'action':'97'}");
        }
        break;
      default:
        break;
    }

    String formattedCommand = "{'action':'$wiperCommand'}";
    updateCommandQueue(formattedCommand);
  }

  toggleVFXBeep() {
    updateCommandQueue("{'action':'vfxOnOff'}");
  }

  changeMode(String mode) {
    if (connected == ConnectionStatus.connected) {
      int index = mode_info.modes.indexOf(mode) + 2;
      updateCommandQueue("{'action':'setMode','mode':'$index'}");
    } else {
      currentMode = mode;
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
    vfxBeep = data[5].toString().toLowerCase() == 'true';
    notifyListeners();
  }

  updateCommandQueue(String command) {
    _commandQueue.add(command);
  }

  sendCommandFromQueue() {
    if (connected == ConnectionStatus.connected) {
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
