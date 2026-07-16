import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart'
    show PillField, PillButton, rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

const List<_Dept> _kDepartments = [
  _Dept('CE', 'Campus Engagement'),
  _Dept('EO', 'Educational Outreach'),
  _Dept('SD', 'Social Development'),
  _Dept('EnS', 'Environment and Sustainability'),
];

class AddEvents extends StatefulWidget {
  const AddEvents({super.key});

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  final _name = TextEditingController();
  final _hours = TextEditingController();
  final _aa = TextEditingController();
  final _remarks = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  _Dept? _department;

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _hours.dispose();
    _aa.dispose();
    _remarks.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kBrand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kInk,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kBrand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kInk,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _dateLabel() => _date == null
      ? 'Pick a date'
      : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';

  String _timeLabel() {
    if (_time == null) return 'Pick a time';
    final h = _time!.hour.toString().padLeft(2, '0');
    final m = _time!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _validate() {
    if (_name.text.trim().isEmpty) {
      _snack('Please enter an event name.');
      return false;
    }
    if (_date == null) {
      _snack('Pick a date.');
      return false;
    }
    if (_time == null) {
      _snack('Pick a time.');
      return false;
    }
    final hrs = int.tryParse(_hours.text.trim());
    if (hrs == null || hrs <= 0) {
      _snack('Enter valid hours.');
      return false;
    }
    if (_aa.text.trim().isEmpty) {
      _snack("Enter the Activity Associate's roll.");
      return false;
    }
    if (_department == null) {
      _snack('Select a department.');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_submitting) return;
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      final body = {
        'name': _name.text.trim(),
        'date':
            '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
        'time':
            '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00',
        'hours': _hours.text.trim(),
        'AA': _aa.text.trim(),
        'remarks': _remarks.text.trim(),
        'department': _department!.label,
      };
      final res = await ApiService.addEvent(body);
      final json = jsonDecode(res.body);
      _snack(json['message']?.toString() ?? 'Event saved.');
      if (mounted &&
          (res.statusCode == 200 || res.statusCode == 201)) {
        _clear();
      }
    } catch (_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _clear() {
    setState(() {
      _name.clear();
      _hours.clear();
      _aa.clear();
      _remarks.clear();
      _date = null;
      _time = null;
      _department = null;
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
          'New event',
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
                child: const Icon(Icons.add_circle_outline,
                    color: _kBrand, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Create a new event',
                style: rf(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Volunteers will see this on their calendar.',
                style: rf(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _kMuted,
                ),
              ),
              const SizedBox(height: 28),
              PillField(
                controller: _name,
                hintText: 'Event name',
                prefixIcon: Icons.event_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _tapField(
                      icon: Icons.calendar_today_outlined,
                      label: _dateLabel(),
                      dim: _date == null,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _tapField(
                      icon: Icons.access_time_outlined,
                      label: _timeLabel(),
                      dim: _time == null,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PillField(
                controller: _hours,
                hintText: 'Hours',
                prefixIcon: Icons.timelapse_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const SizedBox(height: 16),
              PillField(
                controller: _aa,
                hintText: 'Activity Associate roll',
                prefixIcon: Icons.person_outline,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 16),
              _deptDropdown(),
              const SizedBox(height: 16),
              _multilineField(),
              const SizedBox(height: 28),
              PillButton(
                label: 'Create Event',
                loading: _submitting,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tapField({
    required IconData icon,
    required String label,
    required bool dim,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
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
        child: Row(
          children: [
            Icon(icon, size: 20, color: _kMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: rf(
                  fontSize: 15,
                  fontWeight: dim ? FontWeight.w300 : FontWeight.w400,
                  color: dim ? _kMuted : _kInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deptDropdown() {
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<_Dept>(
              value: _department,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: _kMuted),
              dropdownColor: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(20),
              hint: Row(
                children: [
                  const Icon(Icons.apartment_outlined,
                      size: 20, color: _kMuted),
                  const SizedBox(width: 12),
                  Text(
                    'Department',
                    style: rf(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
              style:
                  rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
              selectedItemBuilder: (ctx) => _kDepartments
                  .map((d) => Row(
                        children: [
                          const Icon(Icons.apartment_outlined,
                              size: 20, color: _kBrand),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              d.label,
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
              items: _kDepartments
                  .map((d) => DropdownMenuItem<_Dept>(
                        value: d,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            d.label,
                            style: rf(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: _kInk,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _department = v),
            ),
          ),
        ),
      ),
    );
  }

  Widget _multilineField() {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _remarks,
        maxLines: 4,
        minLines: 3,
        maxLength: 200,
        style: rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
        cursorColor: _kBrand,
        decoration: InputDecoration(
          hintText: 'Description (optional)…',
          hintStyle: rf(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: _kMuted,
          ),
          counterStyle: rf(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: _kMuted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _Dept {
  final String code;
  final String label;
  const _Dept(this.code, this.label);
}
