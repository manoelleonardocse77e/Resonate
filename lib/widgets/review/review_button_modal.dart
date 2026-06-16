import 'package:flutter/material.dart';
import '../../models/album.dart';
import '../../services/musicbrainz_service.dart';
import 'review_sheet.dart';

class ReviewButtonModal extends StatefulWidget {
  final Album? currentAlbum; // álbum atual se estiver na AlbumScreen
  final String? artistMbid;

  const ReviewButtonModal({
    this.currentAlbum,
    this.artistMbid,
    super.key,
  });

  @override
  State<ReviewButtonModal> createState() => _ReviewButtonModalState();
}

class _ReviewButtonModalState extends State<ReviewButtonModal> {
  final _controller = TextEditingController();
  List<Album> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final results = await MusicBrainzService.searchAlbums(query);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _openReview(Album album, String artistMbid) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewSheet(
        albumMbid: album.id,
        albumTitle: album.title,
        albumYear: album.releaseDate?.substring(0, 4) ?? '',
        albumArtist: album.artist,
        albumArtUrl: album.coverUrl,
        artistaMbid: artistMbid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      height: screenH * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          const Text(
            'Fazer Review',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Se estiver na tela de álbum mostra opção rápida
          if (widget.currentAlbum != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Álbum atual',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontFamily: 'Akshar',
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openReview(
                      widget.currentAlbum!,
                      widget.artistMbid ?? '',
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C4EE4).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Capa
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: widget.currentAlbum!.coverUrl != null
                                ? Image.network(
                                    widget.currentAlbum!.coverUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _PlaceholderCover(),
                                  )
                                : _PlaceholderCover(),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adicionar ${widget.currentAlbum!.title}...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  widget.currentAlbum!.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                    fontFamily: 'Akshar',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'ou buscar outro',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontFamily: 'Akshar',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Campo de busca
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: widget.currentAlbum == null,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Akshar',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar álbum ou artista...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontFamily: 'Akshar',
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _search,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Resultados
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C4EE4),
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _controller.text.isEmpty
                              ? 'Digite para buscar um álbum'
                              : 'Nenhum resultado encontrado',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontFamily: 'Akshar',
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenW * 0.05,
                        ),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withValues(alpha: 0.05),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final album = _results[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: album.coverUrl != null
                                  ? Image.network(
                                      album.coverUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _PlaceholderCover(),
                                    )
                                  : _PlaceholderCover(),
                            ),
                            title: Text(
                              album.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              album.artist,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontFamily: 'Akshar',
                              ),
                            ),
                            onTap: () => _openReview(album, album.artistMbid),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFF1C1C1C),
      child: const Icon(Icons.album, color: Colors.white12, size: 24),
    );
  }
}