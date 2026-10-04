import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/widgets/login_form.dart'
    show PillField, PillButton, rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _confirmFocus = FocusNode();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  late String _roll;
  bool _isAa = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map) {
      _roll = args["roll"];
      _isAa = args["is_aa"] ?? false;
    } else {
      _roll = args as String;
      _isAa = false;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _confirmFocus.dispose();
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

  Future<void> _reset() async {
    if (_loading) return;
    final pw = _passwordController.text;
    final confirm = _confirmController.text;
    if (pw.isEmpty) {
      _snack('Enter a new password.');
      return;
    }
    if (pw.length < 6) {
      _snack('Password must be at least 6 characters.');
      return;
    }
    if (pw != confirm) {
      _snack('Passwords don\'t match.');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse("Uri.parse("${dotenv.env['BASE_URL']}/reset-password")"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "roll": _roll, 
          "password": pw,
          "is_aa": _isAa, 
        }),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 && data["status"] == 200) {
        _snack('Password changed. Please sign in with your new password.');
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.loginRoute,
          (_) => false,
        );
      } else {
        _snack(data["message"] ?? 'Unable to reset password.');
      }
    } catch (e, stackTrace) {
      print("RESET PASSWORD ERROR IN APP: $e");
      print(stackTrace);
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
        title: Text(
          'New password',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
        centerTitle: false,
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
                child: const Icon(Icons.lock_outline,
                    color: _kBrand, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Create a new password',
                style: rf(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose something you haven\'t used on this account before.',
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              PillField(
                controller: _passwordController,
                hintText: 'New password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
                suffix: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: _kMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 16),
              PillField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _reset(),
                suffix: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: _kMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 24),
              PillButton(
                label: 'Update Password',
                loading: _loading,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
