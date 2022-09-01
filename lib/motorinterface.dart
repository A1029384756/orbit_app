import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
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
  double speed = 0;
  double stopMotionIncrement = 0;
  int position = 0;
  MotorDirection direction = MotorDirection.ccw;

  String currentMode = modeInformation.keys.first;
  String visorColor = colorRGBAInfo.keys.last;

  MotorInterface(String url) : _url = url;

  connectToOrbit() async {
    if (connected == ConnectionStatus.connected) {
      _channel.sink.close();
      connected = ConnectionStatus.disconnected;
    } else if (connected == ConnectionStatus.connecting) {
      return;
    } else {
      connected = ConnectionStatus.connecting;
      notifyListeners();
      _commandQueue.clear();
      _channel = IOWebSocketChannel.connect(Uri.parse(_url),
          pingInterval: const Duration(milliseconds: 500));
      await Future.delayed(const Duration(milliseconds: 1000));

      if (_channel.innerWebSocket != null) {
        debugPrint('Connected');
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

        //Assign valid motor state on connection
        changeMode(currentMode);
        updateSpeed(0);
        changeLEDColor(visorColor);

        pingInterval =
            Timer.periodic(const Duration(milliseconds: 500), (timer) {
          sendCommandFromQueue();
        });
      } else {
        connectionFailed = true;
        connected = ConnectionStatus.disconnected;
      }
    }
    notifyListeners();
  }

  startStop() {
    updateCommandQueue("{'action':'96'}");

    if (!motorRunning && connected == ConnectionStatus.connected) {
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

  updateSpeed(double rotation) {
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
    notifyListeners();
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
    visorColor = colorRGBAInfo.keys.elementAt(5);

    notifyListeners();
  }

  controlWiperMode(String wiperCommand) {
    switch (wiperCommand) {
      case 'P1':
        p1 = connected == ConnectionStatus.connected;
        wiperCommand = '21';
        break;
      case 'P2':
        p2 = connected == ConnectionStatus.connected;
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
    notifyListeners();
  }

  toggleVFXBeep() {
    updateCommandQueue("{'action':'vfxOnOff'}");
  }

  changeMode(String mode) {
    int index = modeInformation.keys.toList().indexOf(mode) + 2;
    updateCommandQueue("{'action':'setMode','mode':'$index'}");
    updateCommandQueue(
        "{'action':'setAccel,'accel':'${modeInformation[currentMode]!['accel']}'");
    updateCommandQueue(
        "{'action':'setDecel,'decel':'${modeInformation[currentMode]!['accel']}'");
    currentMode = mode;

    notifyListeners();
  }

  receiveMessage(String event) {
    List data = event.split(',');
    batteryPercent = double.parse(data[0]);
    speed = double.parse(data[1]);
    currentMode = modeInformation.keys.elementAt(int.parse(data[2]) - 2);
    position = int.parse(data[3]);
    motorRunning = int.parse(data[4]) == 0 ? false : true;
    stopMotionIncrement = double.parse(data[7]);
    vfxBeep = int.parse(data[8]) == 0 ? false : true;
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
