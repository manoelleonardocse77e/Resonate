import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/colors.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../models/credit.dart';
import '../services/album_service.dart';
import '../widgets/album_screen/album_header.dart';
import '../widgets/album_screen/album_tabs.dart';
import '../widgets/album_screen/analises_section.dart';
import '../widgets/album_screen/parecidos_section.dart';
import '../widgets/album_screen/review_sheet.dart';

class AlbumScreen extends StatefulWidget {
  final Album album;

  const AlbumScreen({required this.album, super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Track> _tracks = [];
  List<Credit> _credits = [];
  List<String> _genres = [];
  List<Album> _similarAlbums = [];
  Map<String, String> _details = {};
  Map<String, dynamic> _albumDetails = {};
  String? _artistImageUrl;
  String? _description;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final apiKey = dotenv.env['LASTFM_API_KEY'] ?? '';

    final results = await Future.wait([
      AlbumService.fetchTracks(widget.album.id),
      AlbumService.fetchGenres(widget.album.id),
      AlbumService.fetchDetails(widget.album.id),
      AlbumService.fetchAlbumDetails(widget.album.id),
      AlbumService.fetchSimilarAlbums(widget.album.artist, apiKey),
      AlbumService.fetchArtistImage(widget.album.artist, apiKey),
      AlbumService.fetchAlbumDescription(
          widget.album.artist, widget.album.title, apiKey),
    ]);

    final albumDetails = results[3] as Map<String, dynamic>;
    final artistCredit = (albumDetails['artist-credit'] as List?)?.first;
    final artistMbid = artistCredit?['artist']?['id'] ?? '';

    List<Credit> credits = [];
    if (artistMbid.isNotEmpty) {
      credits = await AlbumService.fetchArtistMembers(artistMbid);
    }

    setState(() {
      _tracks = results[0] as List<Track>;
      _genres = results[1] as List<String>;
      _details = results[2] as Map<String, String>;
      _albumDetails = albumDetails;
      _similarAlbums = results[4] as List<Album>;
      _artistImageUrl = results[5] as String?;
      _description = results[6] as String?;
      _credits = credits;
      _loading = false;
    });
  }

  void _abrirReview() {
    
    final artistCredit = (_albumDetails['artist-credit'] as List?)?.first;
    final artistaMbid = artistCredit?['artist']?['id'] ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewSheet(
        albumMbid: widget.album.id,
        albumTitle: widget.album.title,
        albumYear: widget.album.releaseDate?.substring(0, 4) ?? '',
        albumArtUrl: widget.album.coverUrl,
        albumArtist: widget.album.artist,
        artista_mbid: artistaMbid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────
                  AlbumHeader(
                    album: widget.album,
                    details: _albumDetails,
                    artistImageUrl: _artistImageUrl,
                    description: _description,
                  ),

                  // ── Botão de avaliação ────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    child: OutlinedButton.icon(
                      onPressed: _abrirReview,
                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                      label: const Text('Avaliar álbum'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF6C4EE4), width: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  // ── Tabs ──────────────────────────────────
                  AlbumTabs(
                    genres: _genres,
                    tracks: _tracks,
                    details: _details,
                    credits: _credits,
                  ),

                  // ── Análises ──────────────────────────────
                  const SizedBox(height: 24),
                  const AnalisesSection(),

                  // ── Parecidos ─────────────────────────────
                  const SizedBox(height: 24),
                  ParecidosSection(
                    albumTitle: widget.album.title,
                    similarAlbums: _similarAlbums,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}