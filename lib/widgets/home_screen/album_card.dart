import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final double cardW;

  const AlbumCard({
    required this.album,
    required this.cardW,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capa
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: album.coverUrl != null
                ? Image.network(
                    album.coverUrl!,
                    width: cardW,
                    height: cardW,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _PlaceholderCover(size: cardW),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _PlaceholderCover(size: cardW);
                    },
                  )
                : _PlaceholderCover(size: cardW),
          ),
          const SizedBox(height: 6),
          // Título
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          // Artista
          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.album, color: Colors.white24, size: 40),
    );
  }
}