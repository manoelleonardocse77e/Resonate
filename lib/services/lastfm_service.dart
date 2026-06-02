import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LastFmService {
  static final _apiKey = dotenv.env['LASTFM_API_KEY'] ?? '';
  static const _baseUrl = 'https://ws.audioscrobbler.com/2.0';

  // ─── Busca listeners de um álbum ─────────────────────────────────────────

  static Future<int> fetchListeners(String artist, String album) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl'
        '?method=album.getinfo'
        '&api_key=$_apiKey'
        '&artist=${Uri.encodeComponent(artist)}'
        '&album=${Uri.encodeComponent(album)}'
        '&format=json',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      final listeners = data['album']?['listeners'];
      return int.tryParse(listeners?.toString() ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }
}