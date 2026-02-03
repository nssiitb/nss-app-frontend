import 'package:flutter/material.dart';
import 'package:nssapp/widgets/HomeVolunteer.dart';
import 'package:nssapp/widgets/HomeAA.dart';
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
        final isaa = data["isaa"] == true;
        return isaa
            ? const Homeaa()
            : Homevolunteer(name: data["name"] ?? "User");
      },
    );
  }
}
