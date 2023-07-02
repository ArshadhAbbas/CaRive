import 'package:carive/services/auth.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../keys/keys.dart';
import '../../../shared/circular_progress_indicator.dart';
import '../../../shared/custom_elevated_button.dart';

// ignore: must_be_immutable
class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  AuthService auth = AuthService();

  late String userId;

  @override
  void initState() {
    super.initState();
    userId = auth.auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('customerNotifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final notifications = snapshot.data!.docs;
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: themeColorGreen),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index].data();
                    final notifcationTimestampString =
                        notification['timestamp'] as String;
                    final notifcationTimestamp =
                        DateTime.parse(notifcationTimestampString);
                    final notifcationFormattedDate =
                        DateFormat('dd/MM hh:mm').format(notifcationTimestamp);
                    return ListTile(
                      title: Text(
                        "${notification['message']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        notifcationFormattedDate,
                        style: TextStyle(color: themeColorblueGrey),
                      ),
                      trailing: Visibility(
                          visible: !notification['didPay'],
                          child: ElevatedButton(
                              onPressed: () {
                                try {
                                  int amount = int.parse(
                                      notification['amount'].toString());
                                  int amountInPaise = amount * 100;
                                  String amountString =
                                      amountInPaise.toString();

                                  Razorpay razorpay = Razorpay();
                                  var options = {
                                    'key': razorPayKey,
                                    'amount': amountString,
                                    'name': 'Name',
                                    'description': 'For car',
                                    'retry': {'enabled': true, 'max_count': 1},
                                    'send_sms_hash': true,
                                    'prefill': {
                                      'contact': '9633760600',
                                      'email': 'arshadhp98@gmail.com'
                                    },
                                    'external': {
                                      'wallets': ['paytm']
                                    }
                                  };
                                  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                                      handlePaymentErrorResponse);
                                  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                                      handlePaymentSuccessResponse);
                                  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                                      handleExternalWalletSelected);
                                  razorpay.open(options);
                                } catch (e) {
                                  showAlertDialog(
                                      context, 'Error', 'Invalid input');
                                }
                              },
                              child: Text("Pay ₹${notification['amount']}"))),
                    );
                  },
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
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed", "${response.message}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customerNotifications')
          .get();

      final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      final String documentId = documentSnapshot.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customerNotifications')
          .doc(documentId)
          .update({'didPay': true});
      // ignore: use_build_context_synchronously
      showAlertDialog(
          context, "Payment Successful", "Payment ID: ${response.paymentId}");
    } catch (e) {
      showAlertDialog(context, "Error", "Failed to update payment status.");
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = CustomElevatedButton(
      paddingHorizontal: 3,
      paddingVertical: 3,
      text: "Continue",
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: themeColorGrey,
      titleTextStyle: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      contentTextStyle: TextStyle(color: Colors.white),
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
