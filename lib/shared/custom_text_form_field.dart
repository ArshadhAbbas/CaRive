import 'package:carive/shared/constants.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  bool obscureText;
  final bool isEye;
  final FormFieldValidator<String>? validator;

  CustomTextFormField({
    Key? key,
    this.hintText,
    this.labelText,
    required this.controller,
    this.obscureText = false,
    this.isEye = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      style: const TextStyle(color: Colors.white),
      obscureText: widget.obscureText,
      enableSuggestions: !widget.obscureText,
      autocorrect: !widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        suffixIcon: widget.isEye
            ? GestureDetector(
                child: Icon(Icons.remove_red_eye_outlined,
                    color: themeColorGreen),
                onTap: () {
                  setState(() {
                    widget.obscureText = !widget.obscureText;
                  });
                },
              )
            : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: themeColorblueGrey),
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 53, 72, 83)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: themeColorGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: themeColorGreen),
        ),
      ),
    );
  }
}
