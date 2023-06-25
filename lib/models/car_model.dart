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
  final String userId; // New field for user ID

  CarModel(
      {this.carId,
      required this.carModel,
      required this.make,
      required this.fuelType,
      required this.seatCapacity,
      required this.modelYear,
      required this.amount,
      required this.location,
      required this.imageUrl,
      required this.userId,
      required this.isAvailable // Added field for user ID
      });

  factory CarModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final carId = snapshot.id; // Retrieve the document ID
    return CarModel(
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
      'isAvailable': isAvailable
    };
  }
  // factory Car.fromMap(Map<String, dynamic> map) {
  //   return Car(
  //     userId: map['userId'],
  //     carModel: map['carModel'],
  //     make: map['make'],
  //     fuelType: map['fuelType'],
  //     seatCapacity: map['seatCapacity'],
  //     modelYear: map['modelYear'],
  //     amount: map['amount'],
  //     location: map['location'],
  //     imageUrl: map['imageUrl'],
  //     isAvailable: map['isAvailable'],
  //   );
  // }
}
