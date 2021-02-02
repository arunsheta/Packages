import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String txtTitle;
  final TextStyle style;
  final TextAlign align;
  final int maxLine;
  final TextOverflow textOverflow;

  CustomText({
    this.txtTitle,
    this.style,
    this.align = TextAlign.start,
    this.maxLine,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txtTitle,
      style: style,
      softWrap: true,
      textAlign: align,
      maxLines: maxLine,
      overflow: textOverflow,
    );
  }
}
