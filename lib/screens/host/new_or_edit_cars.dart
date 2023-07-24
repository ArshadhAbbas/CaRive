// ignore_for_file: prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'dart:io';
import 'dart:ui';

import 'package:carive/providers/add_car_provider.dart';
import 'package:carive/screens/host/location__selection_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/cars_list.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../shared/circular_progress_indicator.dart';
import '../../../shared/custom_text_form_field.dart';

enum ActionType {
  addNewCar,
  editCar,
}

// ignore: must_be_immutable
class NewOrEditCarScreen extends StatefulWidget {
  final ActionType actionType;
  final String? carId;
  String? selectedCarModel;
  String? selectedMake;
  String? selectedFuel;
  String? selectedSeatCapacity;
  final String? modelYear;
  final int? amount;
  final String? location;
  final String? image;
  final double? latitude;
  final double? longitude;
  bool? isAvailable;

  NewOrEditCarScreen({
    required this.actionType,
    this.carId,
    this.selectedCarModel,
    this.selectedMake,
    this.selectedFuel,
    this.selectedSeatCapacity,
    this.modelYear,
    this.amount,
    this.location,
    this.image,
    this.latitude,
    this.longitude,
    this.isAvailable,
  });

  @override
  State<NewOrEditCarScreen> createState() => _NewOrEditCarScreenState();
}

class _NewOrEditCarScreenState extends State<NewOrEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController modelYearController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  // String? photo;
  // late LatLng selectedLocation;
  // String? address;
  AuthService auth = AuthService();
  final CarService carService = CarService();
  bool hasSelectedImage = false;

  @override
  void initState() {
    super.initState();
    modelYearController.text = widget.modelYear ?? '';
    amountController.text = widget.amount?.toString() ?? '';
    // photo = null;
    if (widget.actionType == ActionType.editCar) {
      context.read<AddCarProvider>().selectedCarModel =
          widget.selectedCarModel ?? '';
      context.read<AddCarProvider>().selectedMake = widget.selectedMake ?? '';
      context.read<AddCarProvider>().selectedFuel = widget.selectedFuel ?? '';
      context.read<AddCarProvider>().selectedSeatCapacity =
          widget.selectedSeatCapacity ?? '';
      context.read<AddCarProvider>().address = widget.location;
      context.read<AddCarProvider>().isAvailable = widget.isAvailable ?? true;
      if (widget.latitude != null && widget.longitude != null) {
        context.read<AddCarProvider>().selectedLocation =
            LatLng(widget.latitude!, widget.longitude!);
      }
    }

    if (widget.actionType == ActionType.addNewCar) {
      context.read<AddCarProvider>().selectedCarModel = null;
      context.read<AddCarProvider>().selectedMake = null;
      context.read<AddCarProvider>().selectedFuel = null;
      context.read<AddCarProvider>().selectedSeatCapacity = null;
      context.read<AddCarProvider>().address = null;
      context.read<AddCarProvider>().selectedLocation = null;
    }
  }

  @override
  void dispose() {
    carService.dispose();
    modelYearController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddCarProvider addCarProvider = Provider.of<AddCarProvider>(context);
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
            title: widget.actionType == ActionType.addNewCar
                ? const Text("Add New Car")
                : const Text("Update Car"),
            centerTitle: false,
            actions: [
              if (widget.actionType == ActionType.editCar)
                IconButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CustomProgressIndicator(),
                        );
                      },
                    );
                    try {
                      await carService.deleteCar(
                          widget.carId!, auth.auth.currentUser!.uid);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
            ],
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
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.actionType == ActionType.editCar
                                  ? selectedImage != null
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
                                                  Colors.white60
                                                      .withOpacity(0.25),
                                                  Colors.white10,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: Image(
                                              image: NetworkImage(
                                                widget.image ?? '',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                  : selectedImage == null
                                      ? GestureDetector(
                                          onTap: () async {
                                            await carService
                                                .getImage(ImageSource.gallery);
                                          },
                                          child: Container(
                                            height: 200,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white60
                                                      .withOpacity(0.13),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image(
                                              image: FileImage(selectedImage),
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: 200,
                                            ),
                                          ),
                                        ),
                            ),
                            Visibility(
                              visible: widget.actionType == ActionType.editCar,
                              child: Positioned(
                                bottom: 0,
                                right: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: themeColorGreen,
                                    child: IconButton(
                                      onPressed: () {
                                        carService.getImage(
                                          ImageSource.gallery,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                    child: Consumer<AddCarProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: DropdownButtonFormField<String?>(
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
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
                            value: provider.selectedMake,
                            items: carDataset.keys.map((e) {
                              return DropdownMenuItem<String?>(
                                value: e,
                                child: Center(child: Text(e)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              provider.carMakeChanged(val);
                            },
                          ),
                        );
                      },
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
                    child: Consumer<AddCarProvider>(
                        builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
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
                          value: provider.selectedCarModel,
                          items: (carDataset[provider.selectedMake] ?? [])
                              .map((e) {
                            return DropdownMenuItem<String?>(
                              value: e,
                              child: Center(child: Text(e)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            provider.setSelectedCarModel(val);
                          },
                        ),
                      );
                    }),
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
                    child: Consumer<AddCarProvider>(
                        builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
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
                          value: provider.selectedFuel,
                          items: fuelType.map((e) {
                            return DropdownMenuItem<String?>(
                              value: e,
                              child: Center(child: Text(e)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            provider.setSelectedFuel(val);
                          },
                        ),
                      );
                    }),
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
                    child: Consumer<AddCarProvider>(
                        builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
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
                          value: provider.selectedSeatCapacity,
                          items: seatCapacity.map((e) {
                            return DropdownMenuItem<String?>(
                              value: e,
                              child: Center(child: Text(e)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            provider.setSelectedSeatCapacity(val);
                          },
                        ),
                      );
                    }),
                  ),
                  hSizedBox20,
                  Text(
                    "Make Year",
                    style: TextStyle(
                      color: themeColorblueGrey,
                      fontSize: 18,
                    ),
                  ),
                  hSizedBox10,
                  CustomTextFormField(
                    keyBoardType: TextInputType.number,
                    controller: modelYearController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Model year";
                      }
                      return null;
                    },
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
                     validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Amount";
                      }
                      return null;
                    },
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
                          backgroundColor: Colors.transparent),
                      onPressed: () async {
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
                          addCarProvider.setAddress(
                              "${placemark[0].subLocality!} ${placemark[0].locality!} ${placemark[0].country!}");
                          addCarProvider.setSelectedLocation(selectedLatLng);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                addCarProvider.address ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  hSizedBox10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        fillColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                        value: true,
                        groupValue: addCarProvider.isAvailable,
                        onChanged: (value) {
                          context.read<AddCarProvider>().setIsAvailable(value);
                        },
                      ),
                      const Text(
                        "Available",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      Radio(
                        fillColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                        value: false,
                        groupValue: addCarProvider.isAvailable,
                        onChanged: (value) {
                          context.read<AddCarProvider>().setIsAvailable(value);
                        },
                      ),
                      const Text("Unavailable",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  hSizedBox20,
                  Center(
                    child: CustomElevatedButton(
                      text: widget.actionType == ActionType.addNewCar
                          ? "Add Car"
                          : "Update details",
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (!hasSelectedImage &&
                              widget.actionType == ActionType.addNewCar) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                    child: Text('Please select an image')),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          if (addCarProvider.selectedLocation == null) {
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
                            builder: (context) => const Center(
                              child: CustomProgressIndicator(),
                            ),
                          );
                          final addCarProviderListenFalsed = Provider.of<AddCarProvider>(
                              context,
                              listen: false);
                          if (widget.actionType == ActionType.addNewCar) {
                            // Add new car
                            await carService.postNewCar(
                              ownerFcmToken: fcmToken!,
                              uid: auth.auth.currentUser!.uid,
                              carModel: addCarProviderListenFalsed.selectedCarModel!,
                              make: addCarProviderListenFalsed.selectedMake!,
                              fuelType: addCarProviderListenFalsed.selectedFuel!,
                              seatCapacity:
                                  addCarProviderListenFalsed.selectedSeatCapacity!,
                              modelYear: modelYearController.text,
                              amount: int.parse(amountController.text),
                              location: addCarProviderListenFalsed.address!,
                              latitude:
                                  addCarProviderListenFalsed.selectedLocation!.latitude,
                              longitude:
                                  addCarProviderListenFalsed.selectedLocation!.longitude,
                              isAvailable: addCarProviderListenFalsed.isAvailable ?? true,
                            );
                          } else if (widget.actionType == ActionType.editCar) {
                            await carService.updateCarDetails(
                              carId: widget.carId!,
                              carModel: addCarProviderListenFalsed.selectedCarModel!,
                              make: addCarProviderListenFalsed.selectedMake!,
                              fuelType: addCarProviderListenFalsed.selectedFuel!,
                              seatCapacity:
                                  addCarProviderListenFalsed.selectedSeatCapacity!,
                              modelYear: modelYearController.text,
                              amount: int.parse(amountController.text),
                              location: addCarProviderListenFalsed.address!,
                              latitude:
                                  addCarProviderListenFalsed.selectedLocation!.latitude,
                              longitude:
                                  addCarProviderListenFalsed.selectedLocation!.longitude,
                              isAvailable: addCarProviderListenFalsed.isAvailable!,
                            );
                          }
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
