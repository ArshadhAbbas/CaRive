import 'dart:io';

import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/cars_list.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/custom_text_form_field.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  String? selectedCarModel;
  String? selectedMake;
  String? selectedFuel;
  String? selectedSeatCapacity;

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController modelYearController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController addInfoController = TextEditingController();

  AuthService auth = AuthService();
  final CarService carService = CarService();
  @override
  void dispose() {
    carService.dispose();
    modelYearController.dispose();
    amountController.dispose();
    locationController.dispose();
    addInfoController.dispose();
    super.dispose();
  }

  onCarModelChanged(String? value) {
    // Don't change the second dropdown if the first item didn't change
    if (value != selectedMake) selectedCarModel = null;
    setState(() {
      selectedMake = value;
    });
  }

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
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Add New Car"),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    StreamBuilder<File?>(
                      stream: carService.selectedImageStream,
                      builder: (context, snapshot) {
                        final File? selectedImage = snapshot.data;
                        return selectedImage == null
                            ? GestureDetector(
                                onTap: () async {
                                  await carService
                                      .getImage(ImageSource.gallery);
                                },
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white60.withOpacity(0.13),
                                        Colors.white10,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () async {
                                  await carService
                                      .getImage(ImageSource.gallery);
                                },
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white60.withOpacity(0.13),
                                        Colors.white10,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Image(
                                    image: FileImage(selectedImage),
                                    fit: BoxFit.cover,
                                  ),
                                ));
                      },
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColorGreen),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String?>(
                            validator: (value) =>
                                value == null ? "Field required" : null,
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                            icon: Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward),
                            ),
                            dropdownColor: themeColorGrey,
                            style: TextStyle(color: Colors.white),
                            hint: Center(
                              child: Text(
                                'Select Car Brand',
                                style: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                            value: selectedMake,
                            items: carDataset.keys.map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text(e)),
                              );
                            }).toList(),
                            onChanged: onCarModelChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColorGreen),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String?>(
                            validator: (value) =>
                                value == null ? "Field required" : null,
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                            icon: Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward),
                            ),
                            dropdownColor: themeColorGrey,
                            style: TextStyle(color: Colors.white),
                            value: selectedCarModel,
                            hint: Center(
                              child: Text(
                                'Select Car Model',
                                style: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                            items: (carDataset[selectedMake] ?? []).map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text('$e')),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCarModel = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColorGreen),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String?>(
                            validator: (value) =>
                                value == null ? "Field required" : null,
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                            icon: Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward),
                            ),
                            dropdownColor: themeColorGrey,
                            style: TextStyle(color: Colors.white),
                            value: selectedFuel,
                            hint: Center(
                              child: Text(
                                'Select Fuel type',
                                style: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                            items: fuelType.map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text('$e')),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedFuel = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColorGreen),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String?>(
                            validator: (value) =>
                                value == null ? "Field required" : null,
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                            icon: Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward),
                            ),
                            dropdownColor: themeColorGrey,
                            style: TextStyle(color: Colors.white),
                            value: selectedSeatCapacity,
                            hint: Center(
                              child: Text(
                                'Select Seat Capacity',
                                style: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                            items: seatCapacity.map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text('$e')),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedSeatCapacity = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    hSizedBox20,
                    CustomTextFormField(
                      controller: modelYearController,
                      hintText: "Enter Model Year",
                      validator: (value) =>
                          value == null ? "Enter Model Year" : null,
                    ),
                    hSizedBox20,
                    TextFormField(
                      validator: (value) =>
                          value == null ? "Enter amount" : null,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        hintStyle: TextStyle(color: themeColorblueGrey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: themeColorGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: themeColorGreen),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            '₹/Day',
                            style: TextStyle(
                                color: themeColorblueGrey, fontSize: 20),
                          ),
                        ),
                      ),
                      controller: amountController,
                    ),
                    hSizedBox20,
                    CustomTextFormField(
                      controller: locationController,
                      hintText: "Enter location details",
                    ),
                    hSizedBox20,
                    isLoading
                        ? CircularProgressIndicator(
                            color: themeColorGreen,
                          )
                        : CustomElevatedButton(
                            text: "Post",
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScopeNode currentfocus = FocusScope.of(
                                    context); //get the currnet focus node
                                if (!currentfocus.hasPrimaryFocus) {
                                  //prevent Flutter from throwing an exception
                                  currentfocus
                                      .unfocus(); //unfocust from current focust, so that keyboard will dismiss
                                }
                                setState(() {
                                  isLoading = true;
                                });
                                await carService.postNewCar(
                                    uid: auth.auth.currentUser!.uid,
                                    carModel: selectedCarModel!,
                                    make: selectedMake!,
                                    fuelType: selectedFuel!,
                                    seatCapacity: selectedSeatCapacity!,
                                    modelYear: modelYearController.text,
                                    amount: amountController.text,
                                    location: locationController.text,
                                    additionalInfo: addInfoController.text,
                                    isAvailable: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Center(
                                        child: Text('New car has been posted')),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            // style: ButtonStyle(
                            //   shape: MaterialStateProperty.all<
                            //       RoundedRectangleBorder>(
                            //     RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(20),
                            //     ),
                            //   ),
                            //   backgroundColor: MaterialStateProperty.all(
                            //       const Color(0xFF198396)),
                            // ),
                            // child: Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 150),
                            //   child: Text("Post"),
                            // ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
