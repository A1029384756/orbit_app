import 'package:flutter/material.dart';
import 'package:orbit_app/utils/motor.dart';
import 'package:result_type/result_type.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class MotorInterface extends ChangeNotifier {
  late String _url;
  late Motor motor;

  ConnectionStatus connection = ConnectionStatus.disconnected;
  bool connectionFailed = false;

  double dialRotation = 0.0;

  MotorInterface(String url) {
    motor = Motor(url, notifyOnMessageRecieved, notifyOnDisconnect);
    _url = url;
  }

  connect() async {
    switch (connection) {
      case ConnectionStatus.disconnected:
        connection = ConnectionStatus.connecting;
        notifyListeners();
        Result<String, String> motorResult = await motor.connect(_url);
        if (motorResult.isSuccess) {
          connection = ConnectionStatus.connected;
          debugPrint(motorResult.success);
        } else {
          connection = ConnectionStatus.disconnected;
          connectionFailed = true;
          debugPrint(motorResult.failure);
        }
        break;
      case ConnectionStatus.connecting:
        break;
      case ConnectionStatus.connected:
        connection = ConnectionStatus.disconnected;
        motor.disconnect();
        break;
      default:
        break;
    }

    notifyListeners();
  }

  updateDial(double newRotation) {
    dialRotation = newRotation;
    notifyListeners();
  }

  notifyOnMessageRecieved() {
    notifyListeners();
  }

  notifyOnDisconnect() {
    connection = ConnectionStatus.disconnected;
    notifyListeners();
  }

  updateState(String property, dynamic value) {
    if (connection == ConnectionStatus.connected) {
      motor.updateState(property, value);
    } else {
      debugPrint('Not updating state, not connected');
    }
  }
}
