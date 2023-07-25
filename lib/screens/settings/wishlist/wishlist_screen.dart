// ignore_for_file: use_build_context_synchronously

import 'package:carive/screens/home/car_details/car_details.dart';
import 'package:carive/services/wishlist_service.dart';
import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum MenuItem { open, remove }

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final wishListService = WishListService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!.data() as Map<String, dynamic>;
          final List<String> wishListedCarsIds =
              List<String>.from(user['wishlistedCars'] ?? []);

          if (wishListedCarsIds.isEmpty) {
            return CustomScaffold(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF3E515F),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: const Text("WishList"),
                  centerTitle: false,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/animation_lkgtfp7w.json',
                          height: MediaQuery.of(context).size.height / 3),
                      const Text(
                        'No Cars in the wish list.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cars')
                .where('carId', whereIn: wishListedCarsIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final cars = snapshot.data!.docs;
                if (cars.isEmpty) {
                  return CustomScaffold(
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF3E515F),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        title: const Text("WishList"),
                        centerTitle: false,
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/animation_lkgtfp7w.json',),
                                // height: MediaQuery.of(context).size.height / 1),
                            const Text(
                              'No Cars in the wish list.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return CustomScaffold(
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF3E515F),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text("WishList"),
                      centerTitle: false,
                    ),
                    body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              final car =
                                  cars[index].data() as Map<String, dynamic>;
                              final carId = car['carId'];
                              final carName = car['carModel'];
                              final carImage = car['imageUrl'];
                              final carLocation = car['location'];
                              final carMake = car['make'];
                              final fuelType = car['fuelType'];
                              final seatCapacity = car['seatCapacity'];
                              final modelYear = car['modelYear'];
                              final location = car['location'];
                              final amount = car['amount'];
                              final latitude = car['latitude'];
                              final longitude = car['longitude'];
                              final isAvailable = car['isAvailable'];
                              final ownerId = car['userId'];
                              final ownerFcmToken = car['ownerFcmToken'];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(carImage),
                                ),
                                title: Text(
                                  "$carMake $carName",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "$carLocation",
                                  style: TextStyle(color: themeColorblueGrey),
                                ),
                                trailing: PopupMenuButton<MenuItem>(
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == MenuItem.open) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => CarDetails(
                                            latitude: latitude,
                                            longitude: longitude,
                                            carId: carId,
                                            brand: carMake,
                                            image: carImage,
                                            location: location,
                                            model: carName,
                                            price: amount,
                                            modelYear: modelYear,
                                            seatCapacity: seatCapacity,
                                            fuelType: fuelType,
                                            ownerId: ownerId,
                                            isAvailable: isAvailable,
                                            ownerFcmToken: ownerFcmToken),
                                      ));
                                    } else if (value == MenuItem.remove) {
                                      await wishListService.removeFromWishList(
                                          _auth.currentUser!.uid, carId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Car has been removed from wishlist.'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<MenuItem>(
                                      value: MenuItem.open,
                                      child: Text('Open'),
                                    ),
                                    const PopupMenuItem<MenuItem>(
                                      value: MenuItem.remove,
                                      child: Text('Remove from wishlist'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(),
                            itemCount: cars.length)),
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
    );
  }
}
