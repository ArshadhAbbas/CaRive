import 'dart:async';
import 'dart:io';

import 'package:carive/models/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;


class CarService {
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

  Future<void> postNewCar({
    required String uid,
    required String carModel,
    required String make,
    required String fuelType,
    required String seatCapacity,
    required String modelYear,
    required String amount,
    required String location,
    required String additionalInfo,
    required bool isAvailable
  }) async {
    if (selectedImage == null) {
      throw Exception('No image selected for the car');
    }

    final imageUrl = await uploadImage(selectedImage!);

    final newCar = Car(
      userId:uid ,
      carModel: carModel,
      make: make,
      fuelType: fuelType,
      seatCapacity: seatCapacity,
      modelYear: modelYear,
      amount: amount,
      location: location,
      imageUrl: imageUrl,
      isAvailable: isAvailable
    );

    await carCollectionReference.add(newCar.toMap());
  }

    Stream<QuerySnapshot> get car {
    return carCollectionReference.snapshots();
  }

  void dispose() {
    _selectedImageController.close();
  }
}
