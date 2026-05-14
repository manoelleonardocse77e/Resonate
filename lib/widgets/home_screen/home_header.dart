import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class HomeHeader extends StatelessWidget {
  final double screenW;
  const HomeHeader({required this.screenW, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.05,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: AppColors.white, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF535353),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}