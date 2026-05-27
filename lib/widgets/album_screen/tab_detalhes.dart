import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TabDetalhes extends StatelessWidget {
  final Map<String, String> details;

  const TabDetalhes({required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    final studio = details['studio'] ?? '';
    final country = details['country'] ?? '';
    final language = details['language'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (studio.isNotEmpty) ...[
          _DetailSection(
            title: 'ESTÚDIOS',
            items: [studio],
            screenW: screenW,
          ),
          const Divider(color: Color(0xFF2A2A2A), thickness: 1),
        ],
        if (country.isNotEmpty) ...[
          _DetailSection(
            title: 'País',
            items: [country],
            screenW: screenW,
          ),
          const Divider(color: Color(0xFF2A2A2A), thickness: 1),
        ],
        if (language.isNotEmpty) ...[
          _DetailSection(
            title: 'Língua',
            items: [_formatLanguage(language)],
            screenW: screenW,
          ),
        ],
        if (studio.isEmpty && country.isEmpty && language.isEmpty)
          Padding(
            padding: EdgeInsets.all(screenW * 0.05),
            child: Center(
              child: Text(
                'Nenhum detalhe encontrado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontFamily: 'Akshar',
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatLanguage(String code) {
    const languages = {
      'eng': 'Inglês',
      'por': 'Português',
      'spa': 'Espanhol',
      'fra': 'Francês',
      'deu': 'Alemão',
      'ita': 'Italiano',
      'jpn': 'Japonês',
      'kor': 'Coreano',
      'zho': 'Chinês',
    };
    return languages[code.toLowerCase()] ?? code;
  }
}

// ─── Detail Section ───────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final double screenW;

  const _DetailSection({
    required this.title,
    required this.items,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.05,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item,
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
              )),
        ],
      ),
    );
  }
}