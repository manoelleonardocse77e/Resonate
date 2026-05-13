import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega a altura real descontando status bar e navigation bar
    final mediaQuery = MediaQuery.of(context);
    final screenW = mediaQuery.size.width;
    final screenH = mediaQuery.size.height
        - mediaQuery.padding.top
        - mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: screenW,
          height: screenH,
          child: Column(
            children: [
              // ── Metade superior: imagens ──────────────────────────
              Expanded(
                flex: 55, // 55% da tela
                child: _TopSection(screenW: screenW),
              ),

              // ── Metade inferior: textos + botão ──────────────────
              Expanded(
                flex: 45, // 45% da tela
                child: _BottomSection(screenW: screenW, screenH: screenH),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Seção Superior (imagens) ─────────────────────────────────────────────────

class _TopSection extends StatelessWidget {
  final double screenW;
  const _TopSection({required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagem de fundo
        Image.asset(
          'assets/images/image 1.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
        ),

        // Gradiente na parte de baixo da seção superior
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
                  Color(0xFF121212),
                ],
              ),
            ),
          ),
        ),

        // Imagem da capa do álbum centralizada
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

// ─── Seção Inferior (textos + botão) ──────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final double screenW;
  final double screenH;
  const _BottomSection({required this.screenW, required this.screenH});

  @override
  Widget build(BuildContext context) {
    final fontScale = screenH / 800;

    return Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.only(
        left: screenW * 0.09,
        right: screenW * 0.09,
        bottom: screenH * 0.06, // ← ajuste aqui para subir/descer
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // ← conteúdo vai para baixo
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua plataforma de conexão musical !',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: (22 * fontScale).clamp(16, 28),
              fontFamily: 'BebasNeue',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenH * 0.03),
          _FeatureItem(
            'Registre os álbuns que você já escutou.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.02),
          _FeatureItem(
            'Salve aqueles que você quer escutar depois.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.02),
          _FeatureItem(
            'Conte para seus amigos o que você escuta de melhor.',
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.035),
          Center(
            child: SizedBox(
              width: screenW * 0.55,
              height: (44 * fontScale).clamp(38, 52),
              child: ElevatedButton(
                onPressed: () {
                   Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF501DE4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Começe agora - É gratis !',
                  style: TextStyle(
                    fontSize: (13 * fontScale).clamp(11, 16),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Item ─────────────────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final String text;
  final double fontScale;

  const _FeatureItem(this.text, {required this.fontScale});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: const ShapeDecoration(
              color: Color(0xFFD9D9D9),
              shape: OvalBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: (14 * fontScale).clamp(12, 18),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}