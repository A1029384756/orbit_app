import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orbit_app/modeinformation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:result_type/result_type.dart';

class Motor {
  IOWebSocketChannel? _channel;
  late Timer tickTimer;
  late Function onMessage;
  late Function onDisconnect;
  MotorState motorState = MotorState();

  Motor(String url, Function notifyOnMessageRecieved,
      Function notifyOnDisconnect) {
    onMessage = notifyOnMessageRecieved;
    onDisconnect = notifyOnDisconnect;
  }

  Future<Result<String, String>> connect(String url) async {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(url,
        pingInterval: const Duration(milliseconds: 500));
    await Future.delayed(const Duration(milliseconds: 1000));

    if (channel.innerWebSocket != null) {
      tickTimer = Timer.periodic(
          const Duration(milliseconds: 500), (timer) => sendMessage);
      channel.stream.listen((event) => recieveMessage, onDone: () {
        tickTimer.cancel();
        debugPrint('Disconnected');
        onDisconnect();
      });
      _channel = channel;
      return Success('Connected to Orbit!');
    } else {
      _channel = channel;
      return Failure('Could not connect to Orbit!');
    }
  }

  disconnect() {
    _channel!.sink.close();
    motorState = MotorState();
  }

  sendMessage() {
    _channel!.sink.add(jsonEncode(motorState.state));
  }

  recieveMessage(String event) {
    List data = event.split(',');
    motorState.updateState('battery', double.parse(data[0]));
    motorState.updateState('speed', double.parse(data[1]));
    motorState.updateState('mode', int.parse(data[2] - 2));
    motorState.updateState('position', int.parse(data[3]));
    motorState.updateState('running', int.parse(data[4]) == 0 ? false : true);
    motorState.updateState('vfxBeep', int.parse(data[7]) == 0 ? false : true);
    onMessage();
  }

  updateState(String property, dynamic value) {
    final channel = _channel;
    if (channel != null) {
      debugPrint(_channel?.innerWebSocket?.readyState.toString());
      if (_channel?.innerWebSocket?.readyState == 1) {
        motorState.updateState(property, value);
      } else {
        debugPrint('Not connected, not updating state');
      }
    }
  }
}

class MotorState {
  Map<String, dynamic> state;

  MotorState()
      : state = {
          'running': false,
          'p1': false,
          'p2': false,
          'vfxBeep': false,
          'directionClockwise': false,
          'battery': 0.0,
          'speed': 0.0,
          'position': 0,
          'mode': modeInformation.keys.toList().indexOf('Subject') + 2,
          'visorColor': colorRGBAInfo.keys.elementAt(5)
        };

  updateState(String property, dynamic value) {
    debugPrint('Updating $property with state $value');
    state[property] = value;
  }
}
