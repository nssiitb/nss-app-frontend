// sign_in.dart

import 'package:flutter/material.dart';
import 'package:nssapp/widgets/login_form.dart';
import 'package:nssapp/utils/routes.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 75, 112),
            fontFamily: "Raleway",
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
          child: Column(
            children: [
              const LoginForm(),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.forgotPassword);
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 106, 192),
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.signUpRoute);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 16, fontFamily: 'Raleway'),
                ),
                Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 106, 192),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
