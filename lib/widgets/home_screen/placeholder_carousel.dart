import 'package:flutter/material.dart';

class PlaceholderCarousel extends StatelessWidget {
  final double screenW;

  const PlaceholderCarousel({
    required this.screenW,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = screenW * 0.35;

    return SizedBox(
      height: cardW + 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: screenW * 0.03),
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: cardW,
              height: cardW,
              decoration: BoxDecoration(
                color: const Color(0xFF535353),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: cardW * 0.8,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF535353),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: cardW * 0.5,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}