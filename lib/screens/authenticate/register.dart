// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_text_form_field.dart';
import 'package:carive/shared/logo.dart';

import '../../providers/register_screen_provider.dart'; // Import the RegisterScreenProvider
import '../../services/auth.dart';

class Register extends StatefulWidget {
  const Register({Key? key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<RegisterScreenProvider>(context, listen: false).error = '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterScreenProvider>(
      builder: (context, registerScreenProvider, _) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      const LogoWidget(30, 30),
                      wSizedBox20,
                      const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  hSizedBox30,
                  CustomTextFormField(
                    keyBoardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    labelText: 'Email',
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Email";
                      }
                      return null;
                    },
                  ),
                  hSizedBox30,
                  CustomTextFormField(
                    hintText: 'Password',
                    labelText: 'Password',
                    controller: passwordController,
                    obscureText: true,
                    isEye: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Password";
                      } else if (value.length < 6) {
                        return "Weak password, Must be 6 characters";
                      }
                      return null;
                    },
                  ),
                  hSizedBox30,
                  CustomElevatedButton(
                    text: "Register Now",
                    onPressed: () => _registerButtonPressed(
                      context,
                      emailController.text,
                      passwordController.text,
                    ),
                  ),
                  hSizedBox20,
                  Text(
                    registerScreenProvider.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _registerButtonPressed(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (formkey.currentState?.validate() ?? false) {
      dismissKeyboard(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CustomProgressIndicator(),
        ),
      );
      AuthService auth = AuthService();
      dynamic result = await auth.registerWithEmailAndPAssword(
        email.trim(),
        password.trim(),
      );
      Navigator.of(context).pop();

      final registerScreenProvider =
          Provider.of<RegisterScreenProvider>(context, listen: false);
      if (result == null) {
        registerScreenProvider.setError('Invalid email');
      } else if (result == 'email-already-in-use') {
        registerScreenProvider.setError('User already exists, Please sign In');
      } else {
        Navigator.pop(context);
      }
    }
  }
}
