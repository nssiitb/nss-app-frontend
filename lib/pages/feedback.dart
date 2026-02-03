import 'package:flutter/material.dart';
import 'package:nssapp/widgets/feedback_form.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.white,
              )),
          title: const Text(
            'FEEDBACK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily:
                  'Nunito', // Ensure 'Nunito' font is added to pubspec.yaml
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 1, 1, 59),
        ),
        body:
            const FeedbackForm(), // Assuming FeedbackForm is already implemented.
      ),
    );
  }
}
