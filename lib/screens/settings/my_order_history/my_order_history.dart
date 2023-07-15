import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';

import '../../../services/wishlist_service.dart';
import '../../../shared/circular_progress_indicator.dart';

class MyOrdersHistory extends StatefulWidget {
  const MyOrdersHistory({Key? key}) : super(key: key);

  @override
  State<MyOrdersHistory> createState() => _MyOrdersHistoryState();
}

class _MyOrdersHistoryState extends State<MyOrdersHistory> {
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
    return CustomScaffold(
      child: Scaffold(
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
          title: const Text("My Orders"),
          centerTitle: false,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('myOrders')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final orders = snapshot.data!.docs;
              if (orders.isEmpty) {
                return const Center(
                  child: Text(
                    'No orders yet.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final order = orders[index].data();
                  final carId = order['carId'] as String;

                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('cars')
                        .doc(carId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final carData = snapshot.data!.data()!;
                        final carImage = carData['imageUrl'] as String;

                        final startDateString = order['startDate'] as String;
                        final startDate = DateTime.parse(startDateString);
                        final formattedStartDate =
                            DateFormat('dd/MM/yyyy').format(startDate);

                        final endDateString = order['endDate'] as String;
                        final endDate = DateTime.parse(endDateString);
                        final formattedEndDate =
                            DateFormat('dd/MM/yyyy').format(endDate);

                            final orderDateString = order['orderDate'] as String;
                        final orderDate = DateTime.parse(orderDateString);
                        final formattedOrderDateDate =
                            DateFormat('dd/MM/yyyy').format(orderDate);

                        return GestureDetector(
                          onTap: () {
                            showPopover(
                              context: context,
                              bodyBuilder: (context) => SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Order Id: ${order['OrderId']}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        "Amount paid: ${order['amount']}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        "Start Date: $formattedStartDate",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        "End Date: $formattedEndDate",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: themeColorGrey,
                              onPop: () => print('Popover was popped!'),
                              direction: PopoverDirection.top,
                              width: double.infinity,
                              arrowHeight: 15,
                              arrowWidth: 30,
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF3E515F),
                              backgroundImage: NetworkImage(carImage),
                            ),
                            title: Text(
                              "${carData['make']} ${carData['carModel']}",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "ordered On $formattedOrderDateDate ",
                              style: TextStyle(color: themeColorblueGrey),
                            ),
                          ),
                        );
                      } else {
                        return CustomProgressIndicator();
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: orders.length,
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error fetching Notification.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return const CustomProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
