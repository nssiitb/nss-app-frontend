// login_form.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/global/IPv4_address.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/utils/authenticator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isChecked = false;

  @override
  void dispose() {
    rollController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    if (rollController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    var reqBody = {
      "roll": rollController.text,
      "password": passwordController.text,
      "isaa": isChecked
    };

    try {
      var response = await http.post(
        Uri.parse(baseURL + '/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        await _authService.saveToken(jsonResponse['userData']);
        await GlobalAuthHelper.fetchToken();
        rollController.clear();
        passwordController.clear();
        if (mounted) {
          Navigator.popAndPushNamed(context, Routes.homeRoute);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message'] ?? "Something went wrong."),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED SingleChildScrollView from here
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFDADFEF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Roll Number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Mulish',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  // height: 50,
                  child: TextFormField(
                    controller: rollController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      filled: true,
                      fillColor: const Color(0xFFC5CDE9),
                      hintText: 'Enter your roll number',
                      hintStyle: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(216, 185, 231, 120),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  // height: 50,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      filled: true,
                      fillColor: const Color.fromARGB(182, 164, 205, 107),
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity, // Use double.infinity for responsiveness
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                const Text(
                  "Are you an AA?",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, // Use double.infinity for responsiveness
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDADFEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 3,
              ),
              onPressed: loginUser,
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Color(0xFF506680),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
