import 'dart:ui';

import 'package:carive/screens/home/car_details/car_details.dart';
import 'package:carive/shared/constants.dart';
import 'package:flutter/material.dart';

class TransluscentCard extends StatelessWidget {
  const TransluscentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 400,
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
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/Thar.jpg',
                      fit: BoxFit.fitWidth,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Mahindra Thar",
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
                        const Text(
                          "Available",
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
                    const Text("Location",
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
                            "₹Price",
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
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CarDetails(),));
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
