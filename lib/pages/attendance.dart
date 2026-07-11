import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/global/uuid.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _selectedActivity;

  bool _submitting = false;
  bool _loadingActivities = true;
  String _fetchError = '';

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _loadingActivities = true;
      _fetchError = '';
    });
    try {
      final res = await ApiService.getEventsToday();
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final events = (data['events'] as List?) ?? const [];
        if (!mounted) return;
        setState(() {
          _activities = List<Map<String, dynamic>>.from(events);
          _loadingActivities = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _fetchError = "Couldn't load today's events (${res.statusCode}).";
          _loadingActivities = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fetchError = "Couldn't reach the server. Pull to refresh.";
        _loadingActivities = false;
      });
    }
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

  Future<void> _markAttendance() async {
    if (_submitting) return;
    if (_selectedActivity == null) {
      _snack('Please select an activity first.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await GlobalAuthHelper.fetchToken();
      final name = GlobalAuthHelper.globalname;
      final roll = GlobalAuthHelper.globalrollNo;
      final dept = GlobalAuthHelper.globaldept;
      final timestamp =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final eventName = _selectedActivity?['name'];
      final aaRoll = _selectedActivity?['AA'];

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are off. Enable location to continue.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          throw Exception(
              'Location denied. Enable it in Settings › Apps › NSS IITB › Permissions.');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final fingerprint = await DeviceIDHelper.getDeviceId();

      final response = await ApiService.markAttendance({
        '_roll_': roll,
        '_name_': name,
        '_timestamp_': timestamp,
        '_latitude_': position.latitude.toString(),
        '_longitude_': position.longitude.toString(),
        '_department_': dept,
        '_status_': '1',
        '_message_': eventName,
        '_fingerprint_': fingerprint,
        'aa_roll': aaRoll,
      });
      final body = json.decode(response.body);
      _snack(body['message']?.toString() ?? 'Attendance marked.');
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      _snack(msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
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
          'Mark Attendance',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kBrand,
          onRefresh: _fetchActivities,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _hero(),
                const SizedBox(height: 28),
                Text(
                  'ACTIVITY',
                  style: rf(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _activityPicker(),
                const SizedBox(height: 24),
                _primaryButton(),
                const SizedBox(height: 14),
                _footerNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _kChipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.fact_check_outlined,
              color: _kBrand, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          'Mark your attendance',
          style: rf(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: _kInk,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Pick today's activity to confirm your participation.",
          style: rf(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: _kMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _activityPicker() {
    if (_loadingActivities) {
      return _pickerShell(
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _kMuted,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading activities…',
              style: rf(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: _kMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (_fetchError.isNotEmpty) {
      return _pickerShell(
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fetchError,
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_activities.isEmpty) {
      return _pickerShell(
        child: Row(
          children: [
            const Icon(Icons.event_busy_outlined, size: 20, color: _kMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No activities scheduled today.',
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _kMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _pickerShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedActivity,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _kMuted),
          dropdownColor: Colors.white,
          elevation: 6,
          borderRadius: BorderRadius.circular(20),
          menuMaxHeight: 320,
          hint: Row(
            children: [
              const Icon(Icons.event_outlined, size: 20, color: _kMuted),
              const SizedBox(width: 12),
              Text(
                "Select today's activity",
                style: rf(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                ),
              ),
            ],
          ),
          style: rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
          selectedItemBuilder: (ctx) => _activities
              .map((a) => Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          size: 20, color: _kBrand),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          a['name']?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: rf(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _kInk,
                          ),
                        ),
                      ),
                    ],
                  ))
              .toList(),
          items: _activities
              .map(
                (a) => DropdownMenuItem<Map<String, dynamic>>(
                  value: a,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      a['name']?.toString() ?? '',
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
          onChanged: (v) => setState(() => _selectedActivity = v),
        ),
      ),
    );
  }

  Widget _pickerShell({required Widget child}) {
    return SizedBox(
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
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ),
    );
  }

  Widget _primaryButton() {
    final disabled = _selectedActivity == null || _submitting;
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: _kBrand.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: disabled ? null : _markAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBrand,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kBrand.withOpacity(0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Mark Attendance',
                  style: rf(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _footerNote() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: _kMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Your location is used to verify your attendance.',
              style: rf(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: _kMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
