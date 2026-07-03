import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nssapp/global/IPv4_address.dart';
import '../utils/authenticator.dart';

class ApiService {
  static final Map<String, String> _headers = {
    "Content-Type": "application/json"
  };

  static Future<Map<String, String>> _authHeaders() async {
    String? token = await AuthService().getJwt();

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
  }

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
  // static Future<http.Response> getCompletedHours(String roll) async {
  //   return await http.post(
  //     Uri.parse('$baseURL/getHours'),
  //     headers: _headers,
  //     body: jsonEncode({"roll": roll}),
  //   );
  // }
  static Future<http.Response> getCompletedHours(String roll) async {
    return await http.post(
      Uri.parse('$baseURL/getHours'),
      headers: await _authHeaders(),
      body: jsonEncode({"roll": roll}),
    );
  }

  // AA Functionality
  // static Future<http.Response> startAttendanceWindow(
  //     Map<String, dynamic> body) async {
  //   return await http.post(
  //     Uri.parse('$baseURL/address'),
  //     body: body,
  //   );
  // }
  static Future<http.Response> startAttendanceWindow(
      Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/address'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
  }

  // Events & Calendar
  static Future<http.Response> getEventsToday() async {
    // return await http.get(Uri.parse('$baseURL/eventsToday'));
    return await http.get(
      Uri.parse("$baseURL/eventsToday"),
      headers: await _authHeaders(),
    );
  }

  static Future<http.Response> getAllEvents() async {
    // return await http.post(Uri.parse('$baseURL/allEvents'));
    return await http.get(
      Uri.parse("$baseURL/allEvents"),
      headers: await _authHeaders(),
    );
  }

  static Future<http.Response> getCalendarEvents() async {
    // return await http.get(Uri.parse('$baseURL/calendar'));
    return await http.get(
      Uri.parse("$baseURL/calendar"),
      headers: await _authHeaders(),
    );
  }

  // events.dart used localhost:3000/events - unifying to baseURL
  static Future<http.Response> getEvents() async {
    // return await http.get(Uri.parse('$baseURL/events'));
    return await http.get(
      Uri.parse("$baseURL/events"),
      headers: await _authHeaders(),
    );
  }

  // static Future<http.Response> addEvent(Map<String, dynamic> body) async {
  //   return await http.post(
  //     Uri.parse('$baseURL/addEvent'),
  //     headers: _headers,
  //     body: jsonEncode(body),
  //   );
  // }
  static Future<http.Response> addEvent(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/addEvent'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
  }

  // Attendance
  // static Future<http.Response> markAttendance(Map<String, dynamic> body) async {
  //   return await http.post(
  //     Uri.parse('$baseURL/attendance'),
  //     body: body,
  //   );
  // }
  static Future<http.Response> markAttendance(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseURL/attendance'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
  }

  // static Future<http.Response> getAttendanceByRoll(String roll) async {
  //   return await http.post(
  //     Uri.parse('$baseURL/attByRoll'),
  //     headers: _headers,
  //     body: jsonEncode({"roll": roll}),
  //   );
  // }
  static Future<http.Response> getAttendanceByRoll(String roll) async {
    return await http.post(
      Uri.parse('$baseURL/attByRoll'),
      headers: await _authHeaders(),
      body: jsonEncode({"roll": roll}),
    );
  }

  // Volunteers
  // static Future<http.Response> getAllVolunteers() async {
  //   return await http.get(Uri.parse('$baseURL/sendVolunteers'));
  // }
  static Future<http.Response> getAllVolunteers() async {
    return await http.get(
      Uri.parse('$baseURL/sendVolunteers'),
      headers: await _authHeaders(),
    );
  }
  static Future<http.Response> forgotPassword(String email) async{
    return await http.post(
       Uri.parse('$baseURL/forgot-password'),
       headers: _headers,
       body: jsonEncode({
         "email": email,
       }),
    );
  
  }
}
