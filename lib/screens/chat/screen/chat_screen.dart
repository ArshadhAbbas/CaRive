import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../keys/keys.dart';
import '../../../shared/custom_elevated_button.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController payController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: TextFormField(
                  controller: payController,
                  style:
                      TextStyle(color: Colors.white), // Set the text color here
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    int amount = int.parse(payController.text);
                    int amountInPaise = amount * 100;
                    String amountString = amountInPaise.toString();

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
                    showAlertDialog(context, 'Error', 'Invalid input');
                  }
                },
                child: Text("Pay"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed", "${response.message}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    showAlertDialog(
        context, "Payment Successful", "Payment ID: ${response.paymentId}");
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
