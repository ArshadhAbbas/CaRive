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

  @override
  void initState() {
    super.initState();
    userId = auth.auth.currentUser?.uid ?? '';
  }

  Future<void> sendApprovalNotification(
      String customerId, String carModel, int amount) async {
    try {
      final notificationService = NotificationService();
      final customerFcmToken = await getCustomerFCMToken(customerId);
      await notificationService.sendApprovalNotificationToCustomer(
        customerFcmToken,
        customerId,
        userId,
        carModel,
        amount,
      );
    } catch (e) {
      print('Error sending approval notification: $e');
    }
  }

  Future<void> sendRejectionNotification(
      String customerId, String carModel) async {
    try {
      final notificationService = NotificationService();
      final customerFcmToken = await getCustomerFCMToken(customerId);
      await notificationService.sendRejectionNotificationToCustomer(
          customerFcmToken, customerId, userId, carModel);
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
                  final notification =
                      notifications[index].data() as Map<String, dynamic>;
                  final notifcationTimestampString =
                      notification['timestamp'] as String;
                  final notifcationTimestamp =
                      DateTime.parse(notifcationTimestampString);
                  final notifcationFormattedDate =
                      DateFormat('dd/MM hh:mm').format(notifcationTimestamp);

                  final customerId = notification['customerId'] as String;

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: getCustomerData(customerId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Error loading customer data.'),
                        );
                      }
                      final customerData = snapshot.data;
                      final customerImage = customerData?['image'] as String?;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: customerImage != null
                              ? NetworkImage(customerImage)
                              : AssetImage('assets/dp.png')
                                  as ImageProvider<Object>,
                        ),
                        title: Text(
                          "${notification['message']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          notifcationFormattedDate,
                          style: TextStyle(color: themeColorblueGrey),
                        ),
                        trailing: Visibility(
                          visible: !notification['didReply'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.highlight_remove_rounded,
                                  color: Colors.grey,
                                ),
                                onPressed: () async {
                                  await sendRejectionNotification(
                                    notification['customerId'] as String,
                                    notification['car'] as String,
                                  );
                                  final notificationId =
                                      notification['notificationId'] as String;
                                  final ownerNotificationRef = FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('ownerNotifications')
                                      .doc(notificationId);
                                  try {
                                    await ownerNotificationRef
                                        .update({'didReply': true});
                                  } catch (e) {
                                    print(
                                        'Error updating "didReply" field in Firestore: $e');
                                  }
                                },
                              ),
                              
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: themeColorGreen,
                                ),
                                onPressed: () async {
                                  await sendApprovalNotification(
                                    notification['customerId'] as String,
                                    notification['car'] as String,
                                    notification['amount']
                                  );
                                  final notificationId =
                                      notification['notificationId'] as String;
                                  final ownerNotificationRef = FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('ownerNotifications')
                                      .doc(notificationId);
                                  try {
                                    await ownerNotificationRef
                                        .update({'didReply': true});
                                  } catch (e) {
                                    print(
                                        'Error updating "didReply" field in Firestore: $e');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
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

Future<Map<String, dynamic>?> getCustomerData(String customerId) async {
  final DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(customerId)
      .get();
  return snapshot.data() as Map<String, dynamic>?;
}
