import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';

class CarDetails extends StatelessWidget {
  const CarDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            Image.asset(
              'assets/Thar.jpg',
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
                                  "Mahindra Thar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                                hSizedBox10,
                                Text(
                                  "₹5000/Day",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                                hSizedBox10,
                                Text(
                                  "Malappuram, Kerala",
                                  style: TextStyle(color: Colors.white),
                                ),
                                hSizedBox10,
                                Text(
                                  "Available",
                                  style: TextStyle(color: Colors.white),
                                ),
                                hSizedBox20,
                                Text(
                                  "Owner Info",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                hSizedBox10,
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Seat Capacity : 8",
                                  style: TextStyle(color: Colors.white),
                                ),
                                hSizedBox10,
                                Text(
                                  "Fuel Type : Diesel",
                                  style: TextStyle(color: Colors.white),
                                ),
                                hSizedBox10,
                                Text(
                                  "Model Year : 2020",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(color: themeColorGreen),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  child: Image.asset(
                                    'assets/Akhil.jpg',
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                wSizedBox10,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Akhil G Krishnan",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    Spacer(),
                                    Text(
                                      "Pattambi, Palakkad",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Spacer(),
                                    Text(
                                      "+919446095998",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(
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
                              border: Border.all(color: themeColorGreen),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            "Location",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                        hSizedBox10,
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
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
                            child: Text("Book Now"),
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
  }
}
