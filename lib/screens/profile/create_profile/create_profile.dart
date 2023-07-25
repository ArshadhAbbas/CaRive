// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/auth.dart';
import '../../../services/user_database_service.dart';
import '../../../shared/circular_progress_indicator.dart';
import '../../../shared/constants.dart';
import '../../../shared/custom_elevated_button.dart';
import '../../../shared/custom_scaffold.dart';
import '../../../shared/custom_text_form_field.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mailController = TextEditingController();

  AuthService auth = AuthService();
  UserDatabaseService userDatabaseService = UserDatabaseService();

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    addressController.dispose();
    mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
        child: SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                      hSizedBox20,
                      StreamBuilder<File?>(
                        stream: userDatabaseService.selectedImageStream,
                        builder: (context, snapshot) {
                          final File? selectedImage = snapshot.data;
                          return Stack(
                            children: [
                              selectedImage == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 15, sigmaY: 15),
                                        child: Container(
                                          height: 180,
                                          width: 180,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.white60
                                                      .withOpacity(0.25),
                                                  Colors.white10
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              userDatabaseService.getImage(
                                                  ImageSource.gallery);
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 15, sigmaY: 15),
                                        child: SizedBox(
                                          height: 180,
                                          width: 180,
                                          child: Image(
                                            image: FileImage(selectedImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        },
                      ),
                      hSizedBox60,
                      Text(
                        "Name",
                        style:
                            TextStyle(color: themeColorblueGrey, fontSize: 18),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      hSizedBox20,
                      Text(
                        "Phone number",
                        style:
                            TextStyle(color: themeColorblueGrey, fontSize: 18),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        length: 10,
                        controller: numberController,
                        keyBoardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      Text(
                        "Email",
                        style:
                            TextStyle(color: themeColorblueGrey, fontSize: 18),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        keyBoardType: TextInputType.emailAddress,
                        controller: mailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an email';
                          }
                          // Add more validation logic if needed
                          return null;
                        },
                      ),
                      hSizedBox20,
                      Text(
                        "Address",
                        style:
                            TextStyle(color: themeColorblueGrey, fontSize: 18),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        maxLines: 3,
                        controller: addressController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an address';
                          }
                          // Add more validation logic if needed
                          return null;
                        },
                      ),
                      hSizedBox20,
                      hSizedBox30,
                      Center(
                        child: CustomElevatedButton(
                          text: "Save",
                          onPressed: () async {
                            dismissKeyboard(context);
                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CustomProgressIndicator(),
                                ),
                              );

                              final userUID = auth.auth.currentUser?.uid;

                              if (userUID != null) {
                                final name = nameController.text;
                                final address = addressController.text;
                                final number = numberController.text;
                                final email = mailController.text;

                                try {
                                  if (userDatabaseService.selectedImage ==
                                      null) {
                                    throw ('Image cannot be empty');
                                  }
                                  final fcmToken = await FirebaseMessaging
                                      .instance
                                      .getToken();

                                  await userDatabaseService.addUser(userUID,
                                      name, address, number, email, fcmToken!);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Center(
                                          child: Text('Profile created')),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Center(child: Text(e.toString())),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
