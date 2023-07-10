import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:carive/models/car_model.dart';
import 'package:carive/screens/home/search_screen/search_screen.dart';
import 'package:carive/screens/home/transluscent_card/transluscent_card.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';

import '../../shared/circular_progress_indicator.dart';

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
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color: themeColorGreen),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Search for cars",
                                    style: TextStyle(
                                        color: themeColorblueGrey,
                                        fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.search,
                                    color: themeColorGreen,
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        FadeTransition(
                                  opacity: animation,
                                  child: const SearchScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  hSizedBox20,
                  _buildCarGridView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarGridView() {
    return StreamBuilder<QuerySnapshot>(
      stream: carService.car,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }

        final List<CarModel> allCars = snapshot.data!.docs
            .map((doc) => CarModel.fromSnapshot(doc))
            .toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: allCars.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TransluscentCard(
              latitude: allCars[index].latitude,
              longitude: allCars[index].longitude,
              carId: allCars[index].carId!,
              image: allCars[index].imageUrl,
              brand: allCars[index].make,
              model: allCars[index].carModel,
              location: allCars[index].location,
              price: allCars[index].amount,
              fuelType: allCars[index].fuelType,
              modelYear: allCars[index].modelYear,
              seatCapacity: allCars[index].seatCapacity,
              ownerId: allCars[index].userId,
              isAvailable: allCars[index].isAvailable,
              ownerFcmToken: allCars[index].ownerFcmToken,
            );
          },
        );
      },
    );
  }
}
