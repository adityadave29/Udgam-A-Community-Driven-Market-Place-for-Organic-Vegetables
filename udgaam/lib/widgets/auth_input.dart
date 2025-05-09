import 'package:flutter/material.dart';
import 'package:udgaam/utils/type_def.dart';

class AuthInput extends StatelessWidget {
  final String label, hintText;
  final bool isPassword;
  final TextEditingController controller;
  final ValidatorCallback Validatorcallback;
  const AuthInput({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    required this.Validatorcallback,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      validator: Validatorcallback,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
