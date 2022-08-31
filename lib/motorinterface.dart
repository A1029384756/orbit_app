import 'package:flutter/material.dart';
import 'package:orbit_app/utils/motor.dart';
import 'package:result_type/result_type.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class MotorInterface extends ChangeNotifier {
  final String _url;
  final Motor motor;

  ConnectionStatus connection = ConnectionStatus.disconnected;
  bool connectionFailed = false;

  double dialRotation = 0.0;

  MotorInterface(String url)
      : _url = url,
        motor = Motor(url);

  connect() async {
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

    notifyListeners();
  }

  updateDial(double newRotation) {
    dialRotation = newRotation;
    notifyListeners();
  }
}
