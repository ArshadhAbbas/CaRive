import 'dart:convert';
import 'package:carive/keys/keys.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:intl/intl.dart';

class NotificationService {
  final UserDatabaseService userDatabaseService = UserDatabaseService();
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");

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
        final timestamp = DateTime.now();

        // Create a new document in the "ownerNotifications" subcollection
        final ownerNotificationRef = userCollectionReference
            .doc(ownerId)
            .collection("ownerNotifications")
            .doc();

        final notificationId = ownerNotificationRef.id;

        // Save the notification data
        await ownerNotificationRef.set({
          'notificationId': notificationId,
          'message': '$userName requested for a new booking request from ',
          'timestamp': timestamp.toIso8601String(),
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'customerId': userId
        });

        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }


   Future<void> sendApprovalNotificationToCustomer(String customerFcmToken) async {
    try {
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $fcmServiceKey',
      };

      final body = {
        'to': customerFcmToken,
        'notification': {
          'body': 'Your request has been approved.',
          'title': 'caRive'
        },
        'data': {
          'title': 'Push Notification',
          'message': 'Request Approved',
          'redirect': 'product'
        }
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Approval notification sent successfully');
      } else {
        print('Failed to send approval notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending approval notification: $e');
    }
  }
}
