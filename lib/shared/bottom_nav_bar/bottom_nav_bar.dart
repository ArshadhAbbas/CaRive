import 'package:carive/screens/chat/screen/chat_screen.dart';
import 'package:carive/screens/home/home.dart';
import 'package:carive/screens/host/host_screen.dart';
import 'package:carive/screens/notification/screen/notification_screen.dart';
import 'package:carive/screens/settings/screen/screen.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/logo.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../screens/profile/create_profile/create_profile.dart';
import '../../screens/profile/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool isHost = false;
  String guestOrHost = "Guest";
  int selectedIndex = 2;
  bool isProfileCreated=false;
  List<Widget> widgetOptions = [
    const ChatScreen(),
    const SettingsScreen(),
    const Home(),
     NotificationScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: isProfileCreated? Text(
          "Hello UserName",
          style: TextStyle(color: Colors.white),
        ):Row(
          children: [
            LogoWidget(30, 30),wSizedBox10,
            Text("CaRive")
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Row(
            children: [
              Text(
                guestOrHost,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Switch(
                activeTrackColor: themeColorGrey,
                activeColor: themeColorGreen,

                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white,
                value: isHost,
                onChanged: (value) {
                  setState(() {
                    isHost = value;
                    guestOrHost = value ? "Host" : "Guest";
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: isHost ? HostScreen() : widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: Visibility(
        visible: !isHost,
        child: CurvedNavigationBar(
          height: 60,
          color: themeColorGreen,
          animationCurve: Curves.easeOutQuart,
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
  }
}
