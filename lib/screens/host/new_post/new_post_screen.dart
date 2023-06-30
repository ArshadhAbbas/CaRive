import 'dart:io';

import 'package:carive/screens/host/new_post/location__selection_screen.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/cars_list.dart';
import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  LatLng? selectedLocation;

  AuthService auth = AuthService();
  final CarService carService = CarService();
  @override
  void dispose() {
    carService.dispose();
    modelYearController.dispose();
    amountController.dispose();
    locationController.dispose();
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: StreamBuilder<File?>(
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
                                  child: const Icon(
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Car Brand",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
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
                          icon: const Visibility(
                            visible: false,
                            child: Icon(Icons.arrow_downward),
                          ),
                          dropdownColor: themeColorGrey,
                          style: const TextStyle(color: Colors.white),
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
                  Text(
                    "Car Model",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
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
                          icon: const Visibility(
                            visible: false,
                            child: Icon(Icons.arrow_downward),
                          ),
                          dropdownColor: themeColorGrey,
                          style: const TextStyle(color: Colors.white),
                          value: selectedCarModel,
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
                  Text(
                    "Fuel Type",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
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
                          icon: const Visibility(
                            visible: false,
                            child: Icon(Icons.arrow_downward),
                          ),
                          dropdownColor: themeColorGrey,
                          style: const TextStyle(color: Colors.white),
                          value: selectedFuel,
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
                  Text(
                    "Seat Capacity",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
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
                          icon: const Visibility(
                            visible: false,
                            child: Icon(Icons.arrow_downward),
                          ),
                          dropdownColor: themeColorGrey,
                          style: const TextStyle(color: Colors.white),
                          value: selectedSeatCapacity,
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
                  Text(
                    "Make year",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  CustomTextFormField(
                    controller: modelYearController,
                    validator: (value) =>
                        value == null ? "Enter Model Year" : null,
                  ),
                  hSizedBox20,
                  Text(
                    "Amount Per Day",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  TextFormField(
                    validator: (value) => value == null ? "Enter amount" : null,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
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
                  Text(
                    "Location Name",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  CustomTextFormField(
                    controller: locationController,
                  ),
                  hSizedBox20,
                  Text(
                    "Location",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: themeColorGreen),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () async {
                        FocusScopeNode currentfocus = FocusScope.of(context);
                        if (!currentfocus.hasPrimaryFocus) {
                          currentfocus.unfocus();
                        }
                        final selectedLatLng = await Navigator.push<LatLng>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationSelectionScreen(
                              onLocationSelected: (LatLng selectedLatLng) {
                                Navigator.pop(context, selectedLatLng);
                              },
                            ),
                          ),
                        );

                        if (selectedLatLng != null) {
                          setState(() {
                            selectedLocation = selectedLatLng;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: selectedLocation == null
                              ? const Center(
                                  child: Text("Choose Location"),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Latitude: ${selectedLocation!.latitude}',
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Longitude: ${selectedLocation!.longitude}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  hSizedBox20,
                  isLoading
                      ? const CustomProgressIndicator()
                      : Center(
                        child: CustomElevatedButton(
                            text: "Post",
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (selectedLocation == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Center(
                                          child:
                                              Text('Please select a location')),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }
                      
                                FocusScopeNode currentfocus =
                                    FocusScope.of(context);
                                if (!currentfocus.hasPrimaryFocus) {
                                  currentfocus.unfocus();
                                }
                      
                                setState(() {
                                  isLoading = true;
                                });
                                final fcmToken =
                                    await FirebaseMessaging.instance.getToken();
                                print("FCM:$fcmToken");
                                await carService.postNewCar(
                                  latitude: selectedLocation!.latitude,
                                  longitude: selectedLocation!.longitude,
                                  ownerFcmToken: fcmToken!,
                                  uid: auth.auth.currentUser!.uid,
                                  carModel: selectedCarModel!,
                                  make: selectedMake!,
                                  fuelType: selectedFuel!,
                                  seatCapacity: selectedSeatCapacity!,
                                  modelYear: modelYearController.text,
                                  amount: amountController.text,
                                  location: locationController.text,
                                  isAvailable: true,
                                );
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
                          ),
                      )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
