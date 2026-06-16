import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/album.dart';
import '../../services/favorite_albums_service.dart';
import '../../services/musicbrainz_service.dart';

class ProfileFavoriteAlbums extends StatefulWidget {
  final bool isOwnProfile;

  const ProfileFavoriteAlbums({
    this.isOwnProfile = true,
    super.key,
  });

  @override
  State<ProfileFavoriteAlbums> createState() => _ProfileFavoriteAlbumsState();
}

class _ProfileFavoriteAlbumsState extends State<ProfileFavoriteAlbums> {
  List<Album> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteAlbumsService.loadFavorites();
    setState(() => _favorites = favorites);
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SearchAlbumSheet(
        onAlbumSelected: (album) async {
          await FavoriteAlbumsService.addFavorite(album);
          await _loadFavorites();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Álbuns Favoritos',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.isOwnProfile)
                GestureDetector(
                  onTap: _showSearchDialog,
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Grid de favoritos ─────────────────────────
          _favorites.isEmpty
              ? GestureDetector(
                  onTap: widget.isOwnProfile ? _showSearchDialog : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.album_outlined,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isOwnProfile
                              ? 'Adicione seus álbuns favoritos'
                              : 'Nenhum álbum favorito',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 13,
                            fontFamily: 'Akshar',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...(_favorites.take(4).map((album) {
                        final cardW = 85.0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FavoriteAlbumCard(
                            album: album,
                            cardW: cardW,
                            isOwnProfile: widget.isOwnProfile,
                            onRemove: () async {
                              await FavoriteAlbumsService.removeFavorite(album.id);
                              await _loadFavorites();
                            },
                          ),
                        );
                      })),

                      if (widget.isOwnProfile && _favorites.length < 4)
                        GestureDetector(
                          onTap: _showSearchDialog,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 28,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Favorite Album Card ──────────────────────────────────────────────────────

class _FavoriteAlbumCard extends StatelessWidget {
  final Album album;
  final double cardW;
  final bool isOwnProfile;
  final VoidCallback onRemove;

  const _FavoriteAlbumCard({
    required this.album,
    required this.cardW,
    required this.isOwnProfile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
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
                      )
                    : _PlaceholderCover(size: cardW),
              ),

              // Botão remover
              if (isOwnProfile)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Nome do álbum
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          // Nome do artista
          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
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
      child: const Icon(Icons.album, color: Colors.white24, size: 24),
    );
  }
}

// ─── Search Album Sheet ───────────────────────────────────────────────────────

class _SearchAlbumSheet extends StatefulWidget {
  final Function(Album) onAlbumSelected;

  const _SearchAlbumSheet({required this.onAlbumSelected});

  @override
  State<_SearchAlbumSheet> createState() => _SearchAlbumSheetState();
}

class _SearchAlbumSheetState extends State<_SearchAlbumSheet> {
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

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenH * 0.75,
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          const Text(
            'Buscar Álbum',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Campo de busca
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF535353),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Akshar',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por artista ou álbum...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontFamily: 'Akshar',
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
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
                      color: AppColors.primary,
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _controller.text.isEmpty
                              ? 'Digite para buscar'
                              : 'Nenhum resultado encontrado',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontFamily: 'Akshar',
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenW * 0.05),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0xFF2A2A2A),
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
                                          _PlaceholderCover(size: 48),
                                    )
                                  : _PlaceholderCover(size: 48),
                            ),
                            title: Text(
                              album.title,
                              style: const TextStyle(
                                color: AppColors.white,
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
                            onTap: () {
                              widget.onAlbumSelected(album);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}