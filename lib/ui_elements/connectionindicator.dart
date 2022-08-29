import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({Key? key, required this.connected})
      : super(key: key);
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(right: 100),
      decoration: BoxDecoration(
          color: connected ? Colors.green : Colors.red, shape: BoxShape.circle),
      width: 10,
      height: 10,
    );
  }
}
