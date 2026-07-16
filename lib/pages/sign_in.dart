// sign_in.dart

import 'package:flutter/material.dart';
import 'package:nssapp/widgets/login_form.dart';
import 'package:nssapp/widgets/registration_form.dart';

const Color _kBg = Color(0xFFF8F9FB);

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) => const AuthScreen(initial: AuthTab.signIn);
}

class AuthScreen extends StatefulWidget {
  final AuthTab initial;
  const AuthScreen({super.key, required this.initial});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthTab _tab = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Opaque, fixed header — form scrolls beneath it (clipped).
            Container(
              color: _kBg,
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandWordmark(),
                  const SizedBox(height: 32),
                  AuthTabs(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                ],
              ),
            ),
            // Only the form area transitions. Everything above stays put.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _tab == AuthTab.signIn
                        ? const KeyedSubtree(
                            key: ValueKey('signin'),
                            child: LoginForm(),
                          )
                        : const KeyedSubtree(
                            key: ValueKey('signup'),
                            child: RegistrationForm(),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
