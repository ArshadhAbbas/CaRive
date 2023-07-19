// ignore_for_file: use_build_context_synchronously

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
import 'package:geocoding/geocoding.dart';
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

  final _formKey = GlobalKey<FormState>();

  TextEditingController modelYearController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController addInfoController = TextEditingController();
  LatLng? selectedLocation;
  String? address;
  bool hasSelectedImage = false;

  AuthService auth = AuthService();
  final CarService carService = CarService();
  @override
  void dispose() {
    carService.dispose();
    modelYearController.dispose();
    amountController.dispose();
    super.dispose();
  }

  onCarModelChanged(String? value) {
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
                        hasSelectedImage = selectedImage != null;
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image(
                                    image: FileImage(selectedImage),
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: 200,
                                  ),
                                ),
                              );
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
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                        ),
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
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                        ),
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
                            child: Center(child: Text(e)),
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
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                        ),
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
                            child: Center(child: Text(e)),
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
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                        ),
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
                            child: Center(child: Text(e)),
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
                    keyBoardType: TextInputType.number,
                    controller: modelYearController,
                    validator: (value) =>
                        value == null ? "Enter Model Year" : null,
                    length: 4,
                  ),
                  Text(
                    "Amount Per Day",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  CustomTextFormField(
                    keyBoardType: TextInputType.number,
                    length: 4,
                    controller: amountController,
                    validator: (value) => value == null ? "Enter amount" : null,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        '₹/Day',
                        style:
                            TextStyle(color: themeColorblueGrey, fontSize: 12),
                      ),
                    ),
                  ),
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: themeColorGreen),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () async {
                        dismissKeyboard(context);
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
                          List<Placemark> placemark =
                              await placemarkFromCoordinates(
                                  selectedLatLng.latitude,
                                  selectedLatLng.longitude);
                          setState(() {
                            address =
                                "${placemark[0].subLocality!} ${placemark[0].locality!} ${placemark[0].country!}";
                            selectedLocation = selectedLatLng;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: selectedLocation == null
                              ? const Center(
                                  child: Text("Choose Location"),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(address!, textAlign: TextAlign.center)
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  hSizedBox20,
                  Center(
                    child: CustomElevatedButton(
                      text: "Post",
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (!hasSelectedImage) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                    child: Text('Please select an image')),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          if (selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                    child: Text('Please select a location')),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          dismissKeyboard(context);

                          final fcmToken =
                              await FirebaseMessaging.instance.getToken();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: CustomProgressIndicator(),
                            ),
                          );
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
                            amount: int.parse(amountController.text),
                            location: address!,
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
                          Navigator.of(context).pop();
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
