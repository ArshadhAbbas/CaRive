import 'dart:io';
import 'dart:ui';

import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/cars_list.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/custom_text_form_field.dart';

class EditCarScreen extends StatefulWidget {
  String carId;
  String? selectedCarModel;
  String selectedMake;
  String selectedFuel;
  String selectedSeatCapacity;
  final String modelYear;
  final String amount;
  final String location;
  final String image;

  EditCarScreen({
    required this.carId,
    required this.selectedCarModel,
    required this.selectedMake,
    required this.selectedFuel,
    required this.selectedSeatCapacity,
    required this.modelYear,
    required this.amount,
    required this.location,
    required this.image,
  });

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController modelYearController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController addInfoController = TextEditingController();
  String? photo;

  AuthService auth = AuthService();
  final CarService carService = CarService();

  @override
  void initState() {
    super.initState();
    modelYearController.text = widget.modelYear;
    amountController.text = widget.amount;
    locationController.text = widget.location;
    photo = null;
  }

  @override
  void dispose() {
    carService.dispose();
    modelYearController.dispose();
    amountController.dispose();
    locationController.dispose();
    addInfoController.dispose();
    super.dispose();
  }

  void onCarModelChanged(String? value) {
    if (value != widget.selectedMake) {
      setState(() {
        widget.selectedMake = value!;
        widget.selectedCarModel = null; // Reset selected car model
      });
    }
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
            title: const Text("Update Car"),
            centerTitle: false,
            actions: [
              IconButton(
                  onPressed: () {
                    carService.deleteCar(widget.carId);
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.delete))
            ],
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
                                    carService.getImage(
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
                            value: widget.selectedMake,
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
                            value: widget.selectedCarModel != null
                                ? widget.selectedCarModel
                                : null,
                            hint: Center(
                              child: Text(
                                'Select Car Model',
                                style: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                            items: (carDataset[widget.selectedMake] ?? [])
                                .map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text('$e')),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                widget.selectedCarModel = val!;
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
                            value: widget.selectedFuel,
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
                                widget.selectedFuel = val!;
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
                            value: widget.selectedSeatCapacity,
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
                                widget.selectedSeatCapacity = val!;
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
                            text: "Update details",
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

                                await carService.updateCarDetails(
                                  carId: widget
                                      .carId, // Pass the car ID of the car being edited
                                  carModel: widget.selectedCarModel!,
                                  make: widget.selectedMake,
                                  fuelType: widget.selectedFuel,
                                  seatCapacity: widget.selectedSeatCapacity,
                                  modelYear: modelYearController.text,
                                  amount: amountController.text,
                                  location: locationController.text,
                                );

                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
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
