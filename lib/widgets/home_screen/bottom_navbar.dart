import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.05,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            index: 0,
            currentIndex: currentIndex,
            onTap: (index) {
              onTap(index);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          _NavItem(
            icon: Icons.explore_outlined,
            index: 1,
            currentIndex: currentIndex,
            onTap: (index) {
              onTap(index);
              // TODO: navegar para explorar
            },
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            index: 2,
            currentIndex: currentIndex,
            onTap: (index) {
              onTap(index);
              // TODO: navegar para notificações
            },
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 3,
            currentIndex: currentIndex,
            onTap: (index) {
              onTap(index);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppColors.white
                : Colors.white.withValues(alpha: 0.4),
            size: 26,
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 20 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}