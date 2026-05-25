import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../widgets/input_field.dart';
import '../widgets/cta_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                flex: 48,
                child: _TopSection(screenW: screenW),
              ),
              Expanded(
                flex: 52,
                child: _LoginForm(screenW: screenW, screenH: screenH),
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
          top: screenW * 0.3,
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

// ─── Formulário de login ─────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  final double screenW;
  final double screenH;

  const _LoginForm({required this.screenW, required this.screenH});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Preencha o email e a senha.');
      return;
    }

    setState(() => _loading = true);

    bool didLogin = false;
    try {
      final result = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result.user != null || result.session != null) {
        didLogin = true;
      } else {
        _showMessage('Falha ao fazer login. Verifique seus dados.');
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('Erro ao conectar com o Supabase.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (didLogin && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = widget.screenH / 800;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: widget.screenW * 0.09),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'LOGIN',
            style: TextStyle(
              color: AppColors.white,
              fontSize: (32 * fontScale).clamp(24, 40),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: widget.screenH * 0.008),
          Text(
            'Por favor, faça login para continuar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: (14 * fontScale).clamp(11, 17),
              fontFamily: 'Akshar',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: widget.screenH * 0.03),
          InputField(
            controller: _emailController,
            hint: 'Email...',
            icon: Icons.email_outlined,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: widget.screenH * 0.018),
          InputField(
            controller: _passwordController,
            hint: 'Senha...',
            icon: Icons.lock_outline,
            obscure: true,
            screenW: widget.screenW,
            fontScale: fontScale,
          ),
          SizedBox(height: widget.screenH * 0.018),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _RememberMe(),
              Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: (11 * fontScale).clamp(9, 14),
                  fontFamily: 'Akshar',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenH * 0.03),
          CtaButton(
            label: _loading ? 'Carregando...' : 'LOGIN',
            screenW: widget.screenW,
            fontScale: fontScale,
            onPressed: _loading ? () {} : _login,
          ),
          SizedBox(height: widget.screenH * 0.025),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Não tem uma conta? Cadastre-se ',
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
                  TextSpan(
                    text: ' primeiro',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: (12 * fontScale).clamp(10, 15),
                      fontFamily: 'Akshar',
                      fontWeight: FontWeight.w300,
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

// ─── Remember Me ─────────────────────────────────────────────────────────────

class _RememberMe extends StatefulWidget {
  const _RememberMe();

  @override
  State<_RememberMe> createState() => _RememberMeState();
}

class _RememberMeState extends State<_RememberMe> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _checked = !_checked),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _checked ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: _checked ? AppColors.primary : Colors.white54,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _checked
                ? const Icon(Icons.check, color: Colors.white, size: 13)
                : null,
          ),
          const SizedBox(width: 8),
          const Text(
            'Lembrar de mim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Akshar',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}