import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundImage(),
            _DarkGradientOverlay(),
            _AlbumCoverImage(),
            _BottomContent(),
          ],
        ),
      ),
    );
  }
}

// ─── Background ──────────────────────────────────────────────────────────────

class _BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Mantendo suas coordenadas originais
      left: 0,
      top: 0,
      child: SizedBox(
        width: 500,
        height: 500,
        child: Image.asset(
          'assets/images/image 1.png', // Ajustado para asset local
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey[800]),
        ),
      ),
    );
  }
}

class _DarkGradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 470, // começa junto com a imagem de background
      child: Container(
        height: 500, // mesma altura da imagem de background
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),   // ajuste o valor conforme quiser
            topRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xCC121212), // meio opaco 80%
              Color(0xFF121212), // base totalmente sólida
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Album Cover ─────────────────────────────────────────────────────────────

class _AlbumCoverImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 62,
      top: 156,
      child: SizedBox(
        width: 277,
        height: 415,
        child: Image.asset(
          'assets/images/image 2.png', // Alterado de network para asset
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey[700]),
        ),
      ),
    );
  }
}

// ─── Bottom Content ───────────────────────────────────────────────────────────

class _BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 550,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Headline(),
            const SizedBox(height: 20),
            _FeatureItem('Registre os albúms que você já escutou.'),
            const SizedBox(height: 10),
            _FeatureItem('Salve aqueles que você quer escutar depois.'),
            const SizedBox(height: 10),
            _FeatureItem('Conte para seus amigos o que você escuta de melhor.'),
            const SizedBox(height: 36),
            _CTAButton(),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Sua plataforma de conexão musical !',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontFamily: 'BebasNeue',
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 11,
            height: 11,
            decoration: const ShapeDecoration(
              color: Color(0xFFD9D9D9),
              shape: OvalBorder(),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CTAButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 196,
        height: 43,
        child: ElevatedButton(
          onPressed: () {
            // TODO: navegar para tela de cadastro
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF501DE4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Text(
            'Começe agora - É gratis !',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}