import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

const Map<String, String> _kDeptNames = {
  'CE': 'Campus Engagement',
  'EO': 'Educational Outreach',
  'SD': 'Social Development',
  'EnS': 'Environment and Sustainability',
};

class Volunteer {
  final String roll;
  final String name;
  final String mobile;
  final String dept;
  final String email;
  final int hours;

  Volunteer({
    required this.roll,
    required this.name,
    required this.mobile,
    required this.dept,
    required this.email,
    required this.hours,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      roll: json['roll']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      dept: json['dept']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      hours: json['hours'] is int
          ? json['hours']
          : int.tryParse(json['hours']?.toString() ?? '0') ?? 0,
    );
  }
}

class Volunteerlist extends StatefulWidget {
  const Volunteerlist({super.key});

  @override
  State<Volunteerlist> createState() => _VolunteerlistState();
}

class _VolunteerlistState extends State<Volunteerlist> {
  final _searchController = TextEditingController();

  List<Volunteer> _all = [];
  List<Volunteer> _filtered = [];
  String _selectedDept = 'All';
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _fetch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiService.getAllVolunteers();
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        if (!mounted) return;
        setState(() {
          _all = data
              .map((j) => Volunteer.fromJson(Map<String, dynamic>.from(j)))
              .toList();
          _loading = false;
        });
        _applyFilters();
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load volunteers (${res.statusCode}).';
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

  void _applyFilters() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _all.where((v) {
        final matchesQuery =
            v.name.toLowerCase().contains(q) || v.roll.toLowerCase().contains(q);
        final matchesDept = _selectedDept == 'All' || v.dept == _selectedDept;
        return matchesQuery && matchesDept;
      }).toList();
    });
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
          'Volunteers',
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
                    '${_filtered.length}',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  _searchField(),
                  const SizedBox(height: 12),
                  _deptFilter(),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _kBrand,
                onRefresh: _fetch,
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        style: rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
        cursorColor: _kBrand,
        decoration: InputDecoration(
          hintText: 'Search by name or roll',
          hintStyle: rf(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: _kMuted,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 18, right: 12),
            child: Icon(Icons.search, size: 20, color: _kMuted),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _deptFilter() {
    final items = <String>['All', ..._kDeptNames.keys];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final code = items[i];
          final label = code == 'All' ? 'All' : code;
          final selected = code == _selectedDept;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDept = code);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _kBrand : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F1A3B5A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: rf(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : _kInk,
                ),
              ),
            ),
          );
        },
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
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: _errorCard(),
          ),
        ],
      );
    }
    if (_filtered.isEmpty) {
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _VolunteerCard(volunteer: _filtered[i]),
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
          child: const Icon(Icons.group_off_outlined,
              color: _kBrand, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'No volunteers found',
          style: rf(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Try a different search or department filter.',
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

class _VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  const _VolunteerCard({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    final initial =
        volunteer.name.isNotEmpty ? volunteer.name[0].toUpperCase() : 'V';
    final deptName =
        _kDeptNames[volunteer.dept] ?? volunteer.dept;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A3B5A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: rf(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _kBrand,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volunteer.name.isEmpty ? 'Unnamed' : volunteer.name,
                  style: rf(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${volunteer.roll}  ·  $deptName',
                  style: rf(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: _kMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${volunteer.hours} hrs',
              style: rf(
                fontSize: 12,
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
