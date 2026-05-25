import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/album.dart';

class AlbumListScreen extends StatefulWidget {
  final String title;
  final Future<List<Album>> Function() fetchAlbums;

  const AlbumListScreen({
    required this.title,
    required this.fetchAlbums,
    super.key,
  });

  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  List<Album> _albums = [];
  List<Album> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    final albums = await widget.fetchAlbums();
    setState(() {
      _albums = albums;
      _filtered = albums;
      _loading = false;
    });
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _albums.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.artist.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // ── Barra de pesquisa ──────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenW * 0.04,
                    vertical: 10,
                  ),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF535353),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Akshar',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por álbum ou artista...',
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
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // ── Contador de resultados ─────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenW * 0.04),
                  child: Row(
                    children: [
                      Text(
                        '${_filtered.length} resultado${_filtered.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontFamily: 'Akshar',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Grid de álbuns ─────────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum resultado encontrado',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontFamily: 'Akshar',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(screenW * 0.03),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: screenW * 0.02,
                            mainAxisSpacing: screenW * 0.02,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            return _AlbumGridItem(album: _filtered[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ─── Album Grid Item ──────────────────────────────────────────────────────────

class _AlbumGridItem extends StatelessWidget {
  final Album album;

  const _AlbumGridItem({required this.album});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: album.coverUrl != null
                ? Image.network(
                    album.coverUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderCover(),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _PlaceholderCover();
                    },
                  )
                : _PlaceholderCover(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          album.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 10,
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
            fontSize: 9,
            fontFamily: 'Akshar',
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Placeholder Cover ────────────────────────────────────────────────────────

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF535353),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.album, color: Colors.white24, size: 24),
    );
  }
}