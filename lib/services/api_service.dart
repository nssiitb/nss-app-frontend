import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/IPv4_address.dart';

class ApiService {
  static final Map<String, String> _headers = {
    "Content-Type": "application/json"
  };

  // Auth
  static Future<http.Response> login(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/login'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> register(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/register'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  // Dashboard & Hours
  static Future<http.Response> getCompletedHours(String roll) async {
    return await http.post(
      Uri.parse('$baseURL/getHours'),
      headers: _headers,
      body: jsonEncode({"roll": roll}),
    );
  }

  // AA Functionality
  static Future<http.Response> startAttendanceWindow(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/address'),
      body: body, 
    );
  }

  // Events & Calendar
  static Future<http.Response> getEventsToday() async {
    return await http.get(Uri.parse('$baseURL/eventsToday'));
  }

  static Future<http.Response> getAllEvents() async {
    return await http.post(Uri.parse('$baseURL/allEvents'));
  }
  
  static Future<http.Response> getCalendarEvents() async {
    return await http.get(Uri.parse('$baseURL/calendar'));
  }

  // events.dart used localhost:3000/events - unifying to baseURL
  static Future<http.Response> getEvents() async { 
    return await http.get(Uri.parse('$baseURL/events'));
  }

  static Future<http.Response> addEvent(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/addEvent'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  // Attendance
  static Future<http.Response> markAttendance(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/attendance'),
      body: body,
    );
  }

  static Future<http.Response> getAttendanceByRoll(String roll) async {
    return await http.post(
      Uri.parse('$baseURL/attByRoll'),
      headers: _headers,
      body: jsonEncode({"roll": roll}),
    );
  }

  // Volunteers
  static Future<http.Response> getAllVolunteers() async {
    return await http.get(Uri.parse('$baseURL/sendVolunteers'));
  }
}
