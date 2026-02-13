import 'package:flutter/material.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_drawer.dart';

class Homevolunteer extends StatelessWidget {
  final String name;
  const Homevolunteer({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // toolbarHeight: 96,
      ),
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
                        const SizedBox(height: 12),
                        Text(
                          "Hi, $name",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF444444),
                              fontFamily: "Raleway"),
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _homeCard(
                                  context,
                                  title: "Attendence Portal",
                                  subtitle: "Track your participation",
                                  icon: Icons.list_alt,
                                  backgroundColor: const Color(0xFFD7F4C1),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.attRoute);
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Expanded(
                                child: _homeCard(
                                  context,
                                  title: "Track Your Progress",
                                  subtitle:
                                      "Minimum 40 hours needed to qualify for the PP grade",
                                  icon: Icons.trending_up_sharp,
                                  backgroundColor: const Color(0xFFF2DDFB),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.dashboardpage);
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Expanded(
                                child: _homeCard(
                                  context,
                                  title: "Event Calendar",
                                  subtitle: "View your upcoming activities",
                                  icon: Icons.calendar_month_outlined,
                                  backgroundColor: const Color(0xFFDADFFF),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.calendarRoute);
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Expanded(
                                child: _homeCard(
                                  context,
                                  title: "Certificate Portal",
                                  subtitle: "Access your certificates",
                                  icon: Icons.verified,
                                  backgroundColor: const Color(0xFFD0EAF4),
                                  onTap: () async {
                                    final url = Uri.parse(
                                      "https://nss.gymkhana.iitb.ac.in/certificates/",
                                    );
                                    try {
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Could not open the portal")),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: $e")),
                                        );
                                      }
                                    }
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

  Widget _homeCard(
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
