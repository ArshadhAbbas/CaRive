import 'dart:ui';

import 'package:carive/screens/home/car_details/car_details.dart';
import 'package:carive/shared/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TransluscentCard extends StatelessWidget {
  TransluscentCard(
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
      required this.isAvailable,
      required this.ownerFcmToken,
      required this.latitude,
      required this.longitude});
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
  double latitude;
  double longitude;
  String ownerFcmToken;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white60.withOpacity(0.13), Colors.white10],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  // height: 130,
                  // width: 170,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                            width: 10,
                            child: const CircleAvatar(
                              backgroundColor: Colors.green,
                            )),
                        Text(
                          isAvailable ? "Available" : "Unavailable",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/map-marker.png',
                      width: 15,
                    ),
                    wSizedBox10,
                    Text(location,
                        style: TextStyle(color: Colors.white, fontSize: 15))
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "₹${price}",
                            style: TextStyle(color: themeColorGreen),
                          ),
                          const Text(
                            "/day",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF198396)),
                        ),
                        child: Text("Explore"),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CarDetails(
                                latitude: latitude,
                                longitude: longitude,
                                carId: carId,
                                brand: brand,
                                image: image,
                                location: location,
                                model: model,
                                price: price,
                                modelYear: modelYear,
                                seatCapacity: seatCapacity,
                                fuelType: fuelType,
                                ownerId: ownerId,
                                isAvailable: isAvailable,
                                ownerFcmToken: ownerFcmToken),
                          ));
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
