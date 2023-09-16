import 'dart:ui';

import 'package:carive/screens/host/new_or_edit_cars_screen/new_or_edit_cars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:carive/services/auth.dart';
import 'package:carive/shared/constants.dart';
import 'package:lottie/lottie.dart';
import '../../../models/car_model.dart';
import '../../../shared/circular_progress_indicator.dart';

class HostYourCars extends StatefulWidget {
  const HostYourCars({Key? key}) : super(key: key);

  @override
  State<HostYourCars> createState() => _HostYourCarsState();
}

class _HostYourCarsState extends State<HostYourCars> {
  AuthService auth = AuthService();

  late String userId;
  @override
  void initState() {
    super.initState();
    userId = auth.auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!.data() as Map<String, dynamic>;
            final List<String> postIds = List<String>.from(user['posts'] ?? []);

            if (postIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/animation_lkgtfp7w.json',
                        height: MediaQuery.of(context).size.height / 2),
                    const Text(
                      'No Cars Available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .where('carId', whereIn: postIds)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final cars = snapshot.data!.docs;

                  if (cars.isEmpty) {
                    return const Center(
                      child: Text(
                        'No cars available.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 20),
                      itemCount: cars.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final car = CarModel.fromSnapshot(cars[index]);

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return NewOrEditCarScreen(
                                actionType: ActionType.editCar,
                                isAvailable: car.isAvailable,
                                latitude: car.latitude,
                                longitude: car.longitude,
                                carId: car.carId,
                                selectedCarModel: car.carModel,
                                selectedMake: car.make,
                                selectedFuel: car.fuelType,
                                selectedSeatCapacity: car.seatCapacity,
                                modelYear: car.modelYear,
                                amount: car.amount,
                                location: car.location,
                                image: car.imageUrl,
                              );
                            }));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        Colors.white60.withOpacity(0.13),
                                        Colors.white10
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomCenter),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        // height: 130,
                                        // width: 170,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            car.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              car.carModel,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: 10,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        car.isAvailable
                                                            ? Colors.green
                                                            : Colors.red,
                                                  )),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                car.isAvailable
                                                    ? "Available"
                                                    : "Unavailable",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/map-marker.png',
                                            width: 15,
                                          ),
                                          wSizedBox10,
                                          Expanded(
                                            child: Text(
                                              car.location,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "₹${car.amount}",
                                                  style: TextStyle(
                                                      color: themeColorGreen),
                                                ),
                                                const Text(
                                                  "/day",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error fetching car data.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return const CustomProgressIndicator();
                }
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error fetching user data.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return const CustomProgressIndicator();
          }
        },
      ),
    );
  }
}
