import 'package:cloud_firestore/cloud_firestore.dart';


class CarModel {
  String? carId;
  final String carModel;
  final String make;
  final String fuelType;
  final String seatCapacity;
  final String modelYear;
  final String amount;
  final String location;
  final String imageUrl;
  final bool isAvailable;
  final String ownerFcmToken;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime postDate;

  CarModel({
    this.carId,
    required this.ownerFcmToken,
    required this.carModel,
    required this.make,
    required this.fuelType,
    required this.seatCapacity,
    required this.modelYear,
    required this.amount,
    required this.location,
    required this.imageUrl,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.postDate,
  });

  factory CarModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final carId = snapshot.id; // Retrieve the document ID
    return CarModel(
      ownerFcmToken: data['ownerFcmToken'],
      carId: carId,
      carModel: data['carModel'],
      make: data['make'],
      fuelType: data['fuelType'],
      seatCapacity: data['seatCapacity'],
      modelYear: data['modelYear'],
      amount: data['amount'],
      location: data['location'],
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'],
      userId: data['userId'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      postDate: (data['postDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carModel': carModel,
      'make': make,
      'fuelType': fuelType,
      'seatCapacity': seatCapacity,
      'modelYear': modelYear,
      'amount': amount,
      'location': location,
      'imageUrl': imageUrl,
      'userId': userId,
      'isAvailable': isAvailable,
      'ownerFcmToken': ownerFcmToken,
      'latitude': latitude,
      'longitude': longitude,
      'postDate': postDate,
    };
  }
}