import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/album.dart';

class AlbumHeader extends StatelessWidget {
  final Album album;
  final Map<String, dynamic> details;
  final String? artistImageUrl;
  final String? description;
  final String? totalDuration;

  const AlbumHeader({
    required this.album,
    required this.details,
    this.artistImageUrl,
    this.description,
    this.totalDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Foto da banda + conteúdo ──────────────────────
        SizedBox(
          height: screenH * 0.55,
          child: Stack(
            children: [
              // Foto da banda como fundo
              artistImageUrl != null
                  ? Image.network(
                      artistImageUrl!,
                      width: double.infinity,
                      height: screenH * 0.55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[900]),
                    )
                  : Container(
                      height: screenH * 0.55,
                      color: Colors.grey[900],
                    ),

              // Gradiente escuro
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xAA000000),
                      AppColors.background,
                    ],
                    stops: [0.3, 0.65, 1.0],
                  ),
                ),
              ),

              // Botão voltar
              Positioned(
                top: 12,
                left: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Conteúdo inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── Capa + ícones abaixo ──────────────
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Capa com ícone play
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: album.coverUrl != null
                                    ? Image.network(
                                        album.coverUrl!,
                                        width: screenW * 0.38,
                                        height: screenW * 0.38,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _PlaceholderCover(
                                                size: screenW * 0.38),
                                      )
                                    : _PlaceholderCover(size: screenW * 0.38),
                              ),
                              // Ícone play
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0x4CD9D9D9),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // ── Ícones abaixo da capa ─────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Counter(
                                icon: Icons.headphones_outlined,
                                count: '10k',
                              ),
                              SizedBox(width: screenW * 0.04),
                              _Counter(
                                icon: Icons.favorite_border,
                                count: '1.115',
                              ),
                              SizedBox(width: screenW * 0.04),
                              _Counter(
                                icon: Icons.list_outlined,
                                count: '40',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // ── Info ──────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título + ano
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Expanded(
                                  child: Text(
                                    album.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: screenW * 0.055,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                // Ano ao lado do título
                                if (album.releaseDate != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    album.releaseDate!.length >= 4
                                        ? album.releaseDate!.substring(0, 4)
                                        : album.releaseDate!,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.5),
                                      fontSize: 10,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),

                            // Duração abaixo do título
                            if (totalDuration != null)
                              Text(
                                totalDuration!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 9,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            const SizedBox(height: 4),

                            // LP • Feito por artista
                            Row(
                              children: [
                                Text(
                                  'LP',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFFD9D9D9),
                                    shape: OvalBorder(),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Feito por ',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    album.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Descrição
                            if (description != null &&
                                description!.isNotEmpty)
                              Text(
                                description!,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 9,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Botões + Avaliações lado a lado ───────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * 0.05,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Botões à esquerda ──────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundedButton(
                    label: 'Spotify',
                    color: const Color(0xFF1ED760),
                    icon: Icons.music_note,
                    screenW: screenW,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _RoundedButton(
                    label: '  MUSIC',
                    color: Colors.black,
                    icon: Icons.apple,
                    screenW: screenW,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _RoundedButton(
                    label: 'Adicionar a Lista',
                    color: const Color(0xFF262525),
                    icon: Icons.playlist_add,
                    screenW: screenW,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // ── Avaliações à direita ───────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Avaliações',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Estrela + barras + nota
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Estrela à esquerda
                        Icon(
                          Icons.star,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 6),

                        // Barras crescendo
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _VerticalBar(height: 4),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 8),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 13),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 18),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 25),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 32),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 38),
                            const SizedBox(width: 3),
                            _VerticalBar(height: 43),
                          ],
                        ),
                        const SizedBox(width: 8),

                        // Nota + estrelas à direita
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '4.5',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < 4 ? Icons.star : Icons.star_half,
                                  color: Colors.white,
                                  size: 10,
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Counter ──────────────────────────────────────────────────────────────────

class _Counter extends StatelessWidget {
  final IconData icon;
  final String count;

  const _Counter({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 15),
        const SizedBox(height: 2),
        Text(
          count,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 8,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }
}

// ─── Rounded Button ───────────────────────────────────────────────────────────

class _RoundedButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final double screenW;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _RoundedButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.screenW,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenW * 0.38,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vertical Bar ─────────────────────────────────────────────────────────────

class _VerticalBar extends StatelessWidget {
  final double height;

  const _VerticalBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: height,
      color: const Color(0xFFD9D9D9),
    );
  }
}

// ─── Placeholder Cover ────────────────────────────────────────────────────────

class _PlaceholderCover extends StatelessWidget {
  final double size;
  const _PlaceholderCover({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF535353),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Icon(Icons.album, color: Colors.white24, size: 40),
    );
  }
}