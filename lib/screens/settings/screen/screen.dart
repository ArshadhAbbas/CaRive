import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: const Scaffold(
        body: Center(
            child: Text(
          "settings",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
