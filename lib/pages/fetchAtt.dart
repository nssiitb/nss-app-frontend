import 'package:flutter/material.dart';
import 'package:nssapp/utils/routes.dart';

class Fetchatt extends StatelessWidget {
  const Fetchatt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back, size: 24, color: Color(0xFF343A40)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'View Attendance',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Raleway",
            fontWeight: FontWeight.bold,
            color: Color(0xFF343A40),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(height: 28),
                              Expanded(
                                child: _card(
                                  context,
                                  title: "Attendance by event",
                                  subtitle:
                                      "Get the list of volunteers who attended a particular event.",
                                  icon: Icons.event_available,
                                  backgroundColor: const Color(0xFFD7F4C1),
                                  onTap: () {
                                    // Navigator.pushNamed(
                                    //     context, Routes.attbyEvent);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Upcoming feature"),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Expanded(
                                child: _card(
                                  context,
                                  title: "Attendance by Roll Number",
                                  subtitle:
                                      "Get the attendance data for a particular student",
                                  icon: Icons.numbers_outlined,
                                  backgroundColor: const Color(0xFFF2DDFB),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.attbyRoll);
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Expanded(
                                child: _card(
                                  context,
                                  title: "Attendance by department",
                                  subtitle:
                                      "Get the attendance data for a particular department",
                                  icon: Icons.calendar_month_outlined,
                                  backgroundColor: const Color(0xFFDADFFF),
                                  onTap: () {
                                    // Navigator.pushNamed(
                                    //     context, Routes.attbyDept);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Upcoming feature"),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, fontFamily: "Raleway"),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              size: 40,
              color: Colors.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
