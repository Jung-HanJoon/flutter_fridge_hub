import 'package:flutter/material.dart';

class BorderText extends StatelessWidget {
  const BorderText(
      {Key key, this.text, this.size, this.borderColor, this.textColor})
      : super(key: key);
  final String text;
  final double size;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = borderColor,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(fontSize: size, color: textColor),
        ),
      ],
    );
  }
}
