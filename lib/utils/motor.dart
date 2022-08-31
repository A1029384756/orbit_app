import 'dart:async';
import 'dart:convert';

import 'package:orbit_app/modeinformation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:result_type/result_type.dart';

class Motor {
  late IOWebSocketChannel _channel;
  late Timer tickTimer;
  final MotorState motorState;

  Motor() : motorState = MotorState();

  Future<Result<String, String>> connect(String url) async {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(url);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (channel.innerWebSocket != null) {
      channel.stream
          .listen((event) => recieveMessage, onDone: tickTimer.cancel);
      tickTimer = Timer.periodic(
          const Duration(milliseconds: 500), (timer) => sendMessage);
      _channel = channel;
      return Success('Connected to Orbit!');
    } else {
      return Failure('Could not connect to Orbit!');
    }
  }

  sendMessage() {
    _channel.sink.add(jsonEncode(motorState.state));
  }

  recieveMessage(String event) {
    List data = event.split(',');
    motorState.updateState('battery', double.parse(data[0]));
    motorState.updateState('speed', double.parse(data[1]));
    motorState.updateState('mode', int.parse(data[2] - 2));
    motorState.updateState('position', int.parse(data[3]));
    motorState.updateState('running', int.parse(data[4]) == 0 ? false : true);
    motorState.updateState('vfxBeep', int.parse(data[7]) == 0 ? false : true);
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
          'battery': 0,
          'speed': 0,
          'position': 0,
          'mode': modeInformation.keys.toList().indexOf('Subject') + 2,
          'visorColor': colorRGBAInfo.keys.elementAt(5)
        };

  updateState(String property, dynamic value) {
    state[property] = value;
  }
}
