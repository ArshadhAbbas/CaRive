import 'package:flutter/material.dart';

SizedBox hSizedBox60 = const SizedBox(height: 60);
SizedBox hSizedBox30 = const SizedBox(height: 30);
SizedBox hSizedBox20 = const SizedBox(height: 20);
SizedBox hSizedBox10 = const SizedBox(height: 10);

SizedBox wSizedBox20 = const SizedBox(width: 20);
SizedBox wSizedBox10 = const SizedBox(width: 10);

Color themeColorGreen = const Color(0xFF198396);
Color themeColorGrey = const Color(0xFF1E1E1E);
Color themeColorblueGrey = Colors.blueGrey;

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentfocus = FocusScope.of(context);
  if (!currentfocus.hasPrimaryFocus) {
    currentfocus.unfocus();
  }
}
