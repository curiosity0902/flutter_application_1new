import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/users_service/model.dart';
import 'package:flutter_application_1/pages/auth.dart';
import 'package:flutter_application_1/pages/bottom_menu.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = Provider.of<UserModel?>(context);
    final bool check = userModel != null;

    return check ? HomePage() : AuthPage();
  }
}