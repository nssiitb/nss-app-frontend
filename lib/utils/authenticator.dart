import 'dart:convert'; // Import this for jsonEncode
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'default';

  Future<void> saveToken(Map<String, dynamic>? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      String tokenString = jsonEncode(token); // Convert Map to String
      await prefs.setString(_tokenKey, tokenString);
    }
  }

  // Check if token exists (logged in)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString(_tokenKey);
    return tokenString != null; // Returns true if token exists
  }

  Future<Map<String, dynamic>?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString(_tokenKey);
    if (tokenString != null) {
      return jsonDecode(tokenString); // Convert JSON string back to Map
    }
    return null;
  }

  // Log out by clearing the token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
