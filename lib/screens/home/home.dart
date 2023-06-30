import 'package:carive/models/car_model.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:carive/shared/transluscent_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../shared/circular_progress_indicator.dart';
import '../host/new_post/location__selection_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService auth = AuthService();
  final CarService carService = CarService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: carService.car,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }

        final List<CarModel> cars = snapshot.data!.docs
            .map((doc) => CarModel.fromSnapshot(doc))
            .toList();

        return CustomScaffold(
          child: SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/map-marker.png',
                                width: 20,
                              ),
                              wSizedBox10,
                              Text("Place",
                                  style: TextStyle(
                                      color: themeColorGreen, fontSize: 18))
                            ],
                          ),
                        ],
                      ),
                      hSizedBox20,
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      BorderSide(color: themeColorGreen),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      BorderSide(color: themeColorGreen),
                                ),
                                hintText: "Search for Location",
                                hintStyle: TextStyle(color: themeColorblueGrey),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.filter_alt_outlined,
                              color: themeColorGreen,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      hSizedBox20,
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: cars.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return TransluscentCard(
                            latitude: cars[index].latitude,
                            longitude: cars[index].longitude,
                            carId: cars[index].carId!,
                            image: cars[index].imageUrl,
                            brand: cars[index].make,
                            model: cars[index].carModel,
                            location: cars[index].location,
                            price: cars[index].amount,
                            fuelType: cars[index].fuelType,
                            modelYear: cars[index].modelYear,
                            seatCapacity: cars[index].seatCapacity,
                            ownerId: cars[index].userId,
                            isAvailable: cars[index].isAvailable,
                            ownerFcmToken: cars[index].ownerFcmToken,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
