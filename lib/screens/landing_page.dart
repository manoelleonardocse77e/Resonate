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
      left: -328,
      top: 0,
      child: SizedBox(
        width: 730,
        height: 547,
        child: Image.network(
          'https://picsum.photos/730/547',
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
      top: 469,
      child: Container(
        height: 405,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x19787878),
              Color(0xFF454545),
              Color(0xFF121212),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(10),
            ),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x4C000000),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
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
        child: Image.network(
          'https://picsum.photos/277/415',
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
      top: 504,
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
  } //
}