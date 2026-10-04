import 'dart:convert';
import 'package:nssapp/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/global/uuid.dart';
import 'package:nssapp/widgets/login_form.dart' show PillField, PillButton, rf;

const Color _kInk = Color(0xFF343A40);
const Color _kMuted = Color(0xFF6C757D);

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  String? nameError;
  String? rollError;
  String? phoneError;
  String? emailError;
  String? passError;
  String? confirmPassError;
  String? deptError;

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedDept;
  final List<String> departments = [
    'Environment and Sustainability',
    'Social Development',
    'Educational Outreach',
    'Campus Engagement',
  ];

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void _snack(String msg) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> sendSignupOTP() async {
    if (_loading) return;
    if (!_validateForm()) {
      _snack("Please fix the errors above.");
      return;
    }
    setState(() => _loading = true);
    try {
      final fingerprint = await DeviceIDHelper.getDeviceId();
      final response = await ApiService.forgotPassword({
        "roll": rollController.text.trim().toUpperCase(),
        "mode": "signup",
      });
      final json = jsonDecode(response.body);
      if (!mounted) return;
      if (json["status"] == 200) {
        Navigator.pushNamed(
          context,
          Routes.verifyOTP,
          arguments: {
            "mode": "signup",
            "name": nameController.text.trim(),
            "roll": rollController.text.trim().toUpperCase(),
            "mobile": phoneController.text.trim(),
            "email": emailController.text.trim(),
            "password": passwordController.text,
            "dept": selectedDept, // Ikkada department kooda backend/OTP verify ki vellipotundi!
            "fingerprint": fingerprint,
          },
        );
      } else {
        _snack(json["message"] ?? "Unable to send OTP");
      }
    } catch (_) {
      if (!mounted) return;
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      if (nameController.text.trim().isEmpty) {
        nameError = "Please enter your name";
        isValid = false;
      } else {
        nameError = null;
      }

      if (rollController.text.trim().isEmpty) {
        rollError = "Please enter your roll number";
        isValid = false;
      } else {
        rollError = null;
      }

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

      if (selectedDept == null) {
        deptError = "Please select a department";
        isValid = false;
      } else {
        deptError = null;
      }

      final pw = passwordController.text;
      final policy =
          RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
      if (pw.isEmpty) {
        passError = "Please enter a password";
        isValid = false;
      } else if (!policy.hasMatch(pw)) {
        passError = "8+ chars, upper, lower, digit and a symbol";
        isValid = false;
      } else {
        passError = null;
      }

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
      sendSignupOTP();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillField(
            controller: nameController,
            hintText: 'Full name',
            prefixIcon: Icons.badge_outlined,
            errorText: nameError,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: 16),
          PillField(
            controller: rollController,
            hintText: 'Roll number',
            prefixIcon: Icons.person_outline,
            errorText: rollError,
            autofillHints: const [AutofillHints.username],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          PillField(
            controller: phoneController,
            hintText: 'Phone number',
            prefixIcon: Icons.phone_outlined,
            errorText: phoneError,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          PillField(
            controller: emailController,
            hintText: 'Email',
            prefixIcon: Icons.mail_outline,
            errorText: emailError,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          // Department Dropdown Selection Field
          DropdownButtonFormField<String>(
            value: selectedDept,
            decoration: InputDecoration(
              hintText: 'Select Department',
              prefixIcon: const Icon(Icons.group_outlined, color: _kMuted, size: 20),
              errorText: deptError,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            items: departments.map((String dept) {
              return DropdownMenuItem<String>(
                value: dept,
                child: Text(dept, style: const TextStyle(fontSize: 14, color: _kInk)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDept = newValue;
                deptError = null;
              });
            },
          ),
          const SizedBox(height: 16),
          PillField(
            controller: passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            errorText: passError,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _kMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          PillField(
            controller: confirmPasswordController,
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            errorText: confirmPassError,
            obscureText: _obscureConfirmPassword,
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _kMuted,
                size: 20,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: 32),
          PillButton(
            label: 'Create Account',
            loading: _loading,
            onPressed: sendSignupOTP,
          ),
        ],
      ),
    );
  }
}