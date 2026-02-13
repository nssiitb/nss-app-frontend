import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_service.dart';

class AuthService {
  static const String _userKey = 'default';

  Future<void> saveToken(Map<String, dynamic>? userData, String jwt) async {
    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData));

      await TokenService.saveToken(jwt);
    }
  }

  Future<Map<String, dynamic>?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString(_userKey);

    if (tokenString != null) {
      return jsonDecode(tokenString);
    }
    return null;
  }

  Future<String?> getJwt() async {
    return await TokenService.getToken();
  }

  Future<bool> isLoggedIn() async {
    String? jwt = await getJwt();
    return jwt != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await TokenService.deleteToken();
  }
}
