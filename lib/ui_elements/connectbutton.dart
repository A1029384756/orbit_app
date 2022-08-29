import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/motorinterface.dart';

class ConnectButton extends StatelessWidget {
  const ConnectButton(
      {Key? key, required this.connectToOrbit, required this.connectionStatus})
      : super(key: key);
  final VoidCallback connectToOrbit;
  final ConnectionStatus connectionStatus;

  @override
  Widget build(BuildContext context) {
    late Widget button;
    switch (connectionStatus) {
      case ConnectionStatus.disconnected:
        button = const Icon(CupertinoIcons.plus_circle);
        break;
      case ConnectionStatus.connecting:
        button = const CupertinoActivityIndicator();
        break;
      case ConnectionStatus.connected:
        button = const Icon(CupertinoIcons.check_mark_circled_solid);
        break;
      default:
    }

    return Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              connectToOrbit();
            },
            customBorder: const CircleBorder(),
            child: button,
          ),
        ));
  }
}
