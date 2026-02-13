import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/widgets/app_drawer.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/services/api_service.dart';

class Homeaa extends StatefulWidget {
  final String name;
  const Homeaa({super.key, required this.name});

  @override
  State<Homeaa> createState() => _HomeaaState();
}

class _HomeaaState extends State<Homeaa> {
  bool _isLoading = false;

  void startWindow() async {
    if (_isLoading) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String? roll = GlobalAuthHelper.globalrollNo;

      String timeStamp =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled");
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            "Location permissions are permanently denied. Please enable them from settings.");
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();

      var response = await ApiService.startAttendanceWindow({
        "_roll_": roll,
        "_name_": widget.name,
        "_timestamp_": timeStamp,
        "_latitude_": latitude,
        "_longitude_": longitude,
      });

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Started Attendance Window!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start window: ${response.body}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: IconButton(
              icon: const Icon(Icons.person_outline,
                  color: Color(0xFF344055), size: 28),
              onPressed: () {
                Navigator.pushNamed(context, Routes.profileRoute);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, ${widget.name}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: "Raleway",
                color: Color(0xFF344055),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Welcome back",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF344055),
                  fontFamily: "Raleway"),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    color: const Color(0xFFDCC9F9),
                    circleContent: const Icon(Icons.calendar_month_outlined,
                        color: Color(0xFF344055)),
                    title: "Events this month",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.allEvents);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    color: const Color(0xFFC7E4F8),
                    circleContent:
                        const Icon(Icons.add, color: Color(0xFF344055)),
                    title: "Add event",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.addEvent);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 2. UPDATE THE DASHBOARD CARD'S UI
            DashboardCard(
              color: const Color.fromARGB(255, 176, 241, 255),
              // Show a progress indicator when loading, otherwise show the icon
              circleContent: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF344055),
                      ),
                    )
                  : const Icon(Icons.watch_later_outlined,
                      color: Color(0xFF344055)),
              title: "Start Attendance Window",
              fullWidth: true,
              onTap: () async {
                // The function itself now prevents multiple clicks
                await GlobalAuthHelper.fetchToken();
                startWindow();
              },
            ),
            const SizedBox(height: 16),
            DashboardCard(
              color: const Color(0xFFD5F7C6),
              circleContent: const Icon(Icons.group, color: Color(0xFF344055)),
              title: "View Volunteer List",
              fullWidth: true,
              onTap: () {
                Navigator.pushNamed(context, Routes.volListRoute);
              },
            ),
            const SizedBox(height: 16),
            DashboardCard(
              color: const Color(0xFFD5F7C6),
              circleContent:
                  const Icon(Icons.dataset, color: Color(0xFF344055)),
              title: "View Attendance Data",
              fullWidth: true,
              onTap: () {
                Navigator.pushNamed(context, Routes.fetchAtt);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Color color;
  final Widget circleContent;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  const DashboardCard({
    super.key,
    required this.color,
    required this.circleContent,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // The CircleAvatar is now a flexible Widget
            CircleAvatar(
              backgroundColor:
                  Colors.transparent, // Background is handled by container
              radius: 20,
              child: circleContent,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF344055),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
