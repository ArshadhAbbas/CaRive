import 'dart:convert';
import 'package:carive/keys/keys.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<void> sendNotificationToOwner(
      String ownerFCMToken, String userName) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $fcmServiceKey', // Replace with your server key
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
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.reasonPhrase}');
    }
  }
}
