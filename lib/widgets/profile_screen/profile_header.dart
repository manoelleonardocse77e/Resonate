import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/colors.dart';

class ProfileHeader extends StatefulWidget {
  final String name;
  final String? username;
  final String? location;
  final String? instagram;
  final String? letterboxd;
  final bool isOwnProfile;
  final String? artistImageUrl;

  const ProfileHeader({
    required this.name,
    this.username,
    this.location,
    this.instagram,
    this.letterboxd,
    this.isOwnProfile = true,
    this.artistImageUrl,
    super.key,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final _supabase = Supabase.instance.client;
  late String _nickname;

  @override
  void initState() {
    super.initState();
    _nickname = widget.name;
  }

  Future<void> _editarNickname() async {
    final controller = TextEditingController(text: _nickname);

    final novoNome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Editar nome',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Seu nome de perfil',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (novoNome == null || novoNome.isEmpty || novoNome == _nickname) return;

    try {
      final userId = _supabase.auth.currentUser?.id;

      await _supabase
          .from('usuario')
          .update({'nickname': novoNome})
          .eq('id_usuario', userId as Object);

      setState(() => _nickname = novoNome);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nome atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // ── Foto de fundo ──────────────────────────────
        SizedBox(
          height: screenH * 0.25,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fundo
              widget.artistImageUrl != null
                  ? Image.network(
                      widget.artistImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[900]),
                    )
                  : Container(color: Colors.grey[900]),

              // Gradiente
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background,
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),

              // Botão configurações ou seguir
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: widget.isOwnProfile
                    ? IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {},
                      )
                    : GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Seguir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
              ),

              // Botão menu hamburguer (só no próprio perfil)
              if (widget.isOwnProfile)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
            ],
          ),
        ),

        // ── Avatar + nome ──────────────────────────────
        Transform.translate(
          offset: const Offset(0, -30),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF535353),
                  border: Border.all(
                    color: AppColors.background,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),

              // Nome com botão de edição (só no próprio perfil)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _nickname,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.isOwnProfile) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _editarNickname,
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Localização, letterboxd, instagram
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children: [
                  if (widget.location != null)
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: widget.location!,
                    ),
                  if (widget.letterboxd != null)
                    _InfoChip(
                      icon: Icons.movie_outlined,
                      label: widget.letterboxd!,
                    ),
                  if (widget.instagram != null)
                    _InfoChip(
                      icon: Icons.camera_alt_outlined,
                      label: widget.instagram!,
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Seguidores e Seguindo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(value: '250', label: 'Seguidores'),
                  const SizedBox(width: 16),
                  _StatChip(value: '91', label: 'Seguindo'),
                ],
              ),
              const SizedBox(height: 8),

              // Frase
              Text(
                'Já escutei todos, todos os álbuns',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Akshar',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 14),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontFamily: 'Akshar',
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
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