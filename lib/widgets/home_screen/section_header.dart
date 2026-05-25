import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double screenW;
  final VoidCallback onVerMais;
  final String? toggleLabel;
  final VoidCallback? onToggle;

  const SectionHeader({
    required this.title,
    required this.screenW,
    required this.onVerMais,
    this.toggleLabel,
    this.onToggle,
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
          Row(
            children: [
              // Toggle álbuns/singles
              if (toggleLabel != null && onToggle != null)
                GestureDetector(
                  onTap: onToggle,
                  child: Row(
                    children: [
                      Text(
                        toggleLabel!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.swap_horiz,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

              // Ver mais
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
        ],
      ),
    );
  }
}