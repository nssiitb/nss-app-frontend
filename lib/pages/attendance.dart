import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/global/IPv4_address.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/global/uuid.dart';

////////////
class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Map<String, dynamic>> activities = [];
  Map<String, dynamic>? selectedActivity;
  final _formKey = GlobalKey<FormState>();
  // 1. Add a loading state variable
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final res = await http.get(Uri.parse(baseURL + '/eventsToday'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final events = data['events'] as List;
        setState(() {
          activities = List<Map<String, dynamic>>.from(events);
        });
      } else {
        print("Error fetching events: ${res.statusCode}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  void markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await GlobalAuthHelper.fetchToken();
      String? name = GlobalAuthHelper.globalname;
      String? roll = GlobalAuthHelper.globalrollNo;
      String? dept = GlobalAuthHelper.globaldept;
      String timeStamp =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

      if (selectedActivity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select an event first.")),
        );
        // Important: Stop execution if no activity is selected
        return;
      }

      final eventName = selectedActivity?['name'];
      final aaRoll = selectedActivity?['AA'];

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            "Location services are turned off.\nPlease enable location permission to continue.");
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          throw Exception(
              "Location permission denied forever. To continue, please open your phone’s Settings > Apps > NSS IITB > Permissions and enable Location access.");
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();

      String fingerprint = await DeviceIDHelper.getDeviceId();

      print(latitude);
      print(longitude);

      var response = await http.post(
        Uri.parse(baseURL + '/attendance'),
        body: {
          "_roll_": roll,
          "_name_": name,
          "_timestamp_": timeStamp,
          "_latitude_": latitude,
          "_longitude_": longitude,
          "_department_": dept,
          "_status_": "1",
          "_message_": eventName,
          "_fingerprint_": fingerprint,
          "aa_roll": aaRoll,
        },
      );

      final resData = json.decode(response.body);
      final message = resData['message'] ?? 'Unknown response';

      print(message);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print("Attendance error: $e");

      // Extract clean message for SnackBar
      String errorMessage;

      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      // 3. Set loading to false in the 'finally' block to ensure it always runs
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Please select your activity and mark your attendance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Raleway",
                        color: Color(0xFF444444),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 25),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: InputDecoration(
                        labelText: 'Activity',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: activities.map((event) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: event,
                          child: Text(event['name']),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => selectedActivity = val),
                      validator: (val) =>
                          val == null ? 'Please select an activity' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFF6A5AE0),
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                        // 4. Disable button when _isLoading is true
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  markAttendance();
                                }
                              },
                        // 5. Change the button's child to show a loader
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              )
                            : const Text(
                                'Mark Attendance',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
