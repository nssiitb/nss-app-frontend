import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/widgets/login_form.dart' show rf;

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);
const Color _kBg = Color(0xFFF8F9FB);
const Color _kChipBg = Color(0xFFEEF2F7);

// Accent colours for your department's events
const Color _kMyDeptPrimary = Color(0xFFE65100);
const Color _kMyDeptBg = Color(0xFFFFF8F1);
const Color _kMyDeptBorder = Color(0xFFFFCC80);
const Color _kMyDeptChipBg = Color(0xFFFFE0B2);

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

  /// Checks if this event belongs to the student's department or is a common event.
  bool matchesUserDept(String userDept) {
    if (userDept.trim().isEmpty) return false;
    final d = department.toUpperCase();
    final u = userDept.toUpperCase();

    if (d == 'ALL' || d == 'GENERAL') return true;

    // Matches exact tokens (e.g. "SD" matches "CE,SD,ENS" or "SD" or "SOCIAL DEVELOPMENT")
    final tokens = d.split(RegExp(r'[,/|]')).map((s) => s.trim()).toList();
    if (tokens.contains(u)) return true;

    if (u == 'SD' && d.contains('SOCIAL DEVELOPMENT')) return true;
    if (u == 'ENS' && d.contains('ENVIRONMENTAL')) return true;
    if (u == 'EO' && d.contains('EDUCATIONAL')) return true;

    return false;
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
  String _myDepartment = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndEvents();
  }

  Future<void> _loadUserAndEvents() async {
    try {
      final data = await AuthService().getToken();
      final roll = data?['roll']?.toString() ?? '';
      
      if (roll.isNotEmpty) {
        // Direct ga progress API nundi user department theesukuntundhi
        final res = await ApiService.getVolunteerProgress(roll);
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          // Backend response lo department structure batti pick chey
          final dept = body['department'] ?? 
                       body['volunteer']?['department'] ?? 
                       data?['department'] ?? '';
          if (mounted) {
            setState(() {
              _myDepartment = dept.toString().trim();
            });
            debugPrint("Logged in Volunteer Department: $_myDepartment");
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user department: $e");
    }
    await _loadEvents();
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
                const SizedBox(height: 12),
                _legendIndicator(),
                const SizedBox(height: 20),
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
                        child: _EventCard(
                          event: e,
                          isMyDept: e.matchesUserDept(_myDepartment),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _legendItem(color: _kMyDeptPrimary, label: 'Your Department'),
          const SizedBox(width: 14),
          _legendItem(color: _kBrand, label: 'Other Events'),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: rf(fontSize: 11, fontWeight: FontWeight.w400, color: _kMuted),
        ),
      ],
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
            final dayEvents = events.cast<Event>();
            final hasMyDept = dayEvents.any((e) => e.matchesUserDept(_myDepartment));
            final hasOtherDept = dayEvents.any((e) => !e.matchesUserDept(_myDepartment));

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMyDept)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : _kMyDeptPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasOtherDept)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white70 : _kBrand,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
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
  final bool isMyDept;
  const _EventCard({required this.event, required this.isMyDept});

  @override
  Widget build(BuildContext context) {
    final cardBg = isMyDept ? _kMyDeptBg : Colors.white;
    final iconColor = isMyDept ? _kMyDeptPrimary : _kBrand;
    final iconBg = isMyDept ? _kMyDeptChipBg : _kChipBg;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isMyDept ? Border.all(color: _kMyDeptBorder, width: 1.2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A3B5A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMyDept)
                Container(
                  width: 5,
                  color: _kMyDeptPrimary,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.event_outlined,
                            size: 20, color: iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    event.name,
                                    style: rf(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _kInk,
                                    ),
                                  ),
                                ),
                                if (isMyDept)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _kMyDeptChipBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'YOUR DEPT',
                                      style: rf(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _kMyDeptPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
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
                                  label: event.department,
                                  isHighlighted: isMyDept,
                                ),
                                _MetaChip(
                                  icon: Icons.schedule_outlined,
                                  label: event.time,
                                ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHighlighted ? _kMyDeptChipBg : _kChipBg;
    final fg = isHighlighted ? _kMyDeptPrimary : _kBrand;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: rf(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
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