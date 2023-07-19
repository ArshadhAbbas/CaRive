import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton(
      {required this.text,
      required this.onPressed,
      this.paddingHorizontal = 30,
      this.paddingVertical = 20,
      super.key});

  final String text;
  final VoidCallback? onPressed;
  final double paddingHorizontal;
  final double paddingVertical;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(const Color(0xFF198396)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        child: Text(text),
      ),
    );
  }
}
