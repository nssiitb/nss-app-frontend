import 'package:flutter/material.dart';
import 'package:nssapp/pages/fetchAtt.dart';
import 'package:nssapp/pages/attbyDept.dart';
import 'package:nssapp/pages/attbyEvent.dart';
import 'package:nssapp/pages/attbyRoll.dart';
import 'package:nssapp/pages/dashboard.dart';
import 'package:nssapp/pages/events.dart';
import 'package:nssapp/pages/notifications.dart';
import 'package:nssapp/pages/on_boarding.dart';
import 'package:nssapp/pages/profile.dart';
import 'package:nssapp/pages/feedback.dart';
import 'package:nssapp/pages/sign_in.dart';
import 'package:nssapp/pages/sign_up.dart';
import 'package:nssapp/pages/home.dart';
import 'package:nssapp/pages/splash.dart';
import 'package:nssapp/pages/calendar.dart';
import 'package:nssapp/pages/attendance.dart';
import 'package:nssapp/pages/addEvent.dart';
import 'package:nssapp/pages/allEvents.dart';
import 'package:nssapp/pages/volunteerList.dart';

import 'utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashRoute,
      routes: {
        Routes.homeRoute: (context) => Home(),
        Routes.loginRoute: (context) => const SignIn(),
        Routes.signUpRoute: (context) => const SignUp(),
        Routes.splashRoute: (context) => const Splash(),
        Routes.onBoardRoute: (context) => const OnBoard(),
        Routes.profileRoute: (context) => const ProfilePage(),
        Routes.notificationRoute: (context) => const Notifications(),
        Routes.feedbackRoute: (context) => const FeedbackPage(),
        Routes.eventRoute: (context) => const EventPage(),
        Routes.calendarRoute: (context) => const EventCalendarScreen(),
        Routes.attRoute: (context) => const Attendance(),
        Routes.addEvent: (context) => const AddEvents(),
        Routes.allEvents: (context) => const Allevents(),
        Routes.dashboardpage: (context) => const DashboardPage(),
        Routes.volListRoute: (context) => const Volunteerlist(),
        Routes.fetchAtt: (context) => const Fetchatt(),
        Routes.attbyEvent: (context) => const Attbyevent(),
        Routes.attbyRoll: (context) => const Attbyroll(),
        Routes.attbyDept: (context) => const Attbydept(),
      },
    );
  }
}
