import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:carive/shared/bottom_nav_bar/bottom_nav_bar.dart';

import '../models/custom_user.dart';
import 'authenticate/signin.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);
    if (user == null) {
      return  const SignIn();
    } else {
      return  const BottomNavBar();
    }
  }
}
