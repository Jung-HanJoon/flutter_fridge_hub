import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
        AutoSizeText(
          text,
          style: TextStyle(
            fontSize: size,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = borderColor,
          ),
          maxLines: 1,
        ),
        // Solid text as fill.
        AutoSizeText(
          text,
          style: TextStyle(fontSize: size, color: textColor),
          maxLines: 1,
        ),
      ],
    );
  }
}
