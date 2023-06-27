import 'package:carive/firebase_options.dart';
import 'package:carive/models/custom_user.dart';
import 'package:carive/screens/host/host_notifications.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/firebase__notification_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash/splash_screen.dart';

// Future<void> backroundHandler(RemoteMessage message) async {
//   print(" This is message from background");
//   print(message.notification!.title);
//   print(message.notification!.body);
// }
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotfications();
  // FirebaseMessaging.onBackgroundMessage(backroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser?>.value(
      value: AuthService().user,
      initialData: null,
      catchError: (context, error) {
        print("StreamProvider Error: $error");
        return null;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: SpalshScreen(),
        routes: {
          HostNotifications.route: (context) => HostNotifications(),
        },
      ),
    );
  }
}
