import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key, required this.changeModes}) : super(key: key);
  final Function(String) changeModes;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return (Material(
        color: const Color.fromARGB(255, 56, 56, 56),
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomButton(
                  text: 'Product',
                  onPress: widget.changeModes,
                ),
                BottomButton(
                  text: 'Interview',
                  onPress: widget.changeModes,
                ),
                BottomButton(
                  text: 'Timelapse',
                  onPress: widget.changeModes,
                ),
                BottomButton(
                  text: 'Stop-Motion',
                  onPress: widget.changeModes,
                )
              ],
            ))));
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton({Key? key, required this.text, required this.onPress})
      : super(key: key);
  final String text;
  final Function(String) onPress;
  final TextStyle style = const TextStyle(color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Ink(
            child: InkWell(
          onTap: () {
            onPress(text);
          },
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                text,
                style: style,
              )),
        )));
  }
}
