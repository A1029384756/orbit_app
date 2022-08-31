library motor_mode_infomation;

import 'package:flutter/material.dart';

final Map<String, Map<String, double>> modeInformation = {
  'Product': {'modeScaler': 0.666, 'accel': 1000},
  'Interview': {'modeScaler': 0.0333, 'accel': 500},
  'Timelapse': {'modeScaler': 0.000444, 'accel': 250},
  'Stop-Motion': {'modeScaler': 0.6, 'accel': 250}
};

final Map<String, Color> colorRGBAInfo = {
  'noled': const Color.fromARGB(128, 128, 128, 128),
  'pink': Colors.pink,
  'red': Colors.red,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'white': Colors.white,
};

final List<int> stopMotionIncrements = [1, 5, 10, 15, 25];
