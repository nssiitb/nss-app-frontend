import 'package:flutter/material.dart';
import 'package:nssapp/widgets/notification_tile.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 1, 59),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: const [
          NotificationTile("First"),
          NotificationTile("Two"),
        ],
      ),
    );
  }
}
