// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:carive/models/custom_user.dart';
import 'package:carive/providers/bottom_navbar_provider.dart';
import 'package:carive/providers/location_selection_provider.dart';
import 'package:carive/providers/register_screen_provider.dart';
import 'package:carive/providers/search_screen_provider.dart';
import 'package:carive/screens/host/host_notifications/host_notifications.dart';
import 'package:carive/screens/splash/splash_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/firebase__notification_api.dart';

import 'providers/add_car_provider.dart';
import 'providers/booking_date_range_provider.dart';
import 'providers/cusom_textfromfield_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<CustomUser?>.value(
          value: AuthService().user,
          initialData: null,
          catchError: (context, error) {
            return null;
          },
        ),
        ChangeNotifierProvider<SearchScreenState>(
          create: (context) => SearchScreenState(),
        ),
        ChangeNotifierProvider<RegisterScreenProvider>(
          create: (context) => RegisterScreenProvider(),
        ),
        ChangeNotifierProvider<BookingDateRangeProvider>(
          create: (context) => BookingDateRangeProvider(),
        ),
        ChangeNotifierProvider<AddCarProvider>(
          create: (context) => AddCarProvider(),
        ),
        ChangeNotifierProvider<CustomTextFormFieldProvider>(
          create: (context) => CustomTextFormFieldProvider(),
        ),
        ChangeNotifierProvider<BottomNavBarProvider>(
          create: (context) => BottomNavBarProvider(),
        ),
        ChangeNotifierProvider<LocationSelectionProvider>(
          create: (context) => LocationSelectionProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        home: const SpalshScreen(),
        routes: {
          HostNotifications.route: (context) => const HostNotifications(),
          // Add other routes here if needed.
        },
      ),
    );
  }
}
