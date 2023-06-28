import 'dart:convert';
import 'package:carive/keys/keys.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:intl/intl.dart';

class NotificationService {
  final UserDatabaseService userDatabaseService = UserDatabaseService();
  final CollectionReference notificationCollectionReference =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> sendNotificationToOwner(
    String userId,
    String ownerFCMToken,
    String userName,
    String ownerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $fcmServiceKey', // Replace with your server key
      };
      final dateFormatter = DateFormat('dd/MM');
      final formattedStartDate = dateFormatter.format(startDate);
      final formattedEndDate = dateFormatter.format(endDate);

      final body = {
        'to': ownerFCMToken,
        'notification': {
          'body':
              '$userName requested for a new booking request from $formattedStartDate to $formattedEndDate .',
          'title': 'caRive'
        },
        "data": {
          "title": "Push Notification",
          "message": "Test Push Notification",
          "redirect": "product"
        }
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final notification = notificationCollectionReference.doc();
        final notificationId = notification.id;
        final timestamp = DateTime.now();

        // Save the notification to Firestore
        await notification.set({
          'notificationId': notificationId,
          'ownerId': ownerId,
          'message': '$userName requested for a new booking request from ',
          'timestamp': timestamp.toIso8601String(),
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'customerId': userId
        });

        // Add the notification ID to the owner's ID
        await userDatabaseService.addNotification(ownerId, notificationId);

        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
