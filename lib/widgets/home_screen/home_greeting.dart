import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class HomeGreeting extends StatelessWidget {
  final String username;
  final double screenW;

  const HomeGreeting({
    required this.username,
    required this.screenW,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Olá, '),
                TextSpan(
                  text: username,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const TextSpan(text: ' !'),
              ],
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registre o que está escutando!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontFamily: 'Akshar',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}