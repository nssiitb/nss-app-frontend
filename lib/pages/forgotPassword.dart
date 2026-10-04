import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/login_form.dart'
    show PillField, PillButton, rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _rollController = TextEditingController();
  bool _loading = false;
  bool _isAA = false;

  @override
  void dispose() {
    _rollController.dispose();
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

  Future<void> _sendOtp() async {
    if (_loading) return;
    final _roll = _rollController.text.trim().toUpperCase();
    if (_roll.isEmpty) {
      _snack('Please enter your roll number.');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await ApiService.forgotPassword({
        "roll": _roll,
        "mode": "reset",
        "is_aa": _isAA,
      });
      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200 && data["status"] == 200) {
        _snack('OTP sent successfully.');
        Navigator.pushReplacementNamed(
          context,
          Routes.verifyOTP,
          arguments: {
            "mode": "reset",
            "roll": _roll,
            "is_aa": _isAA,
          },
        );
      } else {
        _snack(data["message"] ?? 'Unable to send OTP.');
      }
    } catch (_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _kInk),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.lock_reset_rounded,
                    color: _kBrand, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Forgot your password?',
                style: rf(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter your roll number and we'll send an OTP to your registered email.",
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              PillField(
                controller: _rollController,
                hintText: 'Roll number',
                prefixIcon: Icons.badge_outlined,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                onSubmitted: (_) => _sendOtp(),
              ),
              const SizedBox(height: 8),
              // --- AA Checkbox Start ---
              CheckboxListTile(
                value: _isAA,
                onChanged: (val) => setState(() => _isAA = val ?? false),
                title: Text(
                  'Change AA Password',
                  style: rf(fontSize: 14, fontWeight: FontWeight.w500, color: _kInk),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: _kBrand,
              ),
              // --- AA Checkbox End ---
              const SizedBox(height: 8),
              PillButton(
                label: 'Send OTP',
                loading: _loading,
                onPressed: _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}