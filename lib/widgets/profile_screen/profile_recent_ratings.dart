import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ProfileRecentRatings extends StatelessWidget {
  const ProfileRecentRatings({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final spacing = screenW * 0.04;
    final cardW = (screenW - (screenW * 0.10) - (spacing * 3)) / 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avaliados Recentes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Carrossel placeholder
          SizedBox(
            height: cardW + 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (_) {
                return SizedBox(
                  width: cardW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Capa placeholder
                      Container(
                        width: cardW,
                        height: cardW,
                        decoration: BoxDecoration(
                          color: const Color(0xFF535353),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Estrelas placeholder
                      Row(
                        children: List.generate(4, (i) {
                          return Icon(
                            i < 3 ? Icons.star : Icons.star_half,
                            color: AppColors.primary,
                            size: 12,
                          );
                        }),
                      ),

                      const SizedBox(height: 3),

                      // Título placeholder
                      Container(
                        width: cardW * 0.8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF535353),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}