import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GlobalAuthHelper {
  static String? globalrollNo;
  static String? globalname;
  static String? globalemail;
  static String? globalphone;
  static String? globaldept;

  static Future<bool> fetchToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('default');

    if (tokenString != null) {
      final token = jsonDecode(tokenString);
      globalrollNo = token['roll'];
      globalname = token['name'];
      globalemail = token['email'];
      globalphone = token['mobile'];
      globaldept = token['dept'];
      return true;
    }
    return false;
  }
}