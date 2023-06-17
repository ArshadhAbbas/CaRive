import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:carive/models/user_model.dart';
import 'package:carive/screens/profile/create_profile/create_profile.dart';
import 'package:carive/screens/profile/edit%20profile/edit_profile_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserDatabaseService userDatabaseService = UserDatabaseService();
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: StreamBuilder<QuerySnapshot>(
        stream: UserDatabaseService().users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator if data is still loading
            return Center(
              child: CircularProgressIndicator(
                color: themeColorGreen,
              ),
            );
          }
          if (snapshot.hasError) {
            // Display an error message if there's an error in fetching the data
            return const Center(
              child: Text('Error retrieving user data'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Display a text when there is no data for the current user
            return Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const CreateProfile();
                    },
                  ));
                },
                child: const Text(
                  'Create your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }

          final userData = snapshot.data!.docs;
          final currentUser = _auth.currentUser;

          UserModel? myUser;
          if (currentUser != null) {
            for (var user in userData) {
              if (user.id == currentUser.uid) {
                myUser = UserModel.fromDocumentSnapshot(user);
                break;
              }
            }
          }
          if (myUser == null) {
            // Display a text when there is no user data available
            return Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const CreateProfile();
                    },
                  ));
                },
                child: const Text(
                  'Create your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Stack(
                  children: [
                    Image.network(
                      myUser.image,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF3E515F),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return EditProfile(
                              mail: myUser!.email,
                              address: myUser.address,
                              image: myUser.image,
                              name: myUser.name,
                              number: myUser.phoneNumber,
                            );
                          },
                        )),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      color: themeColorGrey,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myUser.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                ),
                              ),
                              hSizedBox10,
                              Text(
                                myUser.phoneNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              hSizedBox10,
                              Text(
                                myUser.email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              hSizedBox10,
                              Text(
                                myUser.address,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      titleTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      contentTextStyle:
                                          const TextStyle(color: Colors.white),
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: const Text('Delete ?'),
                                      content: const Text(
                                          'Are you sure you want to Delete yor Account?'),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        CustomElevatedButton(
                                          text: "Ok",
                                          onPressed: () {
                                            userDatabaseService.deleteUser(
                                                auth.auth.currentUser!.uid);
                                            Navigator.pop(context);
                                          },
                                          paddingHorizontal: 8,
                                          paddingVertical: 8,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              tooltip: "Delete Account",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
