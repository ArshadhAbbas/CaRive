import 'package:carive/shared/custom_elevated_button.dart';
import 'package:flutter/material.dart';

import 'package:carive/services/auth.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';

import 'edit profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: themeColorGrey,
                radius: 80,
                backgroundImage: const AssetImage('assets/pro pic.png'),
              ),
              hSizedBox20,
              Text(
                "Arshadh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
              hSizedBox10,
              Text(
                "+919633760600",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              hSizedBox10,
              Text(
                "arshadhp98@gmail.com",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              hSizedBox10,
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return EditProfile();
                      },
                    ));
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF198396)),
                  ),
                  child: Text("Edit profile"),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF198396))),
                onPressed: () async {
                  // Show alert box
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        contentTextStyle: const TextStyle(color: Colors.white),
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: Text('Sign Out ?'),
                        content: Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the alert box
                            },
                          ),
                          // TextButton(
                          //   child: Text('Sign Out'),
                          //   onPressed: () {
                          //     auth.signout();
                          //     Navigator.of(context)
                          //         .pop(); // Close the alert box
                          //   },
                          // ),
                          CustomElevatedButton(
                            text: "Ok",
                            onPressed: () {
                              auth.signout();
                              Navigator.of(context).pop();
                            },
                            paddingHorizontal: 8,
                            paddingVertical: 8,
                          )
                        ],
                      );
                    },
                  );
                },
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ElevatedButton(
//                 onPressed: () async {
//                   auth.signout();
//                 },
//                 style: ButtonStyle(
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     )),
//                     backgroundColor:
//                         MaterialStateProperty.all(const Color(0xFF198396))),
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
//                   child: Text("logout"),
//                 ),
//               ),

