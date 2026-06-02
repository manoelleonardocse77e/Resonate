import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TabGeneros extends StatelessWidget {
  final List<String> genres;

  const TabGeneros({required this.genres, super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    if (genres.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(screenW * 0.05),
        child: Center(
          child: Text(
            'Nenhum gênero encontrado',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Akshar',
            ),
          ),
        ),
      );
    }

    return Column(
      children: genres.map((genre) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenW * 0.05,
                vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _capitalize(genre),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF2A2A2A),
              thickness: 1,
              height: 1,
            ),
          ],
        );
      }).toList(),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}