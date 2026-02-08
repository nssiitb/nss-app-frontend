import 'package:flutter/material.dart';
import 'package:nssapp/services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class Allevents extends StatefulWidget {
  const Allevents({super.key});

  @override
  State<Allevents> createState() => _AlleventsState();
}

class _AlleventsState extends State<Allevents> {
  List<Map<String, dynamic>> activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final res = await ApiService.getAllEvents();
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final events = data['events'] as List;

        events.sort((a, b) {
          // Safely parse dates, providing a fallback for invalid/null strings
          final dateA = DateTime.tryParse(a['date'] ?? '');
          final dateB = DateTime.tryParse(b['date'] ?? '');

          // Handle cases where dates might be null or unparseable
          if (dateA == null && dateB == null) return 0;
          if (dateA == null)
            return 1; // Treat nulls as "greater" to push them to the end
          if (dateB == null) return -1; // Treat nulls as "greater"

          // Compare the two dates. Closest (smallest) date will come first.
          return dateA.compareTo(dateB);
        });

        if (mounted) {
          setState(() {
            activities =
                events.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        // Handle server errors
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print("Error fetching data: ${res.statusCode}");
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a light grey background for better contrast with the white cards
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text(
          "All Events",
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101828),
        elevation: 1, // Subtle shadow for the app bar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : activities.isEmpty
              ? Center(
                  child: Text(
                    "No events found.",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : ListView.builder(
                  // Add padding to the list itself
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: activities.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> event = activities[index];
                    final rawDate = event['date'];
                    // DateTime converts date saved to UTC which is -5:30 from IST
                    final parsedDate = DateTime.tryParse(rawDate ?? '')
                      ?.add(const Duration(hours: 5, minutes: 30));


                    // Date formatting for the card
                    final day = parsedDate != null
                        ? DateFormat('d').format(parsedDate)
                        : '';
                    final month = parsedDate != null
                        ? DateFormat('MMM').format(parsedDate).toUpperCase()
                        : '';

                    return Container(
                      // Use symmetric margin for consistent spacing
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Section
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFFF0F4FF), // Light blue accent
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color: Color(0xFF344055),
                                    ),
                                  ),
                                  Text(
                                    month,
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF344055),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['name'] ?? 'Untitled Event',
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event['dept'] ?? 'No Department',
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFF667085),
                                    ),
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  _EventDetailRow(
                                    icon: Icons.access_time_rounded,
                                    text: "Time: ${event['time'] ?? 'N/A'}",
                                  ),
                                  _EventDetailRow(
                                    icon: Icons.hourglass_bottom_rounded,
                                    text: "Hours: ${event['hours'] ?? '0'}",
                                  ),
                                  // Conditionally show remarks if they exist
                                  if (event['remarks'] != null &&
                                      event['remarks'].isNotEmpty)
                                    _EventDetailRow(
                                      icon: Icons.comment_outlined,
                                      text: event['remarks'],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Helper widget to keep the main build method clean
class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 16),
          const SizedBox(width: 8),
          // Use Expanded to allow text to wrap gracefully
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.grey.shade800,
                fontSize: 14,
                height: 1.4, // Improved line spacing for readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}
