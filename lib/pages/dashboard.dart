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
const int _kTotalHours = 34;
const int _kTargetHours = 28;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();

  int? _completedHours;
  List<dynamic> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedSem = 'Autumn-2026';
  final List<String> _availableSems = ['Autumn-2026', 'Spring-2026'];

  @override
  void initState() {
    super.initState();
    _fetchProgressData();
  }

  Future<void> _fetchProgressData() async {
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

      final roll = userData['roll'].toString();
      final res = await ApiService.getVolunteerProgress(roll, sem: _selectedSem);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          if (mounted) {
            setState(() {
              _completedHours = (body['completedHours'] as num?)?.toInt() ?? 0;
              _events = body['events'] ?? [];
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = body['message']?.toString() ?? 'Failed to load progress.';
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
    } catch (e) {
      print(">>> DASHBOARD ERROR: $e");
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
    final remaining = (_kTargetHours - hours).clamp(0, _kTargetHours);

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
          onRefresh: _fetchProgressData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        onRetry: _fetchProgressData,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Semester Dropdown Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _kChipBg, width: 1.5),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSem,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: _kBrand, size: 18),
                                    style: rf(fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
                                    onChanged: (String? newSem) {
                                      if (newSem != null && newSem != _selectedSem) {
                                        setState(() {
                                          _selectedSem = newSem;
                                        });
                                        _fetchProgressData();
                                      }
                                    },
                                    items: _availableSems.map<DropdownMenuItem<String>>((String val) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(val),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _Content(
                            hours: hours,
                            progress: progress,
                            remaining: remaining,
                          ),
                          const SizedBox(height: 28),
                          // Activities Section Header
                          Text(
                            'Semester Activities',
                            style: rf(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _kInk,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Events dynamic list
                          _events.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No activities found for this semester.',
                                      style: rf(fontSize: 13, color: _kMuted),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _events.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final ev = _events[index];
                                    final bool isPresent = ev['status'] == 'PRESENT';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x081A3B5A),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isPresent
                                                  ? const Color(0xFFE8F5E9)
                                                  : const Color(0xFFFFEBEE),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              isPresent ? Icons.check_circle_outline : Icons.cancel_outlined,
                                              color: isPresent
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFC62828),
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ev['event_name'] ?? 'Activity',
                                                  style: rf(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: _kInk,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${ev['date']} • ${ev['hours']} hrs',
                                                  style: rf(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: _kMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isPresent
                                                  ? const Color(0xFFE8F5E9)
                                                  : const Color(0xFFFFEBEE),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isPresent ? 'PRESENT' : 'ABSENT',
                                              style: rf(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isPresent
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFC62828),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 24),
                        ],
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
        const SizedBox(height: 20),
        // Ring
        SizedBox(
          width: 220,
          height: 220,
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
                        fontSize: 60,
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
        const SizedBox(height: 28),
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
        const SizedBox(height: 24),
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
                  'A minimum of 28 hrs must be completed to be eligible for the PP grade out of 34 hours of NSS activities.',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
