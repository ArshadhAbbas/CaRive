import 'package:carive/services/notification_service.dart';
import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth.dart';

class HostNotifications extends StatefulWidget {
  const HostNotifications({Key? key}) : super(key: key);
  static const route = '/host-notification-screen';

  @override
  State<HostNotifications> createState() => _HostNotificationsState();
}

class _HostNotificationsState extends State<HostNotifications> {
  AuthService auth = AuthService();
  late String userId;
  List<bool> iconButtonsDisabled = [];

  @override
  void initState() {
    super.initState();
    userId = auth.auth.currentUser?.uid ?? '';
  }

  Future<void> sendApprovalNotification(String customerId) async {
    try {
      final notificationService = NotificationService();
      final customerFcmToken = await getCustomerFCMToken(customerId);
      await notificationService
          .sendApprovalNotificationToCustomer(customerFcmToken);
      print('Approval notification sent successfully');
    } catch (e) {
      print('Error sending approval notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('ownerNotifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final notifications = snapshot.data!.docs;
              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: themeColorGreen),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  if (index >= iconButtonsDisabled.length) {
                    iconButtonsDisabled.add(false);
                  }
                  final notification =
                      notifications[index].data() as Map<String, dynamic>;
                  final notifcationTimestampString =
                      notification['timestamp'] as String;
                  final notifcationTimestamp =
                      DateTime.parse(notifcationTimestampString);
                  final notifcationFormattedDate =
                      DateFormat('dd/MM hh:mm').format(notifcationTimestamp);

                  final startDateTimestampString =
                      notification['startDate'] as String;
                  final startDateTimestamp =
                      DateTime.parse(startDateTimestampString);
                  final startDateFormattedDate =
                      DateFormat('dd/MM/yy').format(startDateTimestamp);

                  final endDateTimestampString =
                      notification['endDate'] as String;
                  final endDateTimestamp =
                      DateTime.parse(endDateTimestampString);
                  final endDateFormattedDate =
                      DateFormat('dd/MM/yy').format(endDateTimestamp);
                  return ListTile(
                    title: Text(
                      "${notification['message']} $startDateFormattedDate to $endDateFormattedDate.",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      notifcationFormattedDate,
                      style: TextStyle(color: themeColorblueGrey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!iconButtonsDisabled[index])
                          IconButton(
                            icon: Icon(
                              Icons.highlight_remove_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                iconButtonsDisabled[index] = true;
                              });
                              // Perform action for first IconButton
                            },
                          ),
                        if (!iconButtonsDisabled[index])
                          IconButton(
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: themeColorGreen,
                            ),
                            onPressed: () async {
                              setState(() {
                                iconButtonsDisabled[index] = true;
                              });
                              await sendApprovalNotification(
                                  notification['customerId'] as String);
                              // Perform action for second IconButton
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching Notification.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return const CustomProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

Future<String> getCustomerFCMToken(String customerId) async {
  final DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(customerId)
      .get();
  final userData = snapshot.data() as Map<String, dynamic>?;
  final fcmToken = userData?['fcmToken'] as String? ?? '';
  return fcmToken;
}
