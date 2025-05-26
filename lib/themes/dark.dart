import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      iconColor: MaterialStatePropertyAll(Color(0x9D9187)),
      backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(1, 1, 1, 0.936)),
    ),
  ),
  scaffoldBackgroundColor: Color(0xFFFAF9F6),
  appBarTheme: const AppBarTheme(
    //centerTitle: true,
    backgroundColor: Color(0xFF4A6157),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:
        Color.fromRGBO(0, 0, 0, 0.689), // Цвет кнопки с прозрачностью
    selectedLabelStyle: TextStyle(color: Colors.blue),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStatePropertyAll(
        TextStyle(color: Colors.white),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    ),
  ),
  outlinedButtonTheme: const OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 89, 37, 30)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    ),
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStatePropertyAll(
        TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.white,
        ),
      ),
      foregroundColor: MaterialStatePropertyAll(
        Color(0xFF4A6157),
      ),
    ),
  ),
);
