import 'package:carive/services/auth.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:carive/shared/transluscent_card.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService auth = AuthService();

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
                              borderSide: BorderSide(color: themeColorGreen),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: themeColorGreen),
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
                    itemCount: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return const TransluscentCard();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


 // body: Center(
          //   child:
          //    ElevatedButton(
          //     onPressed: () async {
          //       auth.signout();
          //     },
          //     style: ButtonStyle(
          //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //             RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20),
          //         )),
          //         backgroundColor:
          //             MaterialStateProperty.all(const Color(0xFF198396))),
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          //       child: Text("logout"),
          //     ),
          //   ),
          // ),