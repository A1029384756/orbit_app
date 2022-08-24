library motor_mode_infomation;

final List modes = ['Product', 'Interview', 'Timelapse', 'Stop-Motion'];

final Map<String, Map<String, double>> modeInformation = {
  'Product': {'modeScaler': 0.666},
  'Interview': {'modeScaler': 0.0333},
  'Timelapse': {'modeScaler': 0.000444},
  'Stopmotion': {'modeScaler': 0.6}
};

final List colors = ['noled', 'pink', 'red', 'orange', 'purple', 'white'];
