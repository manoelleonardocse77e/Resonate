import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FeatureItem extends StatelessWidget {
  final String text;
  final double fontScale;

  const FeatureItem(this.text, {required this.fontScale, super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: const ShapeDecoration(
              color: AppColors.bullet,
              shape: OvalBorder(),
            ),
          ),
        ),
        SizedBox(width: screenW * 0.04),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white,
              fontSize: (14 * fontScale).clamp(12, 18),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}