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

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final phoneController = TextEditingController();
  final deptController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!_validateForm()) {
      _snack("Please fix the errors above.");
      return;
    }
    setState(() => _loading = true);
    try {
      final fingerprint = await DeviceIDHelper.getDeviceId();
      final regBody = {
        "roll": rollController.text.trim(),
        "name": nameController.text.trim(),
        "mobile": phoneController.text.trim(),
        "dept": deptController.text,
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "fingerprint": fingerprint,
      };
      final response = await ApiService.register(regBody);
      final jsonResponse = jsonDecode(response.body);
      _snack(jsonResponse['message'] ?? "Something went wrong.");
      if (jsonResponse['status'] == true && mounted) {
        Navigator.pushReplacementNamed(context, Routes.loginRoute);
      }
    } catch (_) {
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

      if (deptController.text.isEmpty) {
        showDeptError = true;
        isValid = false;
      } else {
        confirmPassError = null;
      }
    });
    return isValid;
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
          _deptDropdown(),
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
          PillField(
            controller: passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            errorText: passError,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _kMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 32),
          PillButton(
            label: 'Create Account',
            loading: _loading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _deptDropdown() {
    const items = <_DeptOption>[
      _DeptOption('CE', 'Campus Engagement'),
      _DeptOption('EO', 'Educational Outreach'),
      _DeptOption('SD', 'Social Development'),
      _DeptOption('EnS', 'Environment and Sustainability'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // Match PillField rendered height: 18 (top pad) + 20 (line height) + 18 (bottom pad) ≈ 56.
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F1A3B5A),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: deptController.text.isEmpty
                      ? null
                      : deptController.text,
                  isExpanded: true,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: _kMuted),
                  dropdownColor: Colors.white,
                  elevation: 6,
                  borderRadius: BorderRadius.circular(20),
                  menuMaxHeight: 320,
                  hint: Row(
                    children: [
                      const Icon(Icons.apartment_outlined,
                          size: 20, color: _kMuted),
                      const SizedBox(width: 12),
                      Text(
                        'Select department',
                        style: rf(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: _kMuted,
                        ),
                      ),
                    ],
                  ),
                  style: rf(
                      fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
                  selectedItemBuilder: (context) => items
                      .map((o) => _DeptRow(
                          icon: Icons.apartment_outlined, text: o.label))
                      .toList(),
                  items: items
                      .map(
                        (o) => DropdownMenuItem<String>(
                          value: o.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              o.label,
                              style: rf(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: _kInk,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      deptController.text = val ?? '';
                      showDeptError = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        if (showDeptError)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              'Please select a department',
              style: rf(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
      ],
    );
  }
}

class _DeptOption {
  final String value;
  final String label;
  const _DeptOption(this.value, this.label);
}

class _DeptRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DeptRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _kMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
          ),
        ),
      ],
    );
  }
}
