import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/input_field.dart';
import '../widgets/cta_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: screenW,
          height: screenH,
          child: Column(
            children: [
              Expanded(
                flex: 40,
                child: _TopSection(screenW: screenW),
              ),
              Expanded(
                flex: 60,
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
            height: 160,
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
          top: screenW * 0.15,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/image 2.png',
              width: screenW * 0.65,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey[700]),
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
    final inputSpacing = screenH * 0.015;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.09),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          Text(
            'Registre-se',
            style: TextStyle(
              color: AppColors.white,
              fontSize: (28 * fontScale).clamp(22, 36),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: screenH * 0.006),

          // Subtítulo
          Text(
            'Por favor, faça registre-se para continuar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: (13 * fontScale).clamp(10, 16),
              fontFamily: 'Akshar',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: screenH * 0.025),

          // Nome e Sobrenome lado a lado
          Row(
            children: [
              Expanded(
                child: _SmallInputField(
                  hint: 'Nome...',
                  fontScale: fontScale,
                ),
              ),
              SizedBox(width: screenW * 0.03),
              Expanded(
                child: _SmallInputField(
                  hint: 'Sobrenome...',
                  fontScale: fontScale,
                ),
              ),
            ],
          ),
          SizedBox(height: inputSpacing),

          // Usuário
          InputField(
            hint: 'Usuário...',
            icon: Icons.person_outline,
            screenW: screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Email
          InputField(
            hint: 'Email...',
            icon: Icons.email_outlined,
            screenW: screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Senha
          InputField(
            hint: 'Senha...',
            icon: Icons.lock_outline,
            obscure: true,
            screenW: screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Confirmar Senha
          InputField(
            hint: 'Confirmar Senha...',
            icon: Icons.lock_outline,
            obscure: true,
            screenW: screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: screenH * 0.03),

          // Botão
          CtaButton(
            label: 'Registre-se',
            screenW: screenW,
            fontScale: fontScale,
            onPressed: () {
              // TODO: lógica de registro
            },
          ),
          SizedBox(height: screenH * 0.02),

          // Já tem conta
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Já tem uma conta? Faça seu login ',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: (12 * fontScale).clamp(10, 15),
                      fontFamily: 'Akshar',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: 'AQUI',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: (12 * fontScale).clamp(10, 15),
                      fontFamily: 'Akshar',
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Pequeno (Nome/Sobrenome) ───────────────────────────────────────────

class _SmallInputField extends StatelessWidget {
  final String hint;
  final double fontScale;

  const _SmallInputField({
    required this.hint,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: ShapeDecoration(
        color: const Color(0xFF535353),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        style: TextStyle(
          color: AppColors.white,
          fontSize: (14 * fontScale).clamp(11, 17),
          fontFamily: 'Akshar',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: (14 * fontScale).clamp(11, 17),
            fontFamily: 'Akshar',
            fontWeight: FontWeight.w300,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}