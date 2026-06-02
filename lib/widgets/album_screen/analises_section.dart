import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AnalisesSection extends StatelessWidget {
  const AnalisesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Análises Populares',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Ver Todos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontFamily: 'Akshar',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Placeholder de análises ────────────────────────
        ...List.generate(3, (index) => _AnaliseItem(screenW: screenW)),
      ],
    );
  }
}

// ─── Analise Item ─────────────────────────────────────────────────────────────

class _AnaliseItem extends StatelessWidget {
  final double screenW;

  const _AnaliseItem({required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.05,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF535353),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white24,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome + estrelas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nome placeholder
                    Container(
                      width: screenW * 0.25,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF535353),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Estrelas
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < 4 ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Texto placeholder linha 1
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),

                // Texto placeholder linha 2
                Container(
                  width: screenW * 0.5,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                // Ler mais
                Text(
                  'Ler mais',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontFamily: 'Akshar',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}