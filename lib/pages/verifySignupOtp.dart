import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/utils/routes.dart';

class VerifySignupOtpScreen extends StatefulWidget {
  final Map<String, dynamic> regData; // Brings the signup data from previous page

  const VerifySignupOtpScreen({super.key, required this.regData});

  @override
  State<VerifySignupOtpScreen> createState() => _VerifySignupOtpScreenState();
}

class _VerifySignupOtpScreenState extends State<VerifySignupOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  void verifyAndRegister() async {
    setState(() => isLoading = true);
    
    try {
      final String baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.X.X:3000';
      
      // 1. Verify OTP with the old existing backend route
      final verifyResponse = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roll": widget.regData['roll'],
          "otp": otpController.text.trim()
        }),
      );

      final verifyJson = jsonDecode(verifyResponse.body);

      if (verifyResponse.statusCode == 200 || verifyJson['status'] == 200) {
        // 2. OTP is Correct! Now register the user into DB
        print("✅ OTP Verified! Registering User...");
        
        var registerResponse = await ApiService.register(widget.regData);
        var registerJson = jsonDecode(registerResponse.body);

        if (registerJson['status'] == true || registerJson['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration Successful! 🎉"), backgroundColor: Colors.green),
          );
          // Redirect to Login
          Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute, (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(registerJson['message'] ?? "Registration failed."), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP! Try again."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("🔥 CRASH: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit OTP sent to ${widget.regData['roll']}@iitb.ac.in",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: verifyAndRegister,
                      child: const Text("Verify & Register", style: TextStyle(fontSize: 18)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}