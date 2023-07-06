import 'package:carive/models/user_model.dart';
import 'package:carive/screens/chat/screen/chat_screen.dart';
import 'package:carive/screens/home/home.dart';
import 'package:carive/screens/host/host_screen.dart';
import 'package:carive/screens/notification/screen/notification_screen.dart';
import 'package:carive/screens/settings/screen/screen.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/profile/profile_screen.dart';
import '../../services/auth.dart';
import '../../services/user_database_service.dart';
import '../circular_progress_indicator.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool isHost = false;
  String guestOrHost = "Guest";
  int selectedIndex = 2;
  List<Widget> widgetOptions = [
    ChatScreen(),
     SettingsScreen(),
    const Home(),
    NotificationScreen(),
    ProfileScreen()
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserDatabaseService userDatabaseService = UserDatabaseService();
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: UserDatabaseService().users,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator if data is still loading
          const CustomProgressIndicator();
        }
        if (snapshot.hasError) {
          // Display an error message if there's an error in fetching the data
          return const Center(
            child: Text('Error retrieving user data'),
          );
        }
        final userData = snapshot.data?.docs ?? [];
        final currentUser = _auth.currentUser;

        UserModel? myUser;
        if (currentUser != null) {
          for (var user in userData) {
            if (user.id == currentUser.uid) {
              myUser = UserModel.fromDocumentSnapshot(user);
              break;
            }
          }
        }

        return Scaffold(
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
                    guestOrHost,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Switch(
                    activeTrackColor: themeColorGrey,
                    activeColor: themeColorGreen,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white,
                    value: isHost,
                    onChanged: (value) {
                      if (myUser?.name != null || !value) {
                        setState(() {
                          isHost = value;
                          guestOrHost = value ? "Host" : "Guest";
                        });
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
          body: isHost
              ? const HostScreen()
              : widgetOptions.elementAt(selectedIndex),
          bottomNavigationBar: Visibility(
            visible: !isHost,
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
              index: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
