import 'package:carive/screens/host/edit_cars/edit_cars.dart';
import 'package:carive/services/user_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../services/notification_service.dart';

class CarDetails extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final notificationService = NotificationService();

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
      required this.ownerId});
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
  final userDatabaseService = UserDatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userDatabaseService.getUserData(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: themeColorGreen,
          ));
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
        final user = _auth.currentUser;
        final isCurrentUserOwner = user != null && user.uid == ownerId;
        return CustomScaffold(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF3E515F),
                  child:
                      Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: false,
            ),
            body: Stack(
              children: [
                Image.network(
                  image,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    hSizedBox10,
                                    Text(
                                      "$brand $model",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 30),
                                    ),
                                    hSizedBox10,
                                    Text(
                                      "₹$price/Day",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 30),
                                    ),
                                    hSizedBox10,
                                    Text(
                                      location,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    hSizedBox10,
                                    const Text(
                                      "Available",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Seat Capacity : $seatCapacity",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    hSizedBox10,
                                    Text(
                                      "Fuel Type : $fuelType",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    hSizedBox10,
                                    Text(
                                      "Model Year : $modelYear",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            hSizedBox20,
                            if (!isCurrentUserOwner)
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
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22),
                                              ),
                                              Spacer(),
                                              Text(
                                                "${userData['address']}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Spacer(),
                                              Text(
                                                "${userData['phone_number']}",
                                                style: TextStyle(
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
                                  Container(
                                    height: 300,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: themeColorGreen),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Center(
                                        child: Text(
                                      "Location",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  ),
                                ],
                              ),
                            hSizedBox10,
                            if (!isCurrentUserOwner)
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final ownerFCMToken =
                                          await FirebaseFirestore.instance
                                              .collection('FCMTokens')
                                              .doc(ownerId)
                                              .get()
                                              .then((snapshot) =>
                                                  snapshot.data()?['fcmToken']
                                                      as String);
                                      final currentUserName =
                                          await userDatabaseService
                                              .getCurrentUserName(
                                                  _auth.currentUser!.uid);
                                      await notificationService
                                          .sendNotificationToOwner(
                                              ownerFCMToken, currentUserName);
                                    } catch (e) {
                                      print(e.toString());
                                    }
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFF198396)),
                                  ),
                                  child: const Text("Book Now"),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return EditCarScreen(
                                        carId: carId,
                                        selectedCarModel: model,
                                        selectedMake: brand,
                                        selectedFuel: fuelType,
                                        selectedSeatCapacity: seatCapacity,
                                        modelYear: modelYear,
                                        amount: price,
                                        location: location,
                                        image: image,
                                      );
                                    }));
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFF198396)),
                                  ),
                                  child: const Text("Edit Details"),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
