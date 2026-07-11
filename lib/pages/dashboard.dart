import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);
const int _kTotalHours = 40;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();

  int? _completedHours;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCompletedHours();
  }

  Future<void> _fetchCompletedHours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final userData = await _authService.getToken();
      if (userData == null || userData['roll'] == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not find your account. Please sign in again.';
            _isLoading = false;
          });
        }
        return;
      }

      final res =
          await ApiService.getCompletedHours(userData['roll'].toString());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == true && body['hours'] != null) {
          if (mounted) {
            setState(() {
              _completedHours = (body['hours'] as num).toInt();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = body['message']?.toString() ?? 'Failed to load hours.';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Server error (${res.statusCode}).';
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = "Couldn't reach the server. Pull to refresh.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = _completedHours ?? 0;
    final progress = (hours / _kTotalHours).clamp(0.0, 1.0);
    final remaining = (_kTotalHours - hours).clamp(0, _kTotalHours);

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
          'My Progress',
          style: rf(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _kInk,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kBrand,
          onRefresh: _fetchCompletedHours,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 120),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _kBrand,
                        strokeWidth: 2.4,
                      ),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? _ErrorCard(
                        message: _errorMessage,
                        onRetry: _fetchCompletedHours,
                      )
                    : _Content(
                        hours: hours,
                        progress: progress,
                        remaining: remaining,
                      ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final int hours;
  final double progress;
  final int remaining;

  const _Content({
    required this.hours,
    required this.progress,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Ring
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _kBrand.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: _kChipBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(_kBrand),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$hours',
                      style: rf(
                        fontSize: 64,
                        fontWeight: FontWeight.w500,
                        color: _kInk,
                        height: 1.0,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hours Done',
                      style: rf(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _kMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Text(
          remaining > 0
              ? "You need $remaining more hours to qualify."
              : "You've completed your PP requirement.",
          textAlign: TextAlign.center,
          style: rf(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: _kInk,
          ),
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1A3B5A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.info_outline, size: 18, color: _kBrand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'A minimum of 40 hours must be completed to be eligible for the PP grade — 36 hours of NSS activities and 4 hours of Wellness activities.',
                  style: rf(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA), width: 1),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 28),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: rf(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF991B1B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: _kBrand,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Try again',
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
