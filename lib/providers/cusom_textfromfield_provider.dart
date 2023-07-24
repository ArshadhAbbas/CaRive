import 'package:flutter/material.dart';

class CustomTextFormFieldProvider extends ChangeNotifier {
  bool obscureText = false;

  void toggleObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }
}
