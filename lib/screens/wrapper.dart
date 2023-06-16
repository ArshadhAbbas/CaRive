import 'package:carive/screens/home/home.dart';
import 'package:carive/shared/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/custom_user.dart';
import 'authenticate/signin.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);
    if (user == null) {
      return  SignIn();
    } else {
      return  BottomNavBar();
    }
  }
}
