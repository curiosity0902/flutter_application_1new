import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/input.dart';
import 'package:flutter_application_1/database/users_service/service.dart';
import 'package:flutter_application_1/pages/bottom_menu.dart';
import 'package:flutter_application_1/pages/start_page.dart';
import 'package:toast/toast.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  bool visibility = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 33),
                child: _getHeader(),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: emailcontroller,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: const Color(0xFF4A6157),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    labelText: 'E-mail',
                    hintText: 'Введите ваш e-mail',
                    hintStyle: const TextStyle(color: Color(0xFF4A6157)),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.020),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: passcontroller,
                  obscureText: !visibility,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: const Color(0xFF4A6157),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    suffixIcon: IconButton(
                      icon: !visibility
                          ? const Icon(Icons.visibility, color: Colors.black)
                          : const Icon(Icons.visibility_off,
                              color: Colors.black),
                      onPressed: () {
                        setState(() {
                          visibility = !visibility;
                        });
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    labelText: 'Пароль',
                    hintText: 'Введите ваш пароль',
                    hintStyle: const TextStyle(color: Color(0xFF4A6157)),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.063,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailcontroller.text.isEmpty ||
                        passcontroller.text.isEmpty) {
                      Toast.show('Заполните все поля!');
                    } else {
                      var user = await authService.signIn(
                          emailcontroller.text, passcontroller.text);
                      if (user == null) {
                        Toast.show('Email/Пароль не верный!');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF4A6157),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Войти',
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                    ],
                  ),
                ),
              ),
              _getBottomRow(context),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  _getHeader() {
    return Expanded(
      flex: 3,
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(left: 30, top: 100),
        child: const Text(
          'Добро пожаловать!',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 44,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _getBottomRow(context) {
    ToastContext().init(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.22,
        ),
        const Text(
          "Нет аккаунта?  ",
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.063,
          child: OutlinedButton(
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/reg');
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(
                color: Color(0xFF4A6157),
                width: 2.5,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Зарегистрироваться',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
