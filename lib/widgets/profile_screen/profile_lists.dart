import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ProfileLists extends StatelessWidget {
  const ProfileLists({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW * 0.35;

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
                'Listas',
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

          // Carrossel placeholder
          SizedBox(
            height: cardW + 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) =>
                  SizedBox(width: screenW * 0.03),
              itemBuilder: (_, index) => _ListCard(
                cardW: cardW,
                index: index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── List Card ────────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final double cardW;
  final int index;

  const _ListCard({required this.cardW, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capa com grid 2x2
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: cardW,
              height: cardW,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(4, (i) {
                  return Container(
                    color: Color(0xFF535353)
                        .withValues(alpha: 0.5 + (i * 0.1)),
                    child: const Icon(
                      Icons.album,
                      color: Colors.white12,
                      size: 20,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Nome da lista placeholder
          Container(
            width: cardW * 0.9,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0xFF535353),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),

          // Quantidade de álbuns
          Row(
            children: [
              Icon(
                Icons.album_outlined,
                color: Colors.white.withValues(alpha: 0.3),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '${(index + 1) * 10} álbuns',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontFamily: 'Akshar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}