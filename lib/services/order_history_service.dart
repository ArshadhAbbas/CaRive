import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersHistoryService {
  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  Future<void> addToMyHistory(
    String ownerId,
    String uid,
    String carId,
    int price,
    String startDate,
    String endDate,
  ) async {
    try {
      final myOrdersCollectionReference =
          userCollectionReference.doc(uid).collection("myOrders").doc();

      final orderId = myOrdersCollectionReference.id;

      // Save the notification data
      await myOrdersCollectionReference.set({
        'ownerId': ownerId,
        'OrderId': orderId,
        'carId': carId,
        'amount': price,
        'startDate': startDate,
        'endDate': endDate,
        'orderDate':DateTime.now().toIso8601String()
      });
    } catch (e) {
      print("An error occurred while adding the car to orderHistory: $e");
      throw e;
    }
  }
}
