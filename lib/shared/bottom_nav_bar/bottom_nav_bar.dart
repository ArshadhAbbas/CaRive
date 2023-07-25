// ignore_for_file: use_key_in_widget_constructors

import 'package:carive/models/user_model.dart';
import 'package:carive/providers/bottom_navbar_provider.dart';
import 'package:carive/screens/host/host_screen.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:carive/shared/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_database_service.dart';
import '../circular_progress_indicator.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    Provider.of<BottomNavBarProvider>(context, listen: false).isHost = false;
    Provider.of<BottomNavBarProvider>(context, listen: false).selectedIndex = 2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: UserDatabaseService().users,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error retrieving user data'),
          );
        }
        final userData = snapshot.data?.docs ?? [];
        final currentUser = FirebaseAuth.instance.currentUser;

        UserModel? myUser;
        if (currentUser != null) {
          for (var user in userData) {
            if (user.id == currentUser.uid) {
              myUser = UserModel.fromDocumentSnapshot(user);
              break;
            }
          }
        }

        return CustomScaffold(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: Row(
                children: [
                  const LogoWidget(30, 30),
                  wSizedBox10,
                  Text(
                    myUser?.name ?? "Carive",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Row(
                  children: [
                    Text(
                       Provider.of<BottomNavBarProvider>(context).isHost ? "Host" : "Guest",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                    CupertinoSwitch(
                      activeColor: themeColorGrey,
                      trackColor: Colors.white,
                      thumbColor: themeColorblueGrey,
                      value:  Provider.of<BottomNavBarProvider>(context).isHost,
                      onChanged: (value) {
                        if (myUser?.name != null || !value) {
                           Provider.of<BottomNavBarProvider>(context, listen: false).toggleIsHost(value);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: themeColorGrey,
                                title: const Text(
                                  'Create Profile',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Please create a profile before switching to host mode.',
                                  style: TextStyle(color: Colors.white),
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
                      },
                    ),
                  ],
                )
              ],
            ),
            body:  Provider.of<BottomNavBarProvider>(context).isHost
                ? const HostScreen()
                :  Provider.of<BottomNavBarProvider>(context).widgetOptions.elementAt( Provider.of<BottomNavBarProvider>(context).selectedIndex),
            bottomNavigationBar: Visibility(
              visible: ! Provider.of<BottomNavBarProvider>(context).isHost,
              child: CurvedNavigationBar(
                height: 60,
                color: themeColorGreen,
                animationCurve: Curves.ease,
                buttonBackgroundColor: themeColorblueGrey,
                backgroundColor: Colors.transparent,
                items: const [
                  Icon(Icons.message),
                  Icon(Icons.settings),
                  Icon(Icons.home),
                  Icon(Icons.notifications),
                  Icon(Icons.person),
                ],
                index:  Provider.of<BottomNavBarProvider>(context).selectedIndex,
                onTap: (value) {
                   Provider.of<BottomNavBarProvider>(context, listen: false).setSelectedIndex(value);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
