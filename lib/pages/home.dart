import 'package:flutter/material.dart';
import 'package:nssapp/widgets/HomeVolunteer.dart';
import 'package:nssapp/widgets/HomeAA.dart';
import 'package:nssapp/widgets/HomeCTM.dart';
import 'package:nssapp/utils/authenticator.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final isCTM = data["isctm"] == true || data["isctm"] == 1;
        final isaa = data["isaa"] == true || data["isaa"] == 1;
        
        // Priority order: CTM -> AA -> Volunteer
        if (isCTM) {
          return HomeCTM(name: data["name"] ?? "User");
        } else if (isaa) {
          return HomeAA(name: data["name"] ?? "User");
        } else {
          return HomeVolunteer(name: data["name"] ?? "User");
        }
      },
    );
  }
}