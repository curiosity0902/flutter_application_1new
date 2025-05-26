import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/database/collections/users_collection.dart';
import 'package:flutter_application_1/database/users_service/service.dart';
import 'package:flutter_application_1/pages/VerifyEmailPage.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:toast/toast.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPage();
}

class _RegistrationPage extends State<RegistrationPage> {
  TextEditingController surnamecontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController patronymiccontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController passcheckcontroller = TextEditingController();

  TextEditingController phonecontroller = TextEditingController();
  TextEditingController dateofbirthcontroller = TextEditingController();
  DateTime? _selectedDate;

  AuthService authService = AuthService();
  UserCollection userCollection = UserCollection();

  bool visibility = false;
  String _dateMessage = '';
  bool _isEmailFilled = false;

  void _showCalendar() {}

  @override
  void initState() {
    super.initState();
    emailcontroller.addListener(() {
      setState(() {

        _isEmailFilled = emailcontroller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    emailcontroller.dispose(); 
    super.dispose();
  }

  Timestamp _getTimestampFromDate(String dateStr) {
    try {
      DateTime dateTime = DateFormat('dd/MM/yyyy').parse(dateStr);

      return Timestamp.fromDate(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      return Timestamp.now(); 
    }
  }

  _getBottomRow(context) {
    ToastContext().init(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.063,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A6157),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (surnamecontroller.text.isEmpty ||
                    namecontroller.text.isEmpty ||
                    patronymiccontroller.text.isEmpty ||
                    emailcontroller.text.isEmpty ||
                    phonecontroller.text.isEmpty ||
                    dateofbirthcontroller.text.isEmpty ||
                    passwordcontroller.text.isEmpty) {
                  Toast.show('Заполните все поля!');
                } else {
                  if (passwordcontroller.text == passcheckcontroller.text) {
                    var user = await authService.signUp(
                        emailcontroller.text, passwordcontroller.text);
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyEmailPage(
                            email: emailcontroller.text,
                            password: passwordcontroller.text,
                            fullname:
                                ('${surnamecontroller.text} ${namecontroller.text} ${patronymiccontroller.text}'),
                            count: 0,
                            image: '',
                            dateofbirth: _getTimestampFromDate(
                                dateofbirthcontroller.text),
                            phone: phonecontroller.text,
                          ),
                        ),
                      );
                    } else {
                      Toast.show('Проверьте правильность данных');
                    }
                  } else {
                    Toast.show('Пароли не совпадают');
                  }
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Зарегистрироваться',
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        GestureDetector(
          onTap: () async {
            Navigator.popAndPushNamed(context, '/auth');
          },
          child: const Text("Есть аккаунт?",
              style: TextStyle(
                color: Color(0xFF4A6157),
                fontSize: 17,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4A6157),
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskFormatter = MaskTextInputFormatter(
      mask: '+7(900)-000-00-00',
      filter: {"0": RegExp(r'[0-9]')},
    );

    return Scaffold(
      body: CustomPaint(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 17, left: 35, right: 35),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(top: 50, bottom: 20),
                        child: const Text(
                          'Регистрация',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: surnamecontroller,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.star,
                            color: Colors.black,
                          ),
                          labelText: 'Фамилия',
                          hintText: 'Фамилия',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: namecontroller,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.star,
                            color: Colors.black,
                          ),
                          labelText: 'Имя',
                          hintText: 'Имя',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: patronymiccontroller,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.star,
                            color: Colors.black,
                          ),
                          labelText: 'Отчество',
                          hintText: 'Отчество',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: dateofbirthcontroller,
                        readOnly: true,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                          ),
                          labelText: 'Дата рождения',
                          hintText: 'Выберите дату',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            locale: Locale(
                                'ru', 'RU'), 
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor:
                                      Colors.white, 
                                  buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary,
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Colors
                                        .black, 
                                    onPrimary:
                                        Colors.white, 
                                    surface: Colors.white,
                                    onSurface: Colors
                                        .black, 
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              dateofbirthcontroller.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
                              if (isOver18(pickedDate)) {
                                _dateMessage = 'Возраст подходит';
                              } else {
                                _dateMessage =
                                    'Вам должно быть не менее 18 лет';
                              }
                            });
                          }
                        },
                      ),
                    ),
                    if (_dateMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _dateMessage,
                          style: TextStyle(
                            color: _dateMessage == 'Возраст подходит'
                                ? Color(0xFF4A6157)
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: phonecontroller,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [maskFormatter],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          labelText: 'Номер телефона',
                          hintText: '+7(000)-000-00-00',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: emailcontroller,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          labelText: 'Email',
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (_isEmailFilled)
                      Padding(
                        padding: const EdgeInsets.only(left: 19.0),
                        child: Text(
                          'В дальнейшем вы не сможете изменить почту',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.013),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: passwordcontroller,
                        obscureText: !visibility,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            icon: visibility
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            color: Colors.black,
                            onPressed: () {
                              setState(() {
                                visibility = !visibility;
                              });
                            },
                          ),
                          labelText: 'Пароль',
                          hintText: 'Введите пароль',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.013,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: passcheckcontroller,
                        obscureText: !visibility,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          suffixIcon: IconButton(
                            icon: !visibility
                                ? const Icon(
                                    Icons.visibility,
                                    color: Colors.black,
                                  )
                                : const Icon(
                                    Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                            onPressed: () {
                              setState(() {
                                visibility = !visibility;
                              });
                            },
                          ),
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Colors.black,
                          ),
                          labelText: 'Повторите пароль',
                          hintText: 'Повторите пароль',
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035),
                    _getBottomRow(context),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   bottom: 30,
            //   left: 35,
            //   right: 35,
            //   child: _getBottomRow(context),
            // ),
          ],
        ),
      ),
    );
  }
}

bool isOver18(DateTime birthDate) {
  final today = DateTime.now();
  final age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    return age - 1 >= 18;
  }
  return age >= 18;
}
