class OwnerNotificationsModel {
  final int amount;
  final String car;
  final String carId;
  final String customerId;
  final bool didReply;
  final String message;
  final String notificationId;
  final String timestamp;
  final String? startDate; // Nullable startDate
  final String? endDate;   // Nullable endDate

  OwnerNotificationsModel({
    required this.amount,
    required this.car,
    required this.carId,
    required this.customerId,
    required this.didReply,
    required this.message,
    required this.notificationId,
    required this.timestamp,
    this.startDate,
    this.endDate,
  });

  factory OwnerNotificationsModel.fromJson(Map<String, dynamic> json) {
    return OwnerNotificationsModel(
      amount: json['amount'] ?? 0,
      car: json['car'] ?? '',
      carId: json['carId'] ?? '',
      customerId: json['customerId'] ?? '',
      didReply: json['didReply'] ?? false,
      message: json['message'] ?? '',
      notificationId: json['notificationId'] ?? '',
      timestamp: json['timestamp'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'car': car,
      'carId': carId,
      'customerId': customerId,
      'didReply': didReply,
      'message': message,
      'notificationId': notificationId,
      'timestamp': timestamp,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
