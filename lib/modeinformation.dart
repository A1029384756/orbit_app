library motor_mode_infomation;

import 'dart:ui';

final Map<String, Map<String, double>> modeInformation = {
  'Product': {'modeScaler': 0.666, 'accel': 1000},
  'Interview': {'modeScaler': 0.0333, 'accel': 500},
  'Timelapse': {'modeScaler': 0.000444, 'accel': 250},
  'Stop-Motion': {'modeScaler': 0.6, 'accel': 250}
};

final Map<String, Color> colorRGBAInfo = {
  'noled': const Color.fromARGB(128, 128, 128, 128),
  'pink': const Color.fromARGB(255, 231, 135, 167),
  'red': const Color.fromARGB(255, 184, 54, 54),
  'orange': const Color.fromARGB(255, 238, 129, 56),
  'purple': const Color.fromARGB(255, 195, 35, 243),
  'white': const Color.fromARGB(255, 255, 255, 255),
};

final List<int> stopMotionIncrements = [1, 5, 10, 15, 25];
