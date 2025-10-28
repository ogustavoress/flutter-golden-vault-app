import 'package:flutter/material.dart';

class PasswordResultWidget extends StatelessWidget {
  final String password;

  const PasswordResultWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFD4AF37), width: 2),
      ),
      child: Center(
        child: Text(
          password,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}