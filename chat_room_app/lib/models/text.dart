import 'package:flutter/material.dart';

Text text(
  String txt, {
  Color? clr,
  double? fontsize,
  FontWeight? fontWeight,
}) {
  return Text(
    txt,
    style: TextStyle(
      color: clr ?? Colors.black,
      fontSize: fontsize ?? 15,
      fontWeight: fontWeight ?? FontWeight.normal,
    ),
  );
}
