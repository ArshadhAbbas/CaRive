import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String image;
  final String address;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.image,
    required this.address,
    this.fcmToken,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return UserModel(
      id: data?['id'] ?? '',
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      phoneNumber: data?['phone_number'] ?? '',
      image: data?['image'] ?? '',
      address: data?['address'] ?? '',
      fcmToken: data?['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'image': image,
      'address': address,
    };
  }
}
