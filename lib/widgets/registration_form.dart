import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nssapp/global/uuid.dart';
import 'package:nssapp/pages/verifySignupOtp.dart'; // ✅ Added the missing semicolon here

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
  String? confirmPassError;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Dispose to prevent memory leaks
  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ The Single, Clean OTP Flow Function
  void registerUser() async {
    try {
      print("🚀 Validating and requesting OTP...");
      String fingerprint = await DeviceIDHelper.getDeviceId();

      // Form data to carry forward to the next screen
      var regBody = {
        "roll": rollController.text.trim(),
        "name": nameController.text.trim(),
        "mobile": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "dept": "NA", // The smart bypass 😎
        "fingerprint": fingerprint,
      };

      final String baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.X.X:3000'; 
      
      // Requesting OTP from backend
      var otpResponse = await http.post(
        Uri.parse("$baseUrl/send-signup-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roll": rollController.text.trim(),
          "email": emailController.text.trim()
        }),
      );

      var otpJson = jsonDecode(otpResponse.body);

      if (otpResponse.statusCode == 200 || otpJson['status'] == 200) {
        print("✅ OTP Sent Successfully! Redirecting to Verify Page...");
        // Redirect to Verify OTP Screen and pass the regBody
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifySignupOtpScreen(regData: regBody), 
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpJson['message'] ?? "Failed to send OTP."),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("🔥 CRASH IN SENDING OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
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

      // Confirm Password validation
      if (confirmPasswordController.text.isEmpty) {
        confirmPassError = "Please confirm your password";
        isValid = false;
      } else if (confirmPasswordController.text != passwordController.text) {
        confirmPassError = "Passwords do not match";
        isValid = false;
      } else {
        confirmPassError = null;
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
          _textField(
            controller: confirmPasswordController,
            label: "Confirm Password",
            errorText: confirmPassError,
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
                'Verify Email',
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