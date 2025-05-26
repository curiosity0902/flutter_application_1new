import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/auth.dart';
import 'package:flutter_application_1/pages/begin_page.dart';
import 'package:flutter_application_1/pages/bottom_menu.dart';
import 'package:flutter_application_1/pages/landing.dart';
import 'package:flutter_application_1/pages/registration.dart';
import 'package:flutter_application_1/profile_pages/profile.dart';

final routes = {
  '/begin': (context) => const BeginPage(),
  '/': (context) => const LandingPage(),
  '/auth': (context) => const AuthPage(),
  '/reg': (context) => const RegistrationPage(),
  '/home': (context) => HomePage(),
  '/profile': (context) => const Profile(),
  // '/edit': (context) => EditProfilePage(),
};
