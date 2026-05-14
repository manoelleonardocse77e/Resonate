import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double screenW;
  final VoidCallback onVerMais;

  const SectionHeader({
    required this.title,
    required this.screenW,
    required this.onVerMais,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onVerMais,
            child: Text(
              'Ver mais',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'Akshar',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}