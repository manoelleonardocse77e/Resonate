import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/credit.dart';

class TabCreditos extends StatelessWidget {
  final List<Credit> credits;

  const TabCreditos({required this.credits, super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    if (credits.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(screenW * 0.05),
        child: Center(
          child: Text(
            'Nenhum crédito encontrado',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Akshar',
            ),
          ),
        ),
      );
    }

    return Column(
      children: credits.map((credit) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenW * 0.05,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF535353),
                    ),
                    child: credit.imageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              credit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Nome e role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          credit.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRole(credit.role),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontFamily: 'Akshar',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
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

  String _formatRole(String role) {
    const roles = {
      'member of band': 'Membro da banda',
      'performer': 'Performer',
      'instrument': 'Instrumentista',
      'vocals': 'Vocais',
      'guitar': 'Guitarra',
      'bass guitar': 'Baixo',
      'drums': 'Bateria',
      'keyboard': 'Teclado',
      'producer': 'Produtor',
      'composer': 'Compositor',
      'lyricist': 'Letrista',
      'mix': 'Mixagem',
      'mastering': 'Masterização',
    };
    return roles[role.toLowerCase()] ?? role;
  }
}