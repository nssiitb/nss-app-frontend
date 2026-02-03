import 'dart:convert';
import 'package:nssapp/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/IPv4_address.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  // Validation state
  bool nameValid = true;
  bool rollValid = true;
  bool phoneValid = true;
  bool emailValid = true;
  bool passValid = true;

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
    var regBody = {
      "roll": rollController.text,
      "name": nameController.text,
      "mobile": phoneController.text,
      "dept": deptController.text,
      "email": emailController.text,
      "password": passwordController.text,
    };

    var response = await http.post(
      Uri.parse(baseURL + '/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

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
    required bool isValid,
    required String errorText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          errorText: !isValid ? errorText : null,
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
      child: DropdownButtonFormField<String>(
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
    );
  }

  void validateAndSubmit() {
    setState(() {
      nameValid = nameController.text.isNotEmpty;
      rollValid = rollController.text.isNotEmpty;
      phoneValid = phoneController.text.isNotEmpty;
      emailValid = emailController.text.isNotEmpty;
      passValid = passwordController.text.isNotEmpty;
    });

    if (nameValid &&
        rollValid &&
        phoneValid &&
        emailValid &&
        passValid &&
        deptController.text.isNotEmpty) {
      registerUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields correctly."),
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
            isValid: nameValid,
            errorText: "Please enter your name.",
          ),
          _textField(
            controller: rollController,
            label: "Roll Number",
            isValid: rollValid,
            errorText: "Please enter your roll number.",
          ),
          _textField(
            controller: phoneController,
            label: "Phone Number",
            isValid: phoneValid,
            errorText: "Please enter your phone number.",
          ),
          _dropdownField(),
          _textField(
            controller: emailController,
            label: "Email",
            isValid: emailValid,
            errorText: "Please enter your email.",
          ),
          _textField(
            controller: passwordController,
            label: "Password",
            isValid: passValid,
            errorText: "Please enter your password.",
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
