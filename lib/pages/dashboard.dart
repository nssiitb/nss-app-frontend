import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nssapp/utils/authenticator.dart'; // Assuming authenticator is in utils
import 'package:nssapp/global/IPv4_address.dart'; // Assuming baseURL is here

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // AuthService instance to get user data
  final AuthService _authService = AuthService();

  // State variables to hold fetched data and loading status
  int? _completedHours;
  final int _totalHours = 40;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Fetch the data when the widget is first created
    _fetchCompletedHours();
  }

  /// Fetches the completed hours for the logged-in volunteer from the backend.
  Future<void> _fetchCompletedHours() async {
    try {
      final userData = await _authService.getToken();

      if (userData == null || userData['roll'] == null) {
        setState(() {
          _errorMessage =
              'Could not find user information. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final String rollNumber = userData['roll'];
      var reqBody = {"roll": rollNumber};

      // Corrected the URL parsing
      var response = await http.post(
        Uri.parse('$baseURL/getHours'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['hours'] != null) {
          setState(() {
            _completedHours = jsonResponse['hours'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? 'Failed to get data.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        _completedHours != null ? _completedHours! / _totalHours : 0.0;
    int remainingHours =
        _completedHours != null ? _totalHours - _completedHours! : _totalHours;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // A clean, off-white background
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back, size: 24, color: Color(0xFF343A40)),
        ),
        backgroundColor: Colors.transparent, // Makes app bar blend with body
        elevation: 0,
        title: const Text(
          'My Progress',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Raleway",
            fontWeight: FontWeight.bold,
            color: Color(0xFF343A40), // Dark grey for text
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4C6EF5)))
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(_errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16)))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(), // Spacer
                        // Main progress circle
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 12,
                                  backgroundColor: const Color(0xFFE9ECEF),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4C6EF5)),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_completedHours ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 68,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF343A40),
                                      ),
                                    ),
                                    const Text(
                                      'Hours Done',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF868E96),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Remaining hours text
                        if (_completedHours != null)
                          Text(
                            remainingHours > 0
                                ? "You need $remainingHours more hours to qualify."
                                : "Congratulations! You've completed all hours.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF495057),
                            ),
                          ),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9ECEF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "A minimum of 40 hours must be completed to be eligible for the PP grade, comprising 36 hours of NSS activities and 4 hours of Wellness activities.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF495057),
                              height: 1.5, // Improved line spacing
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
