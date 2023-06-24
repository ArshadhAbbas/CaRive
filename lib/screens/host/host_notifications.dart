import 'package:carive/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HostNotifications extends StatelessWidget {
  const HostNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications =
        Provider.of<NotificationProvider>(context).notifications;

    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(
              notification.title,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              notification.body,
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
