import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show PillField, PillButton, rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const Color _kDanger = Color(0xFFDC2626);

class VerifyOTP extends StatefulWidget {
  const VerifyOTP({super.key});

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  final _otpController = TextEditingController();
  late Map<String, dynamic> args;
  bool _loading = false;
  bool _resending = false;
  late String _roll;
  late String _mode;
  Timer? _timer;
  int _secondsLeft = 300;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _mode = args["mode"];
    _roll = args["roll"];
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        t.cancel();
        _snack('OTP expired. Please request a new one.');
        if (_mode == "signup") {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.signUpRoute,
            (_) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginRoute,
            (_) => false,
          );
        }
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
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

  Future<void> _verify() async {
    if (_loading) return;
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _snack('Enter the 6-digit OTP.');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await ApiService.verifyOTP({
          "roll": _roll,
          "otp": otp,
      });
      final data=jsonDecode(response.body);
      if(!mounted) return;
      if(response.statusCode==200 && data["status"]==200){
        _snack("OTP verified!");
        if(_mode == "reset"){
          Navigator.pushReplacementNamed(
            context,
            Routes.resetPassword,
            arguments: _roll,
          );
        } else{
          final response = await ApiService.register({
            "roll": args["roll"],
            "name": args["name"],
            "mobile": args["mobile"],
            "email": args["email"],
            "password": args["password"],
            "fingerprint": args["fingerprint"],
          });
          final json = jsonDecode(response.body);
          if (json["status"]) {
            if (!mounted) return;
            _snack("Registration successful!");
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginRoute,
              (_) => false,
            );
          }
        }
      } else {
        _snack(data["message"] ?? 'Invalid OTP.');
      }
    } catch(_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async{
    if (_resending) return;
    setState(() => _resending = true);
    try {
      final response = await ApiService.forgotPassword({
        "roll": _roll,
        "mode": _mode,
      });
      final json = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200 && json["status"] == 200) {
        setState(() => _secondsLeft = 300);
        _snack("A new OTP has been sent.");
      } else {
        _snack(json["message"] ?? "Unable to resend OTP.");
      }
    } catch (_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
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
          'Verify OTP',
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
                child: const Icon(Icons.mark_email_read_outlined,
                    color: _kBrand, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Check your email',
                style: rf(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: rf(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit OTP to '),
                    TextSpan(
                      text: '$_roll@iitb.ac.in',
                      style: rf(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kInk,
                      ),
                    ),
                    const TextSpan(text: '. Enter it below to continue.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _expiryChip(),
              const SizedBox(height: 20),
              PillField(
                controller: _otpController,
                hintText: '6-digit OTP',
                prefixIcon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 24),
              PillButton(
                label: 'Verify OTP',
                loading: _loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _resending ? null : _resend,
                  child: Text(
                    _resending ? 'Resending…' : "Didn't get it? Resend OTP",
                    style: rf(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kBrand,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expiryChip() {
    final expiring = _secondsLeft <= 30;
    final fg = expiring ? _kDanger : _kBrand;
    final bg = expiring ? const Color(0xFFFEF2F2) : _kChipBg;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              'Expires in ${_formatTime(_secondsLeft)}',
              style: rf(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
