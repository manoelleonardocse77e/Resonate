import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/feature_item.dart';
import '../widgets/cta_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenW = mediaQuery.size.width;
    final screenH = mediaQuery.size.height
        - mediaQuery.padding.top
        - mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: screenW,
          height: screenH,
          child: Column(
            children: [
              Expanded(
                flex: 55,
                child: _TopSection(screenW: screenW),
              ),
              Expanded(
                flex: 45,
                child: _BottomSection(screenW: screenW, screenH: screenH),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Seção Superior ───────────────────────────────────────────────────────────

class _TopSection extends StatelessWidget {
  final double screenW;
  const _TopSection({required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/image 1.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 320,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/image 2.png',
                width: screenW * 0.60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[700]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Seção Inferior ───────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final double screenW;
  final double screenH;
  const _BottomSection({required this.screenW, required this.screenH});

  @override
  Widget build(BuildContext context) {
    final fontScale = screenH / 800;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        left: screenW * 0.09,
        right: screenW * 0.09,
        bottom: screenH * 0.06,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua plataforma de conexão musical !',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: (22 * fontScale).clamp(16, 28),
              fontFamily: 'BebasNeue',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenH * 0.03),
          FeatureItem(
            'Registre os álbuns que você já escutou.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.02),
          FeatureItem(
            'Salve aqueles que você quer escutar depois.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.02),
          FeatureItem(
            'Conte para seus amigos o que você escuta de melhor.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.035),
          CtaButton(
            label: 'Começe agora - É gratis !',
            screenW: screenW,
            fontScale: fontScale,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}