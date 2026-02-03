import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

List<String> months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Demo(), 
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});


  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<dynamic> events = [];  
  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

 Future<void> fetchEvents() async {
  const String url = 'http://localhost:3000/events'; 
  try {
    final response = await http.get(Uri.parse(url));
    // Log the response body to verify the JSON data
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        events = jsonResponse; // Update the state with fetched events
      });
    } else {
      print('Failed to fetch events: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching events: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: const Color(0xFF01013B),
          title: const Padding(
            padding:  EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  size: 48.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
         
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color(0xFF01013B),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  12, 
                  (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: currentMonth - 1 == index
                          ? Colors.white
                          : const Color.fromARGB(255, 100, 95, 122),
                      child: Container(
                        width: 100,
                        height: 120,
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: currentMonth - 1 == index
                                ? const Color(0xFF02023C)
                                : Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

      
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: List.generate(events.length, (index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: const Color(0xFFEEEEEF),
                    child: Container(
                      width: screenWidth * 0.99,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          
                          Text(
                            event['EVENT NAME'] ?? 'No Name', 
                            style: const TextStyle(
                              color: Color(0xFF02023C),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(
                            color: Color(0xFF676565),
                            thickness: 2,
                            indent: 40,
                            endIndent: 40,
                          ),
                         
                          Text(
                            event['DEPARTMENT NAME'] ?? 'No Department', 
                            style: const TextStyle(
                              color:Color(0xFF2A1B7A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              event['Content'] ?? 'No Content', 
                              style: const TextStyle(
                                color: Color(0xFF1D0303),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Color(0xFF676565),
                            thickness: 2,
                            indent: 40,
                            endIndent: 40,
                          ),
                         
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'VENUE: ${event['VENUE'] ?? 'No Venue'}',
                                style: const TextStyle(
                                  color: Color(0xFF2A1B7A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'TIMINGS: ${event['Timings'] ?? 'No Timings'}', 
                                style: const TextStyle(
                                  color: Color(0xFF2A1B7A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          
                          Text(
                            'DATE: ${event['Date'] ?? 'No Date'}', 
                            style: const TextStyle(
                              color: Color(0xFF2A1B7A),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
