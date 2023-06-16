import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: const Scaffold(
        body: Center(
            child: Text(
          "Notification",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
