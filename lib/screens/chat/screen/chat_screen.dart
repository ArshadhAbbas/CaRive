import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: const Scaffold(
        body: Center(
            child: Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
