import 'package:flutter/material.dart';
import '../constants/colors.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final double screenW;
  final double fontScale;

  const InputField({
    required this.hint,
    required this.icon,
    required this.screenW,
    required this.fontScale,
    this.obscure = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 47,
      decoration: ShapeDecoration(
        color: const Color(0xFF535353),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        obscureText: obscure,
        style: TextStyle(
          color: AppColors.white,
          fontSize: (15 * fontScale).clamp(12, 18),
          fontFamily: 'Akshar',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: (15 * fontScale).clamp(12, 18),
            fontFamily: 'Akshar',
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}