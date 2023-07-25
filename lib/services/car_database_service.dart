// ignore_for_file: library_prefixes

import 'dart:async';
import 'dart:io';

import 'package:carive/models/car_model.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class CarService {
  final UserDatabaseService userDatabaseService = UserDatabaseService();
  final StreamController<File?> _selectedImageController =
      StreamController<File?>.broadcast();

  Stream<File?> get selectedImageStream => _selectedImageController.stream;

  final CollectionReference carCollectionReference =
      FirebaseFirestore.instance.collection('cars');

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future<File?> getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      _selectedImageController.sink.add(selectedImage);
    }
    return null;
  }

  Future<String> uploadImage(File image) async {
    final fileName = Path.basename(image.path);
    final reference =
        FirebaseStorage.instance.ref().child('car_images/$fileName');
    final uploadTask = reference.putFile(image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

// Inside the _NewPostScreenState class

  Future<void> postNewCar({
    required String uid,
    required String carModel,
    required String make,
    required String fuelType,
    required String seatCapacity,
    required String modelYear,
    required int amount,
    required String location,
    required bool isAvailable,
    required String ownerFcmToken,
    required double latitude,
    required double longitude,
  }) async {
    if (selectedImage == null) {
      throw Exception('No image selected for the car');
    }

    final imageUrl = await uploadImage(selectedImage!);

    final newCar = CarModel(
        latitude: latitude,
        longitude: longitude,
        userId: uid,
        carModel: carModel,
        make: make,
        fuelType: fuelType,
        seatCapacity: seatCapacity,
        modelYear: modelYear,
        amount: amount,
        location: location,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        ownerFcmToken: ownerFcmToken,
        postDate: DateTime.now());

    final newCarDocRef = carCollectionReference.doc();
    final newCarId = newCarDocRef.id;

    await newCarDocRef.set(
      newCar.toMap()..addAll({'carId': newCarId}),
    );

    await userDatabaseService.addPost(uid, newCarId);
  }

  Future<void> updateCarDetails({
    required String carId,
    required String carModel,
    required String make,
    required String fuelType,
    required String seatCapacity,
    required String modelYear,
    required int amount,
    required String location,
    required double latitude,
    required double longitude,
    required bool isAvailable,
  }) async {
    final carDocRef = carCollectionReference.doc(carId);
    if (selectedImage != null) {
      String url = await uploadImage(selectedImage!);
      await carCollectionReference.doc(carId).update({
        "imageUrl": url,
      });
    }

    await carDocRef.update({
      'carModel': carModel,
      'make': make,
      'fuelType': fuelType,
      'seatCapacity': seatCapacity,
      'modelYear': modelYear,
      'amount': amount,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
    });
  }

  Future<void> deleteCar(String carId, String uid) async {
    // Get the car document reference
    final carDocRef = carCollectionReference.doc(carId);

    // Get the car data from the document snapshot
    final carDocSnapshot = await carDocRef.get();
    final carData = carDocSnapshot.data() as Map<String, dynamic>?;

    if (carData != null) {
      final imageUrl = carData['imageUrl'];

      // Delete the car document
      await carDocRef.delete();
      await userDatabaseService.removePost(uid, carId);

      // Delete the car's image from Firebase Storage (if applicable)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await imageRef.delete();
      }
    }
  }

  Stream<QuerySnapshot> get car {
    return carCollectionReference.snapshots();
  }

  void dispose() {
    _selectedImageController.close();
  }
}
