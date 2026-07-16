import 'package:flutter/material.dart';
import 'package:nssapp/widgets/feedback_form.dart';

const Color _kBg = Color(0xFFF8F9FB);

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: const SafeArea(child: FeedbackForm()),
    );
  }
}
