import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_text_form_field.dart';
import 'package:carive/shared/logo.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String error = '';
  final formkey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
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
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              hSizedBox30,
              CustomTextFormField(
                hintText: 'Email',
                labelText: 'Email',
                controller: emailController,
              ),
              hSizedBox30,
              CustomTextFormField(
                hintText: 'Password',
                labelText: 'Password',
                controller: passwordController,
                obscureText: true,
                isEye: true,
              ),
              hSizedBox30,
              CustomElevatedButton(text: "Register Now",onPressed: _registerButtonPressed),
              hSizedBox20,
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _registerButtonPressed() async {
    if (formkey.currentState?.validate() ?? false) {
      dynamic result = await auth.registerWithEmailAndPAssword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result == null) {
        setState(() {
          error = 'Invalid email';
        });
      } else if (result == 'email-already-in-use') {
        setState(() {
          error = 'User already exists, Please sign In ';
        });
      } else {
        print('Registered');
        Navigator.pop(context);
      }
    }
  }
}
