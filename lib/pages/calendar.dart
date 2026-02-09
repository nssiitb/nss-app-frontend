import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nssapp/services/api_service.dart';
import 'dart:convert';
import 'dart:async';

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

  // Factory constructor to create an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    // Basic validation
    if (json['name'] == null || json['date'] == null) {
      throw const FormatException("Missing required fields in event JSON");
    }

    final DateTime parsedDate = DateTime.parse(json['date']);

    /*
    return Event(
      name: json['name'],
      description: json['remarks'] ?? '',
      date: parsedDate.add(const Duration(
          hours: 5, minutes: 30)), // Use the parsed DateTime object
      time: DateFormat.jm().format(parsedDate), // Format the time for display
      hours: json['hours'] is int
          ? json['hours']
          : int.tryParse(json['hours'].toString()) ?? 0,
      department: json['department'] ?? 'General',
    );
    */

    return Event(
      name: json['name'],
      description: json['remarks'] ?? '',
      date: parsedDate.add(const Duration(
          hours: 5, minutes: 30)), // Use the parsed DateTime object
      // Check if time is explicitly provided, otherwise format the ADJUSTED date
      time: json['time'] ?? DateFormat.jm().format(parsedDate.add(const Duration(hours: 5, minutes: 30))), 
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
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> _eventsByDate = {};
  List<Event> _selectedEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getCalendarEvents()
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final events = decoded.map((json) => Event.fromJson(json)).toList();
        print(decoded);
        final Map<DateTime, List<Event>> eventsByDate = {};
        for (var event in events) {
          final dateKey =
              DateTime.utc(event.date.year, event.date.month, event.date.day);
          // print(dateKey);
          if (eventsByDate[dateKey] == null) {
            eventsByDate[dateKey] = [];
          }
          eventsByDate[dateKey]!.add(event);
        }
        setState(() {
          _eventsByDate = eventsByDate;
          _selectedEvents = _getEventsForDay(_selectedDay!);
        });
      } else {
        setState(() {
          _errorMessage =
              "Failed to load events. Server returned status code ${response.statusCode}";
        });
      }
    } on TimeoutException {
      setState(() {
        _errorMessage = "The request timed out. Please try again later.";
      });
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = "Failed to parse event data: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateKey = DateTime.utc(day.year, day.month, day.day);
    return _eventsByDate[dateKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ralewayTheme = GoogleFonts.ralewayTextTheme(textTheme).apply(
      bodyColor: const Color(0xFF4A4E69),
      displayColor: const Color(0xFF4A4E69),
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: ralewayTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Events Calendar',
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCalendar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF4A4E69)))
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                  color: Colors.red.shade700, fontSize: 16)),
                        ))
                      : _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF22223B),
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: Color(0xFF4A4E69)),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: Color(0xFF4A4E69)),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.raleway(
              fontWeight: FontWeight.w600, color: const Color(0xFF9A8C98)),
          weekendStyle: GoogleFonts.raleway(
              fontWeight: FontWeight.w600, color: const Color(0xFF9A8C98)),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: const Color(0xFFC9ADA7).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4A4E69),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF9A8C98),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: GoogleFonts.raleway(),
          weekendTextStyle: GoogleFonts.raleway(),
          todayTextStyle: GoogleFonts.raleway(color: const Color(0xFF22223B)),
          selectedTextStyle: GoogleFonts.raleway(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Text(
          "No events for this day.",
          style: GoogleFonts.raleway(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.raleway(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF22223B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: GoogleFonts.raleway(
                        fontSize: 14, color: const Color(0xFF6D6D6D)),
                  ),
                  const Divider(
                      height: 24, thickness: 1, color: Color(0xFFF2E9E4)),
                  _buildEventDetailRow(
                      Icons.apartment_outlined, event.department),
                  const SizedBox(height: 8),
                  _buildEventDetailRow(Icons.schedule_outlined,
                      '${event.time} (${event.hours} ${event.hours > 1 ? "hrs" : "hr"})'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9A8C98)),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.raleway(
                fontSize: 14, color: const Color(0xFF4A4E69))),
      ],
    );
  }
}
