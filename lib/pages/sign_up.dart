import 'package:flutter/material.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/registration_form.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header with back arrow and title
              Row(
                children: [
                  Container(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, Routes.loginRoute);
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color.fromARGB(255, 0, 75, 112),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 75, 112),
                      fontFamily: "Raleway",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RegistrationForm(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
