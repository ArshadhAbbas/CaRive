import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:carive/shared/custom_text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  DateTime? datetime;
  // DateTime(1990, 1, 1);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF3E515F),
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Edit Profile"),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: themeColorGrey,
                      radius: 80,
                      backgroundImage: const AssetImage('assets/pro pic.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: themeColorGreen,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    )
                  ],
                ),
                hSizedBox60,
                CustomTextFormField(
                  controller: nameController,
                  hintText: "Name",
                ),
                hSizedBox20,
                CustomTextFormField(
                  controller: numberController,
                  hintText: "Phone number",
                ),
                hSizedBox20,
                CustomTextFormField(
                  controller: addressController,
                  hintText: "Address",
                  minLines: 1,
                  maxLines: 3,
                ),
                hSizedBox20,
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: themeColorGreen),
                      borderRadius: BorderRadius.circular(20)),
                  child: Tooltip(
                    message: "Pick DOB",
                    child: CupertinoButton(
                      child: Text(
                        datetime != null
                            ? '${datetime!.day}-${datetime!.month}-${datetime!.year}'
                            : "DOB",
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => SizedBox(
                            height: 250,
                            child: CupertinoTheme(
                              data: const CupertinoThemeData(
                                  brightness: Brightness.dark),
                              child: CupertinoDatePicker(
                                backgroundColor: themeColorGrey,
                                onDateTimeChanged: (newTime) => setState(() {
                                  datetime = newTime;
                                }),
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: datetime,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                hSizedBox30,
                CustomElevatedButton(text: "Save", onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
