import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/album.dart';

class ParecidosSection extends StatelessWidget {
  final String albumTitle;
  final List<Album> similarAlbums;

  const ParecidosSection({
    required this.albumTitle,
    required this.similarAlbums,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW * 0.35;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
          child: Text(
            'Parecidos com $albumTitle',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),

        similarAlbums.isEmpty
            ? SizedBox(
                height: cardW + 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
                  itemCount: 5,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: screenW * 0.03),
                  itemBuilder: (_, __) => _PlaceholderCard(cardW: cardW),
                ),
              )
            : SizedBox(
                height: cardW + 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
                  itemCount: similarAlbums.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: screenW * 0.03),
                  itemBuilder: (context, index) {
                    final album = similarAlbums[index];
                    return _SimilarAlbumCard(album: album, cardW: cardW);
                  },
                ),
              ),
      ],
    );
  }
}

// ─── Similar Album Card ───────────────────────────────────────────────────────

class _SimilarAlbumCard extends StatelessWidget {
  final Album album;
  final double cardW;

  const _SimilarAlbumCard({required this.album, required this.cardW});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

// ─── Placeholder Card ─────────────────────────────────────────────────────────

class _PlaceholderCard extends StatelessWidget {
  final double cardW;

  const _PlaceholderCard({required this.cardW});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: cardW,
          height: cardW,
          decoration: BoxDecoration(
            color: const Color(0xFF535353),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: cardW * 0.8,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF535353),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: cardW * 0.5,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
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