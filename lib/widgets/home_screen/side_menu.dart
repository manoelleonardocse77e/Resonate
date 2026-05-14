import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      width: screenW * 0.75,
      height: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Perfil ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenW * 0.06,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF535353),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nome
                  const Text(
                    'Jefersson',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Username
                  Text(
                    '@lins2',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontFamily: 'Akshar',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Seguidores e Seguindo
                  Row(
                    children: [
                      _StatItem(value: '250', label: 'Seguidores'),
                      SizedBox(width: screenW * 0.06),
                      _StatItem(value: '91', label: 'Seguindo'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), thickness: 1),
            const SizedBox(height: 8),

            // ── Menu Items ──────────────────────────────────────
            _MenuItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: true,
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            _MenuItem(
              icon: Icons.album_outlined,
              label: 'Álbums',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.queue_music_outlined,
              label: 'Playlist',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.bar_chart_outlined,
              label: 'Análises',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.list_outlined,
              label: 'Listas',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.thumb_up_outlined,
              label: 'Curtidas',
              onTap: () {},
            ),

            const Spacer(),
            const Divider(color: Color(0xFF2A2A2A), thickness: 1),

            // ── Sair ────────────────────────────────────────────
            _MenuItem(
              icon: Icons.logout_outlined,
              label: 'Sair',
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Item ────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontFamily: 'Akshar',
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Menu Item ────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenW * 0.04,
          vertical: 4,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.04,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.white
                  : Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.white
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}