
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget(this.height,this.width,{super.key});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return  Transform.rotate(
    angle: -math.pi / 4,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: Colors.transparent, border: Border.all(color: Colors.white)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Transform.rotate(
            angle: math.pi / 4, child: Image.asset('assets/SteeringWheel.png')),
      ),
    ),
  );
  }
}