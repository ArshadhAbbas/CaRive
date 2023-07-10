import 'package:carive/screens/settings/wishlist/wishlsit_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

import '../../../shared/custom_elevated_button.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  AuthService auth = AuthService();

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
                        builder: (context) => WishListScreen(),
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
                    text: "Sign Out",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titleTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            contentTextStyle:
                                const TextStyle(color: Colors.white),
                            backgroundColor: const Color(0xFF1E1E1E),
                            title: const Text('Sign Out ?'),
                            content: const Text(
                                'Are you sure you want to sign out?'),
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
                    },
                    paddingHorizontal: 10,
                    paddingVertical: 15,
                  ),
                )
                // ElevatedButton(
                //   style: ButtonStyle(
                //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //       RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //     ),
                //     backgroundColor:
                //         MaterialStateProperty.all(const Color(0xFF198396)),
                //   ),
                //   onPressed: () async {
                //     showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           titleTextStyle: const TextStyle(
                //             color: Colors.white,
                //             fontSize: 20,
                //             fontWeight: FontWeight.bold,
                //           ),
                //           contentTextStyle: const TextStyle(color: Colors.white),
                //           backgroundColor: const Color(0xFF1E1E1E),
                //           title: const Text('Sign Out ?'),
                //           content: const Text('Are you sure you want to sign out?'),
                //           actions: [
                //             TextButton(
                //               child: const Text(
                //                 'Cancel',
                //                 style: TextStyle(color: Colors.white),
                //               ),
                //               onPressed: () {
                //                 Navigator.of(context).pop();
                //               },
                //             ),
                //             CustomElevatedButton(
                //               text: "Ok",
                //               onPressed: () {
                //                 auth.signout();
                //                 Navigator.of(context).pop();
                //               },
                //               paddingHorizontal: 8,
                //               paddingVertical: 8,
                //             ),
                //           ],
                //         );
                //       },
                //     );
                //   },
                //   child: const Text('Sign Out'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
