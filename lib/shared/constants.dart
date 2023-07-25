import 'package:carive/shared/custom_elevated_button.dart';
import 'package:flutter/material.dart';

SizedBox hSizedBox60 = const SizedBox(height: 60);
SizedBox hSizedBox30 = const SizedBox(height: 30);
SizedBox hSizedBox20 = const SizedBox(height: 20);
SizedBox hSizedBox10 = const SizedBox(height: 10);

SizedBox wSizedBox20 = const SizedBox(width: 20);
SizedBox wSizedBox10 = const SizedBox(width: 10);

Color themeColorGreen = const Color(0xFF198396);
Color themeColorGrey = const Color(0xFF1E1E1E);
Color themeColorblueGrey = Colors.blueGrey;

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentfocus = FocusScope.of(context);
  if (!currentfocus.hasPrimaryFocus) {
    currentfocus.unfocus();
  }
}


 void showCreateProfileDialogue(BuildContext context ,String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeColorGrey,
          title: const Text(
            'Create Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            CustomElevatedButton(
              text: "OK",
              paddingHorizontal: 3,
              paddingVertical: 3,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }