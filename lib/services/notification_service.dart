import 'package:carive/models/notifcation_model.dart';
import 'package:carive/services/firebase__notification_api.dart';
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
    String carModel,
    int amount,
    String carId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final dateFormatter = DateFormat('dd/MM');
      final formattedStartDate = dateFormatter.format(startDate);
      final formattedEndDate = dateFormatter.format(endDate);
      final notificationData = OwnerNotificationsModel(
        amount: amount,
        car: carModel,
        carId: carId,
        customerId: userId,
        didReply: false,
        message:
            '$userName requested for your $carModel from $formattedStartDate to $formattedEndDate ',
        notificationId: '',
        timestamp: DateTime.now().toIso8601String(),
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
      );
      http.Response response = await FirebaseApi().sendNotification(
        FCMToken: ownerFCMToken,
        message: notificationData.message,
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
          'message': notificationData.message,
          'timestamp': timestamp.toIso8601String(),
          'startDate': notificationData.startDate,
          'endDate': notificationData.endDate,
          'customerId': notificationData.customerId,
          'didReply': notificationData.didReply,
          'car': notificationData.car,
          'amount': notificationData.amount,
          'carId': notificationData.carId,
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendPaidNotificationToOwner({
    required String userId,
    required String ownerFCMToken,
    required String userName,
    required String ownerId,
    required String carModel,
    required int amount,
    required String carId,
  }) async {
    try {
      http.Response response = await FirebaseApi().sendNotification(
        FCMToken: ownerFCMToken,
        message: '$userName has paid you an amount of $amount for $carModel.',
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
          'message':
              '$userName has paid you an amount of $amount for $carModel.',
          'timestamp': timestamp.toIso8601String(),
          'customerId': userId,
          'car': carModel,
          'amount': amount,
          'carId': carId,
          'didReply': true
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendApprovalNotificationToCustomer(
    String customerFcmToken,
    String customerId,
    String ownerId,
    String carModel,
    int price,
    String carId,
    String startDate,
    String endDate,
  ) async {
    try {
      http.Response response = await FirebaseApi().sendNotification(
          FCMToken: customerFcmToken,
          message: 'Your request for $carModel has been approved.');

      if (response.statusCode == 200) {
        final timestamp = DateTime.now();

        // Create a new document in the "customerNotifications" subcollection
        final customerNotificationRef = userCollectionReference
            .doc(customerId)
            .collection("customerNotifications")
            .doc();

        final notificationId = customerNotificationRef.id;

        // Save the notification data
        await customerNotificationRef.set({
          'ownerId': ownerId,
          'notificationId': notificationId,
          'message': 'Your request for $carModel has been approved.',
          'timestamp': timestamp.toIso8601String(),
          'customerId': customerId,
          'car': carModel,
          'amount': price,
          'didPay': false,
          'carId': carId,
          'startDate': startDate,
          'endDate': endDate,
        });

        print('Approval notification sent successfully');
      } else {
        print(
            'Failed to send approval notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending approval notification: $e');
    }
  }

  Future<void> sendRejectionNotificationToCustomer(
    String customerFcmToken,
    String customerId,
    String ownerId,
    String carModel,
  ) async {
    try {
      http.Response response = await FirebaseApi().sendNotification(
          FCMToken: customerFcmToken,
          message: 'Your request for $carModel has been rejected.');

      if (response.statusCode == 200) {
        final timestamp = DateTime.now();

        // Create a new document in the "customerNotifications" subcollection
        final customerNotificationRef = userCollectionReference
            .doc(customerId)
            .collection("customerNotifications")
            .doc();

        final notificationId = customerNotificationRef.id;

        // Save the notification data
        await customerNotificationRef.set({
          'ownerId': ownerId,
          'notificationId': notificationId,
          'message': 'Your request for $carModel has been rejected.',
          'timestamp': timestamp.toIso8601String(),
          'customerId': customerId,
          'car': carModel,
          'didPay': true,
        });

        print('Rejection notification sent successfully');
      } else {
        print(
            'Failed to send rejection notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending rejection notification: $e');
    }
  }

 
}
