import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final IconData? icon;
  final IconButton? suffixIcon;

  final bool obscure;

  const Input(
      {this.suffixIcon,
      this.obscure = false,
      this.icon,
      required this.placeholder,
      required this.controller,
      super.key});

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    // return TextField(
    //   controller: controller,
    //   decoration: InputDecoration(label: Text(placeholder)),
    // );
    return TextField(
      controller: widget.controller, // Контролер
      style: const TextStyle(color: Colors.white), // Цвет текста в поле
      cursorColor: const Color.fromRGBO(239, 238, 255, 1), //Цвет курсора
      decoration: InputDecoration(
        prefixIcon: Icon(
          //Иконка
          widget.icon,
          color: const Color.fromRGBO(239, 238, 255, 1),
        ),
        labelText: widget.placeholder,
        hintText: widget.placeholder,
        hintStyle: const TextStyle(color: Colors.white60),
        labelStyle: const TextStyle(
          color: Color(0xFF4A6157),
        ),
      ),
    );
  }
}
