import 'dart:async';
import 'package:nssapp/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:nssapp/utils/authenticator.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  // animation controller
  late AnimationController _controller;
  late Animation<double> _animation;

  // function to replace splash screen with home screen after some seconds
  @override
  void initState() {
    // ----------------- Animation Stuff --------------------
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // ----------------------------------------------------

    final AuthService authService = AuthService();

    Future<void> navigateToNextPage() async {
      await Future.delayed(const Duration(seconds: 2));
      // Check login status
      bool isLoggedIn = await authService.isLoggedIn();
      // Navigate to the appropriate page
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.homeRoute);
      } else {
        Navigator.pushReplacementNamed(context, Routes.loginRoute);
      }
    }

    navigateToNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 1, 1, 59),
        body: FadeTransition(
          opacity: _animation,
          child: Column(
            children: [
              const Spacer(
                // flex: 3,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nsslogo.png',
                        alignment: Alignment.center,
                        height: 180,
                        width: 180,
                      ),
                      Column(
                        children: [
                          const Text(
                            "NSS IITB",
                            style: TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(
                                0, -15), // Negative value to move upwards
                            child: const Text(
                              "National Service Scheme",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "THINK WE NOT ME!",
                        style: TextStyle(
                          color: Color.fromARGB(255, 186, 153, 100),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Image.asset("assets/images/handimage.png",
              //     opacity: const AlwaysStoppedAnimation(.8)),
            ],
          ),
        ));
  }
}
