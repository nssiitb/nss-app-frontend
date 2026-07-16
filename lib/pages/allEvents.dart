import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class Allevents extends StatefulWidget {
  const Allevents({super.key});

  @override
  State<Allevents> createState() => _AlleventsState();
}

class _AlleventsState extends State<Allevents> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiService.getAllEvents();
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final events = (data['events'] as List?) ?? const [];
        events.sort((a, b) {
          final da = DateTime.tryParse(a['date'] ?? '');
          final db = DateTime.tryParse(b['date'] ?? '');
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        if (!mounted) return;
        setState(() {
          _events = events.map((e) => Map<String, dynamic>.from(e)).toList();
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load events (${res.statusCode}).';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't reach the server. Pull to refresh.";
        _loading = false;
      });
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
          'All events',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
        actions: [
          if (!_loading && _error.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kChipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_events.length}',
                    style: rf(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kBrand,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kBrand,
          onRefresh: _fetch,
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _kBrand, strokeWidth: 2.4),
      );
    }
    if (_error.isNotEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: _errorCard(),
          ),
        ],
      );
    }
    if (_events.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: _emptyState(),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _EventCard(event: _events[i]),
    );
  }

  Widget _emptyState() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _kChipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.event_busy_outlined,
              color: _kBrand, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'No events yet',
          style: rf(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'New events will show up here as they are scheduled.',
          textAlign: TextAlign.center,
          style: rf(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: _kMuted,
          ),
        ),
      ],
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 26),
          const SizedBox(height: 10),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: rf(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetch,
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
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final rawDate = event['date']?.toString() ?? '';
    final parsed = DateTime.tryParse(rawDate)
        ?.add(const Duration(hours: 5, minutes: 30));
    final day = parsed != null ? DateFormat('d').format(parsed) : '—';
    final month =
        parsed != null ? DateFormat('MMM').format(parsed).toUpperCase() : '';

    final name = event['name']?.toString() ?? 'Untitled event';
    final dept = event['department']?.toString() ??
        event['dept']?.toString() ??
        '';
    final time = event['time']?.toString() ?? '';
    final hours = event['hours']?.toString() ?? '';
    final remarks = event['remarks']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: rf(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _kBrand,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  month,
                  style: rf(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _kBrand,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: rf(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                  ),
                ),
                if (remarks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    remarks,
                    style: rf(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: _kMuted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (dept.isNotEmpty)
                      _MetaChip(
                          icon: Icons.apartment_outlined, label: dept),
                    if (time.isNotEmpty)
                      _MetaChip(
                          icon: Icons.schedule_outlined, label: time),
                    if (hours.isNotEmpty)
                      _MetaChip(
                        icon: Icons.timelapse_outlined,
                        label: '$hours ${hours == "1" ? "hr" : "hrs"}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kChipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _kBrand),
          const SizedBox(width: 6),
          Text(
            label,
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kBrand,
            ),
          ),
        ],
      ),
    );
  }
}
