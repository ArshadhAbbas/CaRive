import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class UserDatabaseService {
  final StreamController<File?> _selectedImageController =
      StreamController<File?>.broadcast();

  Stream<File?> get selectedImageStream => _selectedImageController.stream;

  final CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference carCollectionReference =
      FirebaseFirestore.instance.collection("cars");

// Create user profile

  Future<void> addUser(
    String uid,
    String name,
    String address,
    String phoneNumber,
    String mailId,
    String fcmToken,
  ) async {
    try {
      String url = await uploadImage(selectedImage!);
      await userCollectionReference.doc(uid).set({
        "id": uid,
        "image": url,
        "name": name,
        "phone_number": phoneNumber,
        "email": mailId,
        "address": address,
        'fcmToken': fcmToken
      });
    } catch (e) {
      print("An error occurred while adding the user: $e");
      rethrow;
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

  Future<String> getCurrentUserName(String uid) async {
    try {
      final userSnapshot = await userCollectionReference.doc(uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        return userData['name'] ?? '';
      }
    } catch (e) {
      print('An error occurred while getting the user name: $e');
    }
    return '';
  }

  Future<String> getCurrentUserImage(String uid) async {
    try {
      final userSnapshot = await userCollectionReference.doc(uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        return userData['image'] ?? '';
      }
    } catch (e) {
      print('An error occurred while getting the user name: $e');
    }
    return '';
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
    });
    return imageUrl;
  }
  Future<void> deleteUser(String deleteUid) async {
  // Delete user's profile image if available
  final userDocSnapshot = await userCollectionReference.doc(deleteUid).get();
  final userData = userDocSnapshot.data() as Map<String, dynamic>?;

  if (userData != null) {
    final imageUrl = userData['image'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();
    }

    // Delete the user's posts
    final posts = userData['posts'] as List<dynamic>?;
    if (posts != null && posts.isNotEmpty) {
      for (final postId in posts) {
        final carDocRef = carCollectionReference.doc(postId);
        final carDocSnapshot = await carDocRef.get();
        if (carDocSnapshot.exists) {
          final carData = carDocSnapshot.data() as Map<String, dynamic>?;
          final carImageUrl = carData?['imageUrl'];

          // Delete the car document
          await carDocRef.delete();

          // Delete the car's image from Firebase Storage (if applicable)
          if (carImageUrl != null && carImageUrl.isNotEmpty) {
            final carImageRef = FirebaseStorage.instance.refFromURL(carImageUrl);
            await carImageRef.delete();
          }
        }
      }
    }

    // Delete chat documents for the user with other users
    await deleteChatDocumentsForUser(deleteUid);

    // Delete the user document itself
    await userCollectionReference.doc(deleteUid).delete();
  }
}

Future<void> deleteChatDocumentsForUser(String userId) async {
  final QuerySnapshot chatsSnapshot =
      await userCollectionReference.doc(userId).collection('chats').get();
  final chats = chatsSnapshot.docs;

  // Delete chat documents for the current user with other users
  for (final chat in chats) {
    await deleteChatDocuments(userId, chat.id);
  }
}

Future<void> deleteChatDocuments(String user1Id, String user2Id) async {
  // Delete chat document for user1 with user2
  await userCollectionReference
      .doc(user1Id)
      .collection("chats")
      .doc(user2Id)
      .delete();

  // Delete all messages for user1 with user2
  final user1MessagesRef = userCollectionReference
      .doc(user1Id)
      .collection("chats")
      .doc(user2Id)
      .collection("messages");
  final user1MessagesSnapshot = await user1MessagesRef.get();
  for (final messageDoc in user1MessagesSnapshot.docs) {
    await messageDoc.reference.delete();
  }

  // Delete chat document for user2 with user1
  await userCollectionReference
      .doc(user2Id)
      .collection("chats")
      .doc(user1Id)
      .delete();

  // Delete all messages for user2 with user1
  final user2MessagesRef = userCollectionReference
      .doc(user2Id)
      .collection("chats")
      .doc(user1Id)
      .collection("messages");
  final user2MessagesSnapshot = await user2MessagesRef.get();
  for (final messageDoc in user2MessagesSnapshot.docs) {
    await messageDoc.reference.delete();
  }
}

  Future<void> addFcmToken(String uid, String? fcmToken) async {
    try {
      await userCollectionReference.doc(uid).update({
        "fcmToken": FieldValue.arrayUnion([fcmToken]),
      });
    } catch (e) {
      print("An error occurred while adding the fcm Token: $e");
      throw e;
    }
  }

  Future<void> addPost(String uid, String postId) async {
    try {
      await userCollectionReference.doc(uid).update({
        "posts": FieldValue.arrayUnion([postId]),
      });
    } catch (e) {
      print("An error occurred while adding the post: $e");
      throw e;
    }
  }

  Future<void> removePost(String uid, String postId) async {
    try {
      await userCollectionReference.doc(uid).update({
        "posts": FieldValue.arrayRemove([postId]),
      });
    } catch (e) {
      print("An error occurred while removing the post: $e");
      throw e;
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
