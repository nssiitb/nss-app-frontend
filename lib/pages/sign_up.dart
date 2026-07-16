import 'package:flutter/material.dart';
import 'package:nssapp/pages/sign_in.dart';
import 'package:nssapp/widgets/login_form.dart' show AuthTab;

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) => const AuthScreen(initial: AuthTab.signUp);
}
