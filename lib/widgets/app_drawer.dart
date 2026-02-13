import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/utils/routes.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 4, 4, 107),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 16),
                const Text(
                  'NSS IITB',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontFamily: "Raleway"),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: const Icon(
              Icons.person,
              size: 25,
            ),
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pushNamed(context, Routes.profileRoute);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: const Icon(
              Icons.calendar_month_outlined,
              size: 25,
            ),
            title: const Text(
              "Calendar",
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pushNamed(context, Routes.calendarRoute);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: const Icon(
              Icons.logout,
              size: 25,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(fontSize: 18),
            ),
            onTap: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, Routes.loginRoute);
            },
          ),
        ],
      ),
    );
  }
}
