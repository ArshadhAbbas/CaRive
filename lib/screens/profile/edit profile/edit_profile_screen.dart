import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/auth.dart';
import '../../../services/user_database_service.dart';
import '../../../shared/constants.dart';
import '../../../shared/custom_elevated_button.dart';
import '../../../shared/custom_scaffold.dart';
import '../../../shared/custom_text_form_field.dart';

class EditProfile extends StatefulWidget {
  final String name;
  final String address;
  final String number;
  final String image;
  final String mail;

  const EditProfile({
    Key? key,
    required this.name,
    required this.address,
    required this.number,
    required this.image,
    required this.mail,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  String? photo;
  bool isLoading = false;

  AuthService auth = AuthService();
  UserDatabaseService userDatabaseService = UserDatabaseService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    addressController = TextEditingController(text: widget.address);
    mailController = TextEditingController(text: widget.mail);
    numberController = TextEditingController(text: widget.number);
    photo = null;
  }

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
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      hSizedBox20,
                      StreamBuilder<File?>(
                        stream: userDatabaseService.selectedImageStream,
                        builder: (context, snapshot) {
                          final File? selectedImage = snapshot.data;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: selectedImage != null
                                    ? Image.file(
                                        selectedImage,
                                        height: 180,
                                        width: 180,
                                        fit: BoxFit.cover,
                                      )
                                    : BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 15,
                                          sigmaY: 15,
                                        ),
                                        child: Container(
                                          height: 180,
                                          width: 180,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white60.withOpacity(0.25),
                                                Colors.white10,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: Image(
                                            image: NetworkImage(
                                              widget.image,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  child: IconButton(
                                    onPressed: () {
                                      userDatabaseService.getImage(
                                        ImageSource.gallery,
                                      );
                                    },
                                    icon: Icon(Icons.edit),
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
                        style: TextStyle(
                          color: themeColorblueGrey,
                          fontSize: 18,
                        ),
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
                        style: TextStyle(
                          color: themeColorblueGrey,
                          fontSize: 18,
                        ),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        controller: numberController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      hSizedBox20,
                      Text(
                        "Email",
                        style: TextStyle(
                          color: themeColorblueGrey,
                          fontSize: 18,
                        ),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        controller: mailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      hSizedBox20,
                      Text(
                        "Address",
                        style: TextStyle(
                          color: themeColorblueGrey,
                          fontSize: 18,
                        ),
                      ),
                      hSizedBox10,
                      CustomTextFormField(
                        controller: addressController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      hSizedBox30,
                      Center(
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: themeColorGreen,
                              )
                            : CustomElevatedButton(
                                text: "Save",
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await userDatabaseService.updateUserData(
                                      auth.auth.currentUser!.uid,
                                      nameController.text,
                                      addressController.text,
                                      numberController.text,
                                      mailController.text,
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Center(
                                          child: Text('Profile Data Updated'),
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    Navigator.of(context).pop();
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
