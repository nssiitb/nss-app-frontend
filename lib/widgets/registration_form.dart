import 'dart:convert';
import 'package:nssapp/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/global/uuid.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  // Error messages
  String? nameError;
  String? rollError;
  String? phoneError;
  String? emailError;
  String? passError;
  bool showDeptError = false;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Dispose to prevent memory leaks
  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    phoneController.dispose();
    deptController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void registerUser() async {
    String fingerprint = await DeviceIDHelper.getDeviceId();

    var regBody = {
      "roll": rollController.text,
      "name": nameController.text,
      "mobile": phoneController.text,
      "dept": deptController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "fingerprint": fingerprint,
    };

    var response = await ApiService.register(regBody);

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status']) {
      Navigator.pushNamed(context, Routes.loginRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonResponse['message'] ?? "Something went wrong."),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          errorText: errorText,
          labelText: label,
          labelStyle: const TextStyle(fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: deptController.text.isEmpty ? null : deptController.text,
            items: const [
              DropdownMenuItem(value: 'CE', child: Text('Campus Engagement')),
              DropdownMenuItem(value: 'EO', child: Text('Educational Outreach')),
              DropdownMenuItem(value: 'SD', child: Text('Social Development')),
              DropdownMenuItem(
                  value: 'EnS', child: Text('Environment and Sustainabilty')),
            ],
            onChanged: (val) {
              setState(() {
                deptController.text = val ?? '';
                showDeptError = false;
              });
            },
            decoration: InputDecoration(
              hintText: "Select Department",
              labelText: "Department",
              labelStyle: const TextStyle(fontSize: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (showDeptError)
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 12),
              child: Text(
                "Please select a department",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      // Name validation
      if (nameController.text.trim().isEmpty) {
        nameError = "Please enter your name";
        isValid = false;
      } else {
        nameError = null;
      }

      // Roll validation
      if (rollController.text.trim().isEmpty) {
        rollError = "Please enter your roll number";
        isValid = false;
      } else {
        rollError = null;
      }

      // Phone validation
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        phoneError = "Please enter your phone number";
        isValid = false;
      } else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
        phoneError = "Phone number must be exactly 10 digits";
        isValid = false;
      } else {
        phoneError = null;
      }

      // Email validation
      final email = emailController.text.trim();
      if (email.isEmpty) {
        emailError = "Please enter your email";
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(email)) {
        emailError = "Please enter a valid email address";
        isValid = false;
      } else {
        emailError = null;
      }

      // Password validation
      if (passwordController.text.isEmpty) {
        passError = "Please enter a password";
        isValid = false;
      } else if (passwordController.text.length < 6) {
        passError = "Password must be at least 6 characters long";
        isValid = false;
      } else {
        passError = null;
      }

      // Department validation
      if (deptController.text.isEmpty) {
        showDeptError = true;
        isValid = false;
      } else {
        showDeptError = false;
      }
    });
    return isValid;
  }

  void validateAndSubmit() {
    if (_validateForm()) {
      registerUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the errors in the form."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _textField(
            controller: nameController,
            label: "Name",
            errorText: nameError,
          ),
          _textField(
            controller: rollController,
            label: "Roll Number",
            errorText: rollError,
          ),
          _textField(
            controller: phoneController,
            label: "Phone Number",
            errorText: phoneError,
            keyboardType: TextInputType.phone,
          ),
          _dropdownField(),
          _textField(
            controller: emailController,
            label: "Email",
            errorText: emailError,
            keyboardType: TextInputType.emailAddress,
          ),
          _textField(
            controller: passwordController,
            label: "Password",
            errorText: passError,
            obscureText: true,
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDADFEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 3,
                ),
                onPressed: validateAndSubmit,
                child: const Text(
                  'Sign Up',
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
