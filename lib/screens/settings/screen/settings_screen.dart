// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:carive/screens/settings/wishlist/wishlist_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';

import '../../../services/user_database_service.dart';
import '../../../shared/custom_elevated_button.dart';
import '../my_order_history/my_order_history.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  AuthService auth = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserDatabaseService userDatabaseService = UserDatabaseService();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 8, right: 8),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: "My wishlist",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const WishListScreen(),
                      ));
                    },
                    paddingHorizontal: 10,
                    paddingVertical: 15,
                  ),
                ),
                hSizedBox30,
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: "My Orders",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyOrdersHistory(),
                      ));
                    },
                    paddingHorizontal: 10,
                    paddingVertical: 15,
                  ),
                ),
                hSizedBox30,
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: "Delete my profile",
                    onPressed: () async {
                      bulidDeleteAccountDialogue(context);
                    },
                    paddingHorizontal: 10,
                    paddingVertical: 15,
                  ),
                ),
                hSizedBox30,
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: "Sign Out",
                    onPressed: () {
                      buildSignOutDialogue(context);
                    },
                    paddingHorizontal: 10,
                    paddingVertical: 15,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildSignOutDialogue(BuildContext context) {
    return showDialog(
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
              onPressed: () async {
                await auth.signout();
                Navigator.of(context).pop();
              },
              paddingHorizontal: 8,
              paddingVertical: 8,
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> bulidDeleteAccountDialogue(BuildContext context) {
    return showDialog(
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
          title: const Text('Delete !?'),
          content: const Text(
              'All your posts will be deleted.This action cannot be undone'),
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
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CustomProgressIndicator(),
                  ),
                );
                await userDatabaseService.deleteUser(
                    _auth.currentUser!.uid, _auth.currentUser);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              paddingHorizontal: 8,
              paddingVertical: 8,
            ),
          ],
        );
      },
    );
  }
}
