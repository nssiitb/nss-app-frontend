import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

class Event {
  final String name;
  final String description;
  final DateTime date;
  final String time;
  final int hours;
  final String department;

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.hours,
    required this.department,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null || json['date'] == null) {
      throw const FormatException("Missing required fields in event JSON");
    }
    final parsedDate = DateTime.parse(json['date']);
    final adjusted = parsedDate.add(const Duration(hours: 5, minutes: 30));
    return Event(
      name: json['name'],
      description: json['remarks'] ?? '',
      date: adjusted,
      time: json['time'] ?? DateFormat.jm().format(adjusted),
      hours: json['hours'] is int
          ? json['hours']
          : int.tryParse(json['hours'].toString()) ?? 0,
      department: json['department'] ?? 'General',
    );
  }
}

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Event>> _eventsByDate = {};
  List<Event> _selectedEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getCalendarEvents()
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final events = decoded.map((j) => Event.fromJson(j)).toList();
        final Map<DateTime, List<Event>> eventsByDate = {};
        for (final event in events) {
          final key =
              DateTime.utc(event.date.year, event.date.month, event.date.day);
          (eventsByDate[key] ??= []).add(event);
        }
        if (!mounted) return;
        setState(() {
          _eventsByDate = eventsByDate;
          _selectedEvents = _getEventsForDay(_selectedDay);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              "Failed to load events (${response.statusCode}).";
          _isLoading = false;
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage = "The request timed out. Pull to refresh.";
        _isLoading = false;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Couldn't parse event data: ${e.message}";
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Couldn't reach the server. Pull to refresh.";
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _eventsByDate[key] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (isSameDay(_selectedDay, selectedDay)) return;
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
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
          'Events',
          style: rf(fontSize: 18, fontWeight: FontWeight.w600, color: _kInk),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kBrand,
          onRefresh: _loadEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _customHeader(),
                _calendarCard(),
                const SizedBox(height: 24),
                _selectedDayHeader(),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: _kBrand, strokeWidth: 2.4),
                    ),
                  )
                else if (_errorMessage.isNotEmpty)
                  _errorCard()
                else if (_selectedEvents.isEmpty)
                  _emptyState()
                else
                  ..._selectedEvents.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: e),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A3B5A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2027, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
        onDaySelected: _onDaySelected,
        onPageChanged: (fd) => setState(() => _focusedDay = fd),
        rowHeight: 44,
        daysOfWeekHeight: 32,
        headerVisible: false,
        // Force 6 rows regardless of month length so the card doesn't
        // shrink/grow between Feb (4 rows) and 31-day months.
        sixWeekMonthsEnforced: true,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: rf(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kMuted,
            letterSpacing: 1.2,
          ),
          weekendStyle: rf(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kMuted,
            letterSpacing: 1.2,
          ),
          dowTextFormatter: (date, _) =>
              DateFormat.E().format(date).substring(0, 3).toUpperCase(),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            final isSelected = isSameDay(day, _selectedDay);
            return Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : _kBrand,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(2),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kBrand, width: 1.4),
          ),
          selectedDecoration: const BoxDecoration(
            color: _kBrand,
            shape: BoxShape.circle,
          ),
          defaultTextStyle:
              rf(fontSize: 14, fontWeight: FontWeight.w400, color: _kInk),
          weekendTextStyle:
              rf(fontSize: 14, fontWeight: FontWeight.w400, color: _kMuted),
          todayTextStyle: rf(
              fontSize: 14, fontWeight: FontWeight.w600, color: _kBrand),
          selectedTextStyle:
              rf(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          disabledTextStyle:
              rf(fontSize: 14, fontWeight: FontWeight.w300, color: _kMuted),
        ),
      ),
    );
  }

  Widget _customHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM').format(_focusedDay),
            style: rf(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _kInk,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_focusedDay.year}',
            style: rf(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: _kMuted,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          _NavChip(
            icon: Icons.chevron_left,
            onTap: () => setState(() {
              _focusedDay =
                  DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
            }),
          ),
          const SizedBox(width: 8),
          _NavChip(
            icon: Icons.chevron_right,
            onTap: () => setState(() {
              _focusedDay =
                  DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _selectedDayHeader() {
    final count = _selectedEvents.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            DateFormat('EEE, d MMM').format(_selectedDay),
            style: rf(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _kInk,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (!_isLoading && _errorMessage.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count == 0
                  ? 'No events'
                  : '$count ${count == 1 ? "event" : "events"}',
              style: rf(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _kBrand,
                letterSpacing: 0.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.event_available_outlined,
                color: _kBrand, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            'No events for this day',
            style: rf(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick another date to see scheduled activities.',
            textAlign: TextAlign.center,
            style: rf(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: _kMuted,
            ),
          ),
        ],
      ),
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
            _errorMessage,
            textAlign: TextAlign.center,
            style: rf(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF991B1B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadEvents,
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
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.event_outlined,
                size: 20, color: _kBrand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: rf(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _kInk,
                  ),
                ),
                if (event.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: rf(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: _kMuted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                        icon: Icons.apartment_outlined,
                        label: event.department),
                    _MetaChip(
                        icon: Icons.schedule_outlined, label: event.time),
                    _MetaChip(
                      icon: Icons.timelapse_outlined,
                      label:
                          '${event.hours} ${event.hours > 1 ? "hrs" : "hr"}',
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

class _NavChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kChipBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 20, color: _kInk),
        ),
      ),
    );
  }
}
