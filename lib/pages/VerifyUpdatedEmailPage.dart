import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/database/collections/users_collection.dart';
import 'package:flutter_application_1/database/users_service/service.dart';
import 'package:toast/toast.dart';

class VerifyUpdatedEmailPage extends StatefulWidget {
  final String newEmail;
  final String fullname;
  final String image;
  final String oldEmail;
  final String password;
  final String phone;

  const VerifyUpdatedEmailPage({
    Key? key,
    required this.newEmail,
    required this.fullname,
    required this.image,
    required this.oldEmail,
    required this.password,
    required this.phone,
  }) : super(key: key);

  @override
  _VerifyUpdatedEmailPageState createState() => _VerifyUpdatedEmailPageState();
}

class _VerifyUpdatedEmailPageState extends State<VerifyUpdatedEmailPage> {
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
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        // await _auth.currentUser?.reload();
        authService.signOut();
        var user = await authService.signIn(widget.newEmail, widget.password);
        if (user != null) {
          timer.cancel();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'email': widget.newEmail,
            'fullname': widget.fullname,
            'image': widget.image,
            'phone': widget.phone,
          });

          // Перенаправляем на страницу редактирования профиля
          Navigator.popAndPushNamed(context, '/edit');
        } else {
          authService.signIn(widget.oldEmail, widget.password);
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != widget.newEmail) {
        await user.verifyBeforeUpdateEmail(widget.newEmail);
        print('Verification email sent to ${user.email}');
        setState(() {
          emailSent = true;
          canResendEmail = false;
        });
        await Future.delayed(const Duration(minutes: 1));
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  void showToast(String message) {
    Toast.show(message, duration: Toast.lengthLong, gravity: Toast.bottom);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color.fromRGBO(239, 238, 255, 1),
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
                      const Icon(
                        Icons.message_outlined,
                        size: 48, // Укажите размер иконки по вашему усмотрению
                        color: Colors.white, // Цвет иконки
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'На вашу электронную почту отправлено письмо. Пожалуйста, проверьте почту и подтвердите адрес.',
                        style: TextStyle(
                          fontSize: 21,
                          color: Colors.white, // Цвет текста
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        label: Text(
                          canResendEmail
                              ? 'Отправить письмо снова'
                              : 'Отправлено',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white, // Цвет текста
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed:
                            canResendEmail ? sendVerificationEmail : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                              fontSize: 18, color: Colors.black // Цвет текста
                              ),
                        ),
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/edit');
                        },
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      );
}
