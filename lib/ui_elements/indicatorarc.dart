import 'dart:math';
import 'package:flutter/material.dart';

class MeasurementArc extends CustomPainter {
  MeasurementArc(
      {required this.lineCount,
      required this.radius,
      required this.tickLength,
      required this.arcColor});
  final int lineCount;
  final int radius;
  final int tickLength;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    //draw arc
    canvas.drawArc(
        Offset(-radius.toDouble(), -radius.toDouble()) &
            Size(radius * 2, radius * 2),
        2.5, //radians
        4.39, //radians
        false,
        paint1);

    for (var i = 0; i < lineCount; i++) {
      double startPoint = 0.96;
      double interval = 4.4 / (lineCount - 1);
      double startX, startY, endX, endY = 0;

      startX = (radius - tickLength / 2) * sin(startPoint + interval * i);
      startY = (radius - tickLength / 2) * cos(startPoint + interval * i);
      endX = (radius + tickLength / 2) * sin(startPoint + interval * i);
      endY = (radius + tickLength / 2) * cos(startPoint + interval * i);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
