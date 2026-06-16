import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/album.dart';

class FavoriteAlbumsService {
  static const _key = 'favorite_albums';

  // ─── Salvar favoritos ─────────────────────────────────────────────────────

  static Future<void> saveFavorites(List<Album> albums) async {
    final prefs = await SharedPreferences.getInstance();
    final data = albums.map((a) => {
      'id': a.id,
      'title': a.title,
      'artist': a.artist,
      'coverUrl': a.coverUrl,
      'releaseDate': a.releaseDate,
    }).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  // ─── Carregar favoritos ───────────────────────────────────────────────────

  static Future<List<Album>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final data = jsonDecode(raw) as List;
    return data.map((a) => Album(
      id: a['id'] ?? '',
      title: a['title'] ?? '',
      artist: a['artist'] ?? '',
      coverUrl: a['coverUrl'],
      releaseDate: a['releaseDate'],
      artistMbid: '',
    )).toList();
  }

  // ─── Adicionar favorito ───────────────────────────────────────────────────

  static Future<void> addFavorite(Album album) async {
    final favorites = await loadFavorites();
    if (!favorites.any((a) => a.id == album.id)) {
      favorites.add(album);
      await saveFavorites(favorites);
    }
  }

  // ─── Remover favorito ─────────────────────────────────────────────────────

  static Future<void> removeFavorite(String albumId) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((a) => a.id == albumId);
    await saveFavorites(favorites);
  }

  // ─── Verificar se é favorito ──────────────────────────────────────────────

  static Future<bool> isFavorite(String albumId) async {
    final favorites = await loadFavorites();
    return favorites.any((a) => a.id == albumId);
  }
}