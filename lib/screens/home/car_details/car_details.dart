import 'package:carive/screens/host/edit_cars/edit_cars.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;

import '../../../services/notification_service.dart';
import '../../../shared/circular_progress_indicator.dart';

// ignore: must_be_immutable
class CarDetails extends StatefulWidget {
  CarDetails(
      {super.key,
      required this.carId,
      required this.brand,
      required this.model,
      required this.price,
      required this.location,
      required this.image,
      required this.modelYear,
      required this.seatCapacity,
      required this.fuelType,
      required this.ownerId,
      required this.latitude,
      required this.longitude,
      required this.ownerFcmToken,
      required this.isAvailable});
  String carId;
  String brand;
  String model;
  String price;
  String location;
  String image;
  String fuelType;
  String modelYear;
  String seatCapacity;
  String ownerId;
  bool isAvailable;
  String ownerFcmToken;
  double latitude;
  double longitude;

  DateTime? start;
  DateTime? end;

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final notificationService = NotificationService();
  final userDatabaseService = UserDatabaseService();

  _mapLauncher(location) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: launcher.Coords(location.latitude, location.longitude),
      title: "Car Location",
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userDatabaseService.getUserData(widget.ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              'User profile has been deleted',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return CustomScaffold(
          child: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    widget.image,
                    height: MediaQuery.of(context).size.height / 2,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF3E515F),
                    child:
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  maxChildSize: 0.8,
                  minChildSize: 0.6,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        decoration: BoxDecoration(
                            color: themeColorGrey,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        clipBehavior: Clip.hardEdge,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 66, 66, 66),
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                              hSizedBox10,
                              Text(
                                "${widget.brand} ${widget.model}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                              hSizedBox10,
                              Text(
                                "₹${widget.price}/Day",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      hSizedBox10,
                                      Text(
                                        widget.location,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        widget.isAvailable
                                            ? "Available"
                                            : "Unavailable",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Seat Capacity : ${widget.seatCapacity}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        "Fuel Type : ${widget.fuelType}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        "Model Year : ${widget.modelYear}",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              hSizedBox20,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Owner Info",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                  hSizedBox10,
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: themeColorGreen),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                "${userData['image']}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          wSizedBox10,
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${userData['name']}",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "${userData['address']}",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "${userData['phone_number']}",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.message_rounded,
                                            color: Colors.white,
                                            size: 60,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  hSizedBox20,
                                  GestureDetector(
                                    onTap: () async {
                                      _mapLauncher(LatLng(
                                          widget.latitude, widget.longitude));
                                    },
                                    child: Container(
                                      height: 300,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: themeColorGreen),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: GoogleMap(
                                            markers: {
                                              Marker(
                                                markerId: const MarkerId(
                                                    'carLocation'),
                                                position: LatLng(
                                                    widget.latitude,
                                                    widget.longitude),
                                              ),
                                            },
                                            initialCameraPosition:
                                                CameraPosition(
                                                    target: LatLng(
                                                        widget.latitude,
                                                        widget.longitude),
                                                    zoom: 8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              hSizedBox10,
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    widget.isAvailable
                                        ? bookingDialogueBox()
                                        : null;
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    backgroundColor: widget.isAvailable
                                        ? MaterialStateProperty.all(
                                            const Color(0xFF198396))
                                        : MaterialStateProperty.all(
                                            Color.fromARGB(255, 110, 128, 131)),
                                  ),
                                  child: Text(
                                    "Book Now",
                                    style: TextStyle(
                                        color: widget.isAvailable
                                            ? Colors.white
                                            : Colors.grey),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

//
//
//
//
//
//
//

  Future<dynamic> bookingDialogueBox() {
    widget.start = null;
    widget.end = null;
    return showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(builder: (context1, setState) {
          return AlertDialog(
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: const TextStyle(color: Colors.white),
            backgroundColor: themeColorGrey,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColorGreen),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  customDateRangePicker(context, setState);
                },
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: widget.start == null
                      ? const Text("Select Date Range")
                      : Text(
                          '${widget.start != null ? DateFormat("dd/MMM/yyyy").format(widget.start!) : '-'} - ${widget.end != null ? DateFormat("dd/MMM/yyyy").format(widget.end!) : '-'}',
                        ),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CustomElevatedButton(
                text: "Book Now",
                onPressed: widget.start != null
                    ? () async {
                        try {
                          final currentUserId = _auth.currentUser!.uid;
                          final currentUserName = await userDatabaseService
                              .getCurrentUserName(currentUserId);
                          Navigator.of(context).pop(); // Close the dialog

                          if (currentUserName == '') {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: themeColorGrey,
                                  title: const Text(
                                    'Create Profile',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Please create a profile to create a booking.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    CustomElevatedButton(
                                      text: "OK",
                                      paddingHorizontal: 3,
                                      paddingVertical: 3,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            final carModel = '${widget.brand} ${widget.model}';
                            await notificationService.sendNotificationToOwner(
                                currentUserId,
                                widget.ownerFcmToken,
                                currentUserName,
                                widget.ownerId,
                                carModel,
                                widget.price,
                                widget.start!,
                                widget.end!);
                            showSnackbar(
                                "Booking request has sent to the owner, Please wait for the response");
                          }
                        } catch (e) {
                          showSnackbar(
                              "Could not send request. Try after some time");
                          print(e.toString());
                        }
                      }
                    : () {
                        showSnackbar("Select Date range");
                      },
                paddingHorizontal: 8,
                paddingVertical: 8,
              ),
            ],
          );
        });
      },
    );
  }

  void customDateRangePicker(BuildContext context, StateSetter setState) {
    return showCustomDateRangePicker(context,
        dismissible: true,
        minimumDate: DateTime.now(),
        maximumDate: DateTime(2030),
        backgroundColor: themeColorGrey,
        startDate: widget.start,
        endDate: widget.end, onApplyClick: (startDate, endDate) {
      setState(() {
        widget.start = startDate;
        widget.end = endDate;
      });
    }, onCancelClick: () {
      Navigator.pop(context);
    }, primaryColor: Colors.blue);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
