import 'dart:convert';
import 'package:carive/keys/keys.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carive/services/user_database_service.dart';

class NotificationService {
  final UserDatabaseService userDatabaseService = UserDatabaseService();
  final CollectionReference notificationCollectionReference =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> sendNotificationToOwner(
    String ownerFCMToken,
    String userName,
    String ownerId,
  ) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $fcmServiceKey', // Replace with your server key
    };

    final body = {
      'to': ownerFCMToken,
      'notification': {
        'body': 'You have a new booking request from ${userName}.',
      },
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final notification = notificationCollectionReference.doc();
      final notificationId = notification.id;

      // Save the notification to Firestore
      await notification.set({
        'notificationId': notificationId,
        'ownerId': ownerId,
        'message': 'You have a new booking request from $userName.',
      });

      // Add the notification ID to the owner's ID
      await userDatabaseService.addNotification(ownerId, notificationId);

      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.reasonPhrase}');
    }
  }
}
