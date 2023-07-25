

import 'package:flutter/material.dart';

class RegisterScreenProvider extends ChangeNotifier {
  String error = '';

  void setError(String errorMessage) {
    error = errorMessage;
    notifyListeners();
  }
}
