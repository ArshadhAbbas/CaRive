

import 'package:flutter/material.dart';

class RegisterScreenProvider extends ChangeNotifier {
  String error = '';

  // String get error => _error;

  void setError(String errorMessage) {
    error = errorMessage;
    notifyListeners();
  }
}
