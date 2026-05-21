import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double screenW;
  final double fontScale;

  const CtaButton({
    required this.label,
    required this.onPressed,
    required this.screenW,
    required this.fontScale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: screenW * 0.55,
        height: (44 * fontScale).clamp(38, 52),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: (13 * fontScale).clamp(11, 16),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}