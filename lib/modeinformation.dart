library motor_mode_infomation;

import 'dart:ui';

final List modes = ['Product', 'Interview', 'Timelapse', 'Stop-Motion'];

final Map<String, Map<String, double>> modeInformation = {
  'Product': {'modeScaler': 0.666},
  'Interview': {'modeScaler': 0.0333},
  'Timelapse': {'modeScaler': 0.000444},
  'Stopmotion': {'modeScaler': 0.6}
};

final List colors = ['noled', 'pink', 'red', 'orange', 'purple', 'white'];

final Map<String, Color> colorRGBAInfo = {
  'noled': const Color.fromARGB(128, 128, 128, 128),
  'pink': const Color.fromARGB(255, 231, 135, 167),
  'red': const Color.fromARGB(255, 184, 54, 54),
  'orange': const Color.fromARGB(255, 238, 129, 56),
  'white': const Color.fromARGB(255, 255, 255, 255),
  'purple': const Color.fromARGB(255, 195, 35, 243),
};
