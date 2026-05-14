import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';

class MusicBrainzService {
  static const _baseUrl = 'https://musicbrainz.org/ws/2';
  static const _headers = {
    'User-Agent': 'ResonateApp/1.0 (contato@resonate.com)',
    'Accept': 'application/json',
  };

  // ─── Lançamentos da semana (sexta a sexta) ────────────────────────────────

  static Future<List<Album>> fetchWeekReleases() async {
    try {
      final now = DateTime.now();

      // Acha a sexta-feira anterior (ou hoje se for sexta)
      final daysFromFriday = (now.weekday - DateTime.friday) % 7;
      final lastFriday = now.subtract(Duration(days: daysFromFriday));

      // Próxima sexta-feira
      final nextFriday = lastFriday.add(const Duration(days: 7));

      final from = _formatDate(lastFriday);
      final to = _formatDate(nextFriday);

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

      return groups.map((g) => _mapAlbum(g)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Próximos lançamentos (por data futura) ───────────────────────────────

  static Future<List<Album>> fetchUpcomingReleases() async {
    try {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 90));

      final from = _formatDate(now);
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

      return groups.map((g) => _mapAlbum(g)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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

  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}