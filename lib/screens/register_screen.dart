import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class _BottomSection extends StatefulWidget {
  final double screenW;
  final double screenH;
  const _BottomSection({required this.screenW, required this.screenH});

  @override
  State<_BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<_BottomSection> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Preencha email, senha e confirmação.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('As senhas não coincidem.');
      return;
    }

    setState(() => _loading = true);

    final userMetadata = <String, dynamic>{};
    if (_usernameController.text.isNotEmpty) {
      userMetadata['username'] = _usernameController.text.trim();
    }
    if (_firstNameController.text.isNotEmpty) {
      userMetadata['first_name'] = _firstNameController.text.trim();
    }
    if (_lastNameController.text.isNotEmpty) {
      userMetadata['last_name'] = _lastNameController.text.trim();
    }

    try {
      final result = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: userMetadata.isEmpty ? null : userMetadata,
      );

      if (!mounted) return;

      if (result.user != null || result.session != null) {
        if (result.session != null) {
          Navigator.pushReplacementNamed(context, '/');
          return;
        }

        _showMessage(
          'Registro enviado. Verifique seu email para confirmar a conta.',
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      _showMessage('Falha ao registrar. Verifique seus dados.');
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Erro ao conectar com o Supabase: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = widget.screenH / 800;
    final inputSpacing = widget.screenH * 0.015;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: widget.screenW * 0.09),
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
          SizedBox(height: widget.screenH * 0.006),

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
          SizedBox(height: widget.screenH * 0.025),

          // Nome e Sobrenome lado a lado
          Row(
            children: [
              Expanded(
                child: _SmallInputField(
                  controller: _firstNameController,
                  hint: 'Nome...',
                  fontScale: fontScale,
                ),
              ),
              SizedBox(width: widget.screenW * 0.03),
              Expanded(
                child: _SmallInputField(
                  controller: _lastNameController,
                  hint: 'Sobrenome...',
                  fontScale: fontScale,
                ),
              ),
            ],
          ),
          SizedBox(height: inputSpacing),

          // Usuário
          InputField(
            controller: _usernameController,
            hint: 'Usuário...',
            icon: Icons.person_outline,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Email
          InputField(
            controller: _emailController,
            hint: 'Email...',
            icon: Icons.email_outlined,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Senha
          InputField(
            controller: _passwordController,
            hint: 'Senha...',
            icon: Icons.lock_outline,
            obscure: true,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: inputSpacing),

          // Confirmar Senha
          InputField(
            controller: _confirmController,
            hint: 'Confirmar Senha...',
            icon: Icons.lock_outline,
            obscure: true,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: widget.screenH * 0.03),

          // Botão
          CtaButton(
            label: _loading ? 'Carregando...' : 'Registre-se',
            screenW: widget.screenW,
            fontScale: fontScale,
            onPressed: _loading ? () {} : _register,
          ),
          SizedBox(height: widget.screenH * 0.02),

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
  final TextEditingController? controller;
  final String hint;
  final double fontScale;

  const _SmallInputField({
    this.controller,
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
        controller: controller,
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