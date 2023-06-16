import 'package:flutter/material.dart';

class HostNotifications extends StatelessWidget {
  const HostNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(child: Text("Notifications",style: TextStyle(color: Colors.white),)),
    );
  }
}