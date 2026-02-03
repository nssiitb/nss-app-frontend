import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIDHelper {
  static const _key = 'device_uuid';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_key);

    if (storedId != null) return storedId;

    // Generate and store a new UUID
    String newId = const Uuid().v4(); // Generates a random UUID
    await prefs.setString(_key, newId);
    return newId;
  }
}
