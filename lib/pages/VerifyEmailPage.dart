import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/collections/users_collection.dart';
import 'package:flutter_application_1/database/users_service/service.dart';
import 'package:flutter_application_1/pages/landing.dart';
import 'package:toast/toast.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullname;
  final int count;
  final String image;
  final Timestamp dateofbirth;
  final String phone;

  const VerifyEmailPage({
    Key? key,
    required this.email,
    required this.password,
    required this.fullname,
    required this.count,
    required this.image,
    required this.dateofbirth,
    required this.phone,
  }) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late Timer timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserCollection userCollection = UserCollection();
  bool isEmailVerified = false;
  bool canResendEmail = false;
  bool isLoading = false;
  AuthService authService = AuthService();
  bool emailSent = false;

  @override
  void initState() {
    super.initState();
    sendVerificationEmail();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _auth.currentUser?.reload();
      var user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        timer.cancel();
        await authService.addUser(
          user.uid,
          user.email!,
          widget.fullname,
          widget.image,
          widget.count,
          widget.password,
          widget.dateofbirth,
          widget.phone,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email sent to ${user.email}');
        setState(() {
          emailSent = true;
          canResendEmail = false;
        });
        await Future.delayed(Duration(minutes: 1));
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  Future<void> saveUserData() async {
    var user = _auth.currentUser;
    if (user != null) {
      setState(() {
        isLoading = true;
      });
      try {
        await authService.addUser(
          user.uid,
          widget.email,
          widget.fullname,
          widget.image,
          widget.count,
          widget.password,
          widget.dateofbirth,
          widget.phone,
        );
        goToHomePage();
      } catch (e) {
        print('Error saving user data: $e');
        showToast('Ошибка сохранения данных пользователя');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void goToHomePage() {
    Navigator.popAndPushNamed(context, '/');
  }

  void showToast(String message) {
    Toast.show(message, duration: Toast.lengthLong, gravity: Toast.bottom);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF4A6157),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 64, 77, 72),
                Color.fromARGB(255, 88, 112, 102), 
                Color.fromARGB(255, 55, 100, 82), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 48,
                        color: Colors.white, 
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'На вашу электронную почту отправлено письмо. Пожалуйста, проверьте почту и подтвердите адрес.',
                        style: TextStyle(
                          fontSize: 21,
                          color: Colors.white, 
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        label: Text(
                          canResendEmail
                              ? 'Отправить письмо снова'
                              : 'Отправлено',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, 
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black,
                          ),
                        ),
                        onPressed:
                            canResendEmail ? sendVerificationEmail : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                              color: Colors.black, fontSize: 19 
                              ),
                        ),
                        onPressed: () => _auth.currentUser!.delete().then((_) {
                          Navigator.popAndPushNamed(context, '/reg');
                        }),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
