import 'package:carive/services/auth.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

import '../../../shared/custom_elevated_button.dart';

// ignore: must_be_immutable
class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child:  Scaffold(
        body: Center(
            child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(const Color(0xFF198396)),
          ),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  contentTextStyle: const TextStyle(color: Colors.white),
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Sign Out ?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomElevatedButton(
                      text: "Ok",
                      onPressed: () {
                        auth.signout();
                        Navigator.of(context).pop();
                      },
                      paddingHorizontal: 8,
                      paddingVertical: 8,
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Sign Out'),
        )),
      ),
    );
  }
}
