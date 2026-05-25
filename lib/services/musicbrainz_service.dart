import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';
import 'lastfm_service.dart';

class MusicBrainzService {
  static const _baseUrl = 'https://musicbrainz.org/ws/2';

  static const _headers = {
    'User-Agent': 'ResonateApp/1.0 (contato@resonate.com)',
    'Accept': 'application/json',
  };

  // ─────────────────────────────────────────────────────────────
  // Retorna a sexta-feira mais recente
  // ─────────────────────────────────────────────────────────────

  static DateTime _lastFriday(DateTime now) {
    final daysToLastFriday = (now.weekday - DateTime.friday + 7) % 7;
    return now.subtract(Duration(days: daysToLastFriday));
  }

  // ─────────────────────────────────────────────────────────────
  // Lançamentos da semana
  // Sexta passada → Hoje
  // Apenas lançamentos já lançados
  // ─────────────────────────────────────────────────────────────

  static Future<List<Album>> fetchWeekReleases() async {
    try {
      final featuredAlbum = Album(
        id: '054c3793-9de7-46a0-b4d6-7469dd6c4f29',
        title: 'Tsunami Sea',
        artist: 'Spiritbox',
        releaseDate: '2025-03-07',
        coverUrl:
            'https://coverartarchive.org/release-group/054c3793-9de7-46a0-b4d6-7469dd6c4f29/front-250',
      );

      final now = DateTime.now();
      final startOfWeek = _lastFriday(now);
      final endOfWeek = now;

      final from = _formatDate(startOfWeek);
      final to = _formatDate(endOfWeek);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Album'
        '&limit=100'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) return [featuredAlbum];

      final data = jsonDecode(response.body);
      final groups = data['release-groups'] as List? ?? [];

      final rawAlbums = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .take(10)
          .toList();

      // Busca listeners de todos em paralelo
      final listenersResults = await Future.wait(
        rawAlbums.map((a) => LastFmService.fetchListeners(a.artist, a.title)),
      );

      // Combina álbuns com listeners
      final albumsWithListeners = List.generate(rawAlbums.length, (i) {
        return Album(
          id: rawAlbums[i].id,
          title: rawAlbums[i].title,
          artist: rawAlbums[i].artist,
          releaseDate: rawAlbums[i].releaseDate,
          coverUrl: rawAlbums[i].coverUrl,
          listeners: listenersResults[i],
        );
      });

      // Ordena por listeners (mais popular primeiro)
      albumsWithListeners.sort((a, b) => b.listeners.compareTo(a.listeners));

      // Álbum fixo no topo
      albumsWithListeners.insert(0, featuredAlbum);

      return albumsWithListeners;
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Singles da semana
  // Sexta passada → Hoje
  // ─────────────────────────────────────────────────────────────

  static Future<List<Album>> fetchWeekSingles() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));

      final from = _formatDate(sevenDaysAgo);
      final to = _formatDate(now);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Single'
        '&limit=100'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final groups = data['release-groups'] as List? ?? [];

      final rawSingles = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .take(10) // ← limita para 10
          .toList();

      // Busca listeners em paralelo
      final listenersResults = await Future.wait(
        rawSingles.map((a) => LastFmService.fetchListeners(a.artist, a.title)),
      );

      // Combina singles com listeners
      final singlesWithListeners = List.generate(rawSingles.length, (i) {
        return Album(
          id: rawSingles[i].id,
          title: rawSingles[i].title,
          artist: rawSingles[i].artist,
          releaseDate: rawSingles[i].releaseDate,
          coverUrl: rawSingles[i].coverUrl,
          listeners: listenersResults[i],
        );
      });

      // Ordena por listeners (mais popular primeiro)
      singlesWithListeners.sort((a, b) => b.listeners.compareTo(a.listeners));

      return singlesWithListeners;
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Próximos lançamentos
  // Amanhã → próximos 90 dias
  // ─────────────────────────────────────────────────────────────

  static Future<List<Album>> fetchUpcomingReleases() async {
    try {
      final now = DateTime.now();

      final upcomingStart = now.add(const Duration(days: 1));
      final future = upcomingStart.add(const Duration(days: 90));

      final from = _formatDate(upcomingStart);
      final to = _formatDate(future);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Album'
        '&limit=10'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);

      final groups = data['release-groups'] as List? ?? [];

      final albums = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .toList();

      albums.sort(
        (a, b) => DateTime.parse(a.releaseDate!)
            .compareTo(DateTime.parse(b.releaseDate!)),
      );

      return albums;
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Próximos singles
  // Amanhã → próximos 90 dias
  // ─────────────────────────────────────────────────────────────

  static Future<List<Album>> fetchUpcomingSingles() async {
    try {
      final now = DateTime.now();

      final upcomingStart = now.add(const Duration(days: 1));
      final future = upcomingStart.add(const Duration(days: 90));

      final from = _formatDate(upcomingStart);
      final to = _formatDate(future);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Single'
        '&limit=10'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);

      final groups = data['release-groups'] as List? ?? [];

      final singles = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .toList();

      singles.sort(
        (a, b) => DateTime.parse(a.releaseDate!)
            .compareTo(DateTime.parse(b.releaseDate!)),
      );

      return singles;
    } catch (_) {
      return [];
    }
  }

  // ─── Todos lançamentos da semana (sem limite) ─────────────────────────────

  static Future<List<Album>> fetchAllWeekReleases() async {
    try {
      final now = DateTime.now();
      final startOfWeek = _lastFriday(now);
      final endOfWeek = now;

      final from = _formatDate(startOfWeek);
      final to = _formatDate(endOfWeek);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Album'
        '&limit=100'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final groups = data['release-groups'] as List? ?? [];

      final rawAlbums = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .toList(); // ← sem .take(10)

      final listenersResults = await Future.wait(
        rawAlbums.map((a) => LastFmService.fetchListeners(a.artist, a.title)),
      );

      final albumsWithListeners = List.generate(rawAlbums.length, (i) {
        return Album(
          id: rawAlbums[i].id,
          title: rawAlbums[i].title,
          artist: rawAlbums[i].artist,
          releaseDate: rawAlbums[i].releaseDate,
          coverUrl: rawAlbums[i].coverUrl,
          listeners: listenersResults[i],
        );
      });

      albumsWithListeners.sort((a, b) => b.listeners.compareTo(a.listeners));

      return albumsWithListeners;
    } catch (_) {
      return [];
    }
  }

  // ─── Todos próximos lançamentos (sem limite) ──────────────────────────────

  static Future<List<Album>> fetchAllUpcomingReleases() async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final future = now.add(const Duration(days: 90));

      final from = _formatDate(tomorrow);
      final to = _formatDate(future);

      final uri = Uri.parse(
        '$_baseUrl/release-group'
        '?query=firstreleasedate:[$from TO $to] AND primarytype:Album'
        '&limit=100'
        '&fmt=json',
      );

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final groups = data['release-groups'] as List? ?? [];

      final rawAlbums = groups
          .where((g) => _hasFullDate(g['first-release-date']))
          .map((g) => _mapAlbum(g))
          .toList();

      final listenersResults = await Future.wait(
        rawAlbums.map((a) => LastFmService.fetchListeners(a.artist, a.title)),
      );

      final albumsWithListeners = List.generate(rawAlbums.length, (i) {
        return Album(
          id: rawAlbums[i].id,
          title: rawAlbums[i].title,
          artist: rawAlbums[i].artist,
          releaseDate: rawAlbums[i].releaseDate,
          coverUrl: rawAlbums[i].coverUrl,
          listeners: listenersResults[i],
        );
      });

      albumsWithListeners.sort((a, b) => b.listeners.compareTo(a.listeners));

      return albumsWithListeners;
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  static Album _mapAlbum(dynamic g) {
    final artist = (g['artist-credit'] as List?)
            ?.map((a) => a['name'] ?? '')
            .join(', ') ??
        'Desconhecido';

    return Album(
      id: g['id'] ?? '',
      title: g['title'] ?? '',
      artist: artist,
      releaseDate: g['first-release-date'],
      coverUrl:
          'https://coverartarchive.org/release-group/${g['id']}/front-250',
    );
  }

  // Aceita apenas yyyy-mm-dd
  static bool _hasFullDate(String? date) {
    if (date == null) return false;

    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    return regex.hasMatch(date);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}