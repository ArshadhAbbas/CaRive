import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class UserDatabaseService {
  UserDatabaseService({this.uid});
  final String? uid;

  final StreamController<File?> _selectedImageController =
      StreamController<File?>.broadcast();

  Stream<File?> get selectedImageStream => _selectedImageController.stream;

  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");

// Create user profile

  Future<void> addUser(String uid, String name, String address,
      String phoneNumber, String mailId) async {
    try {
      String url = await uploadImage(selectedImage!);
      await userCollectionReference.doc(uid).set({
        "id": uid,
        "image": url,
        "name": name,
        "phone_number": phoneNumber,
        "email": mailId,
        "address": address
      });
    } catch (e) {
      print("An error occurred while adding the user: $e");
      throw e;
    }
  }

  // Edit user profile

  Future<void> updateUserData(
    String uid,
    String name,
    String address,
    String phoneNumber,
    String mailId,
  ) async {
    if (selectedImage != null) {
      String url = await uploadImage(selectedImage!);
      await userCollectionReference.doc(uid).update({
        "image": url,
      });
    }
     await userCollectionReference.doc(uid).update({
      "name": name,
      "phone_number": phoneNumber,
      "email": mailId,
      "address": address
    });
  }

  // Image picker from gallery

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

  // Upload image to firestore

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance.ref().child('users/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
      print("DownloadUrl:$value");
    });
    return imageUrl;
  }

//  Delete user profile
  Future deleteUser(String deleteUid) async {
    // Delete user document
    await userCollectionReference.doc(deleteUid).delete();

    // Delete user image from Firebase Storage
    var userDoc = await userCollectionReference.doc(deleteUid).get();
    var data = userDoc.data() as Map<String, dynamic>?;

    if (data != null) {
      var imageUrl = data['image'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        var imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await imageRef.delete();
      }
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await userCollectionReference.doc(uid).get();
  }

  Stream<QuerySnapshot> get users {
    return userCollectionReference.snapshots();
  }

  void dispose() {
    _selectedImageController.close();
  }
}
