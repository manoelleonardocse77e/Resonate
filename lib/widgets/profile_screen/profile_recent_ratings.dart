import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/colors.dart';
import '../../models/album.dart';
import '../../screens/album_screen.dart';

class ProfileRecentRatings extends StatefulWidget {
  const ProfileRecentRatings({super.key});

  @override
  State<ProfileRecentRatings> createState() => _ProfileRecentRatingsState();
}

class _ProfileRecentRatingsState extends State<ProfileRecentRatings> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Busca as reviews do usuário com os dados do álbum
      final data = await _supabase
          .from('review')
          .select('id_review, nota, created_at, album_mbid, album(titulo, cover_url, artista(nome), artista_mbid)')
          .eq('id_usuario', userId)
          .order('created_at', ascending: false)
          .limit(4);

      setState(() {
        _reviews = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = (screenW * 0.9 - 32) / 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ────────────────────────────────────
          const Text(
            'Avaliados Recentes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // ── Cards ─────────────────────────────────────
          _loading
              ? _PlaceholderRow(cardW: cardW)
              : _reviews.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Nenhuma avaliação ainda',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontFamily: 'Akshar',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: _reviews.map((review) {
                        final albumData = review['album'] as Map<String, dynamic>?;
                        final albumObj = Album(
                            id: review['album_mbid'] ?? '',
                            title: albumData?['titulo'] ?? '',
                            artist: (albumData?['artista'] as Map<String, dynamic>?)?['nome'] ?? '',
                            artistMbid: albumData?['artista_mbid'] ?? '',
                            coverUrl: albumData?['cover_url'],
                          );    

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlbumScreen(album: albumObj),
                                ),
                              );
                            },
                            child: _RatingCard(
                              cardW: cardW,
                              coverUrl: albumData?['cover_url'],
                              title: albumData?['titulo'] ?? '',
                              nota: (review['nota'] as num?)?.toInt() ?? 0,
                              artista: (albumData?['artista'] as Map<String, dynamic>?)?['nome'] ?? '',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

// ─── Rating Card ──────────────────────────────────────────────────────────────

class _RatingCard extends StatelessWidget {
  final double cardW;
  final String? coverUrl;
  final String title;
  final String artista;
  final int nota;

  const _RatingCard({
    required this.cardW,
    required this.coverUrl,
    required this.title,
    required this.artista,
    required this.nota,
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
            child: coverUrl != null
                ? Image.network(
                    coverUrl!,
                    width: cardW,
                    height: cardW,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _PlaceholderCover(size: cardW),
                  )
                : _PlaceholderCover(size: cardW),
          ),
          const SizedBox(height: 6),

          // Estrelas
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < nota ? Icons.star : Icons.star_outline,
                color: AppColors.primary,
                size: 10,
              );
            }),
          ),
          const SizedBox(height: 3),

          // Título
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),

          // Artista
          Text(
            artista,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 8,
              fontFamily: 'Akshar',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder Row ──────────────────────────────────────────────────────────

class _PlaceholderRow extends StatelessWidget {
  final double cardW;
  const _PlaceholderRow({required this.cardW});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
          child: Column(
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
              Row(
                children: List.generate(4, (i) {
                  return Icon(
                    i < 3 ? Icons.star : Icons.star_half,
                    color: AppColors.primary,
                    size: 10,
                  );
                }),
              ),
              const SizedBox(height: 3),
              Container(
                width: cardW * 0.8,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF535353),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
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
      child: const Icon(Icons.album, color: Colors.white24, size: 20),
    );
  }
}