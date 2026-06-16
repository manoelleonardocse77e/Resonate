import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';
import '../models/track.dart';
import '../models/credit.dart';

class AlbumService {
  static const _mbBase = 'https://musicbrainz.org/ws/2';
  static const _lfmBase = 'https://ws.audioscrobbler.com/2.0';
  static const _mbHeaders = {
    'User-Agent': 'ResonateApp/1.0 (contato@resonate.com)',
    'Accept': 'application/json',
  };

  // ─── Busca detalhes completos do álbum (MusicBrainz) ─────────────────────

  static Future<Map<String, dynamic>> fetchAlbumDetails(String mbid) async {
    try {
      final uri = Uri.parse(
        '$_mbBase/release-group/$mbid'
        '?inc=artists+releases+genres+tags'
        '&fmt=json',
      );
      final response = await http.get(uri, headers: _mbHeaders);
      if (response.statusCode != 200) return {};
      return jsonDecode(response.body);
    } catch (_) {
      return {};
    }
  }

  // ─── Busca faixas do álbum (MusicBrainz) ─────────────────────────────────

  static Future<List<Track>> fetchTracks(String mbid) async {
    try {
      // Busca o release principal do release-group
      final groupUri = Uri.parse(
        '$_mbBase/release-group/$mbid'
        '?inc=releases'
        '&fmt=json',
      );
      final groupResponse = await http.get(groupUri, headers: _mbHeaders);
      if (groupResponse.statusCode != 200) return [];

      final groupData = jsonDecode(groupResponse.body);
      final releases = groupData['releases'] as List? ?? [];
      if (releases.isEmpty) return [];

      // Pega o primeiro release
      final releaseId = releases.first['id'];

      final releaseUri = Uri.parse(
        '$_mbBase/release/$releaseId'
        '?inc=recordings'
        '&fmt=json',
      );
      final releaseResponse = await http.get(releaseUri, headers: _mbHeaders);
      if (releaseResponse.statusCode != 200) return [];

      final releaseData = jsonDecode(releaseResponse.body);
      final media = releaseData['media'] as List? ?? [];
      if (media.isEmpty) return [];

      final tracks = <Track>[];
      for (final medium in media) {
        final trackList = medium['tracks'] as List? ?? [];
        for (final t in trackList) {
          final length = t['length'] as int? ?? 0;
          final minutes = (length / 60000).floor();
          final seconds = ((length % 60000) / 1000).floor();
          tracks.add(Track(
            number: t['position'] ?? tracks.length + 1,
            title: t['title'] ?? '',
            duration:
                '$minutes:${seconds.toString().padLeft(2, '0')}',
          ));
        }
      }
      return tracks;
    } catch (_) {
      return [];
    }
  }

  // ─── Busca créditos do álbum (Last.fm) ───────────────────────────────────

  static Future<List<Credit>> fetchCredits(
      String artist, String album, String apiKey) async {
    try {
      final uri = Uri.parse(
        '$_lfmBase'
        '?method=album.getinfo'
        '&api_key=$apiKey'
        '&artist=${Uri.encodeComponent(artist)}'
        '&album=${Uri.encodeComponent(album)}'
        '&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      // Last.fm não tem créditos diretos, retorna membros da banda via MusicBrainz
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Busca membros/créditos (MusicBrainz) ────────────────────────────────

  static Future<List<Credit>> fetchArtistMembers(String artistMbid) async {
    try {
      final uri = Uri.parse(
        '$_mbBase/artist/$artistMbid'
        '?inc=artist-rels'
        '&fmt=json',
      );
      final response = await http.get(uri, headers: _mbHeaders);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final relations = data['relations'] as List? ?? [];

      return relations
          .where((r) =>
              r['type'] == 'member of band' ||
              r['type'] == 'performer' ||
              r['type'] == 'instrument')
          .map((r) {
            final artist = r['artist'];
            return Credit(
              name: artist?['name'] ?? '',
              role: r['type'] ?? '',
              imageUrl: null, // Last.fm não fornece imagem por artista
            );
          })
          .where((c) => c.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Busca álbuns parecidos (Last.fm) ────────────────────────────────────

  static Future<List<Album>> fetchSimilarAlbums(
      String artist, String apiKey) async {
    try {
      // Busca artistas similares
      final uri = Uri.parse(
        '$_lfmBase'
        '?method=artist.getsimilar'
        '&artist=${Uri.encodeComponent(artist)}'
        '&api_key=$apiKey'
        '&limit=6'
        '&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final artists = data['similarartists']?['artist'] as List? ?? [];

      // Para cada artista similar busca o top álbum no MusicBrainz
      final albums = await Future.wait(
        artists.take(6).map((a) => _fetchTopAlbumByArtist(a['name'] ?? '')),
      );

      return albums.whereType<Album>().toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Album?> _fetchTopAlbumByArtist(String artist) async {
    try {
      final uri = Uri.parse(
        '$_mbBase/release-group'
        '?query=artist:${Uri.encodeComponent(artist)} AND primarytype:Album'
        '&limit=1'
        '&fmt=json',
      );
      final response = await http.get(uri, headers: _mbHeaders);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final groups = data['release-groups'] as List? ?? [];
      if (groups.isEmpty) return null;

      final g = groups.first;
      final artistName = (g['artist-credit'] as List?)
              ?.map((a) => a['name'] ?? '')
              .join(', ') ??
          artist;

      return Album(
        id: g['id'] ?? '',
        title: g['title'] ?? '',
        artist: artistName,
        coverUrl:
            'https://coverartarchive.org/release-group/${g['id']}/front-250',
        artistMbid: '',
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Busca gêneros do álbum (MusicBrainz) ────────────────────────────────

  static Future<List<String>> fetchGenres(String mbid) async {
    try {
      final uri = Uri.parse(
        '$_mbBase/release-group/$mbid'
        '?inc=genres+tags'
        '&fmt=json',
      );
      final response = await http.get(uri, headers: _mbHeaders);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final genres = data['genres'] as List? ?? [];
      final tags = data['tags'] as List? ?? [];

      final allGenres = [
        ...genres.map((g) => g['name'] as String? ?? ''),
        ...tags.map((t) => t['name'] as String? ?? ''),
      ].where((g) => g.isNotEmpty).toSet().toList();

      return allGenres;
    } catch (_) {
      return [];
    }
  }

  // ─── Busca imagem do artista (Last.fm) ───────────────────────────────────────

  static Future<String?> fetchArtistImage(String artist, String apiKey) async {
    try {
      final uri = Uri.parse(
        '$_lfmBase'
        '?method=artist.getinfo'
        '&artist=${Uri.encodeComponent(artist)}'
        '&api_key=$apiKey'
        '&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final images = data['artist']?['image'] as List? ?? [];

      // Pega a maior imagem disponível
      final large = images.lastWhere(
        (img) => img['size'] == 'extralarge' || img['size'] == 'large',
        orElse: () => images.isNotEmpty ? images.last : null,
      );

      final url = large?['#text'] as String? ?? '';
      return url.isNotEmpty ? url : null;
    } catch (_) {
      return null;
    }
  }
  
  // ─── Busca descrição do álbum (Last.fm) ───────────────────────────────────────

  static Future<String?> fetchAlbumDescription(String artist, String album, String apiKey) async {
    try {
      final uri = Uri.parse(
        '$_lfmBase'
        '?method=album.getinfo'
        '&api_key=$apiKey'
        '&artist=${Uri.encodeComponent(artist)}'
        '&album=${Uri.encodeComponent(album)}'
        '&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final summary = data['album']?['wiki']?['summary'] as String? ?? '';
      // Remove tags HTML
      return summary.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    } catch (_) {
      return null;
    }
  }

  // ─── Busca detalhes (estúdio, país, língua) ───────────────────────────────

  static Future<Map<String, String>> fetchDetails(String mbid) async {
    try {
      final groupUri = Uri.parse(
        '$_mbBase/release-group/$mbid'
        '?inc=releases'
        '&fmt=json',
      );
      final groupResponse = await http.get(groupUri, headers: _mbHeaders);
      if (groupResponse.statusCode != 200) return {};

      final groupData = jsonDecode(groupResponse.body);
      final releases = groupData['releases'] as List? ?? [];
      if (releases.isEmpty) return {};

      final releaseId = releases.first['id'];
      final releaseUri = Uri.parse(
        '$_mbBase/release/$releaseId'
        '?inc=labels+artist-credits'
        '&fmt=json',
      );
      final releaseResponse = await http.get(releaseUri, headers: _mbHeaders);
      if (releaseResponse.statusCode != 200) return {};

      final data = jsonDecode(releaseResponse.body);
      final labels = data['label-info'] as List? ?? [];
      final label = labels.isNotEmpty
          ? (labels.first['label']?['name'] ?? '')
          : '';

      return {
        'studio': label,
        'country': data['country'] ?? '',
        'language': data['text-representation']?['language'] ?? '',
      };
    } catch (_) {
      return {};
    }
  }
}
