import 'dart:async';

import 'package:carive/screens/wrapper.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:carive/shared/logo.dart';
import 'package:flutter/material.dart';


class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Wrapper()),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const LogoWidget(150, 150),
              hSizedBox60,
              const Text(
                "CaRive",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
              // sizedBox20,
              const Text(
                "Discover the world on wheels with our car rental service",
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
