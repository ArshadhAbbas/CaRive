import 'package:flutter/material.dart';
class HostHistory extends StatelessWidget {
  const HostHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(child: Text("History",style: TextStyle(color: Colors.white),)),
    );
  }
}