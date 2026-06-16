import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ProfileAnalyses extends StatelessWidget {
  const ProfileAnalyses({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + Ver Todas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Análises',
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
                  'Ver todas',
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
          const SizedBox(height: 12),

          // Lista de análises placeholder
          ...List.generate(2, (index) => _AnaliseItem(screenW: screenW)),
        ],
      ),
    );
  }
}

// ─── Analise Item ─────────────────────────────────────────────────────────────

class _AnaliseItem extends StatelessWidget {
  final double screenW;

  const _AnaliseItem({required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + nome + estrelas
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF535353),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white24,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título do álbum placeholder
                        Container(
                          width: screenW * 0.25,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF535353),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Estrelas
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < 4 ? Icons.star : Icons.star_half,
                              color: AppColors.primary,
                              size: 10,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Título da análise placeholder
                Container(
                  width: screenW * 0.3,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF535353),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),

                // Texto placeholder
                Container(
                  width: double.infinity,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: screenW * 0.45,
                  height: 7,
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
                    fontSize: 11,
                    fontFamily: 'Akshar',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Imagem do álbum
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF535353),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.album,
              color: Colors.white24,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}