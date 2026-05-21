// lib/services/album_service.dart
// Serviço Flutter — toda a lógica fica na Edge Function.
// Fontes externas: MusicBrainz, Cover Art Archive, iTunes, Wikimedia.
// O Flutter só chama um endpoint e recebe os dados prontos.
//
// Dependências no pubspec.yaml:
//   supabase_flutter: ^2.0.0

import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Modelos ──────────────────────────────────────────────────────────────────

class Album {
  final String albumMbid;
  final String titulo;
  final String? coverUrl;      // Cover Art Archive → iTunes (fallback)
  final String? lancamento;
  final String? gravadora;
  final List<String> generos;  // MusicBrainz + iTunes
  final String? pais;
  final String? idioma;
  final String artistaMbid;
  final String artistaNome;
  final String? artistaFoto;   // Wikimedia/Wikidata
  final double? notaMedia;
  final int totalReviews;

  const Album({
    required this.albumMbid,
    required this.titulo,
    this.coverUrl,
    this.lancamento,
    this.gravadora,
    required this.generos,
    this.pais,
    this.idioma,
    required this.artistaMbid,
    required this.artistaNome,
    this.artistaFoto,
    this.notaMedia,
    required this.totalReviews,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        albumMbid:    json['album_mbid']    as String,
        titulo:       json['titulo']         as String,
        coverUrl:     json['cover_url']      as String?,
        lancamento:   json['lancamento']     as String?,
        gravadora:    json['gravadora']      as String?,
        generos:      List<String>.from(json['generos'] as List? ?? []),
        pais:         json['pais']           as String?,
        idioma:       json['idioma']         as String?,
        artistaMbid:  json['artista_mbid']   as String,
        artistaNome:  json['artista_nome']   as String,
        artistaFoto:  json['artista_foto']   as String?,
        notaMedia:    (json['nota_media']    as num?)?.toDouble(),
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      );
}

class AlbumStats {
  final String albumMbid;
  final String titulo;
  final String? coverUrl;
  final String? lancamento;
  final String? gravadora;
  final List<String> generos;
  final String? pais;
  final String? idioma;
  final String artistaMbid;
  final String artistaNome;
  final String? artistaFoto;
  final int totalReviews;
  final double? notaMedia;

  const AlbumStats({
    required this.albumMbid,
    required this.titulo,
    this.coverUrl,
    this.lancamento,
    this.gravadora,
    required this.generos,
    this.pais,
    this.idioma,
    required this.artistaMbid,
    required this.artistaNome,
    this.artistaFoto,
    required this.totalReviews,
    this.notaMedia,
  });

  factory AlbumStats.fromJson(Map<String, dynamic> json) => AlbumStats(
        albumMbid:    json['album_mbid']    as String,
        titulo:       json['titulo']         as String,
        coverUrl:     json['cover_url']      as String?,
        lancamento:   json['lancamento']     as String?,
        gravadora:    json['gravadora']      as String?,
        generos:      List<String>.from(json['generos'] as List? ?? []),
        pais:         json['pais']           as String?,
        idioma:       json['idioma']         as String?,
        artistaMbid:  json['artista_mbid']   as String,
        artistaNome:  json['artista_nome']   as String,
        artistaFoto:  json['artista_foto']   as String?,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        notaMedia:    (json['nota_media']    as num?)?.toDouble(),
      );
}

class Musica {
  final String musicaMbid;
  final String nome;
  final int? posicao;
  final int? duracaoMs;

  const Musica({
    required this.musicaMbid,
    required this.nome,
    this.posicao,
    this.duracaoMs,
  });

  factory Musica.fromJson(Map<String, dynamic> json) => Musica(
        musicaMbid: json['musica_mbid'] as String,
        nome:       json['nome']        as String,
        posicao:    json['posicao']     as int?,
        duracaoMs:  json['duracao_ms']  as int?,
      );

  String get duracaoFormatada {
    if (duracaoMs == null) return '--:--';
    final total = duracaoMs! ~/ 1000;
    final min   = total ~/ 60;
    final seg   = total % 60;
    return '$min:${seg.toString().padLeft(2, '0')}';
  }
}

// ─── Serviço ──────────────────────────────────────────────────────────────────

class AlbumService {
  AlbumService._();
  static final instance = AlbumService._();

  final _supabase = Supabase.instance.client;

  // ── RF-01: Busca álbuns ───────────────────────────────────────────────────
  // Fluxo: cache Supabase → MusicBrainz + Cover Art Archive + iTunes + Wikimedia
  Future<List<Album>> buscarAlbuns({
    String? titulo,
    String? artista,
    String? gravadora,
    String? ano,
  }) async {
    final response = await _supabase.functions.invoke(
      'search-albums', // nome da Edge Function (com "s")
      body: {
        if (titulo    != null) 'titulo':    titulo,
        if (artista   != null) 'artista':   artista,
        if (gravadora != null) 'gravadora': gravadora,
        if (ano       != null) 'ano':        ano,
      },
    );

    if (response.status != 200) {
      throw Exception('Erro na busca de álbuns: ${response.data}');
    }

    final results = response.data['results'] as List? ?? [];
    return results
        .map((json) => Album.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── RF-02: Detalhes e estatísticas do álbum ───────────────────────────────
  Future<AlbumStats?> buscarDetalhesAlbum(String albumMbid) async {
    final data = await _supabase
        .from('vw_album_stats')
        .select()
        .eq('album_mbid', albumMbid)
        .maybeSingle();

    if (data == null) return null;
    return AlbumStats.fromJson(data);
  }

  // ── RF-02: Tracklist ──────────────────────────────────────────────────────
  Future<List<Musica>> buscarTracklist(String albumMbid) async {
    final data = await _supabase
        .from('musica')
        .select()
        .eq('album_mbid', albumMbid)
        .order('posicao');

    return data.map((json) => Musica.fromJson(json)).toList();
  }

  // ── RF-03: Criar / editar review ──────────────────────────────────────────
  Future<void> salvarReview({
    required String albumMbid,
    required double nota,
    String? corpo,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase.from('review').upsert(
      {
        'id_usuario': userId,
        'album_mbid': albumMbid,
        'nota':       nota,
        'corpo':      corpo,
      },
      onConflict: 'id_usuario,album_mbid',
    );
  }

  // ── RF-04: Reviews de um álbum ────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> buscarReviewsAlbum(
    String albumMbid, {
    bool ordenarPorNota = false,
  }) async {
    final query = _supabase
        .from('review')
        .select('*, usuario(nickname, foto_url)')
        .eq('album_mbid', albumMbid);

    final orderedQuery = ordenarPorNota
        ? query.order('nota',       ascending: false)
        : query.order('created_at', ascending: false);

    return await orderedQuery;
  }

  // ── RF-05: Seguir / deixar de seguir ──────────────────────────────────────
  Future<void> seguirUsuario(String seguidoId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase.from('seguidor').insert({
      'seguidor_id': userId,
      'seguido_id':  seguidoId,
    });
  }

  Future<void> deixarDeSeguir(String seguidoId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase
        .from('seguidor')
        .delete()
        .eq('seguidor_id', userId)
        .eq('seguido_id',  seguidoId);
  }

  // ── RF-06: Feed social ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> buscarFeed() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    final seguidos = await _supabase
        .from('seguidor')
        .select('seguido_id')
        .eq('seguidor_id', userId);

    if (seguidos.isEmpty) return [];

    final seguidosIds =
        seguidos.map((s) => s['seguido_id'] as String).toList();

    return await _supabase
        .from('vw_feed_social')
        .select()
        .inFilter('id_usuario', seguidosIds)
        .limit(50);
  }

  // ── RF-07: Curtir / descurtir review ──────────────────────────────────────
  Future<void> curtirReview(String idReview) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase.from('review_curtida').insert({
      'id_review':  idReview,
      'id_usuario': userId,
    });
  }

  Future<void> descurtirReview(String idReview) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase
        .from('review_curtida')
        .delete()
        .eq('id_review',  idReview)
        .eq('id_usuario', userId);
  }

  // ── RF-07: Notificações ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> buscarNotificacoes() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    return await _supabase
        .from('notificacao')
        .select()
        .eq('id_usuario', userId)
        .order('created_at', ascending: false)
        .limit(50);
  }

  Future<void> marcarNotificacaoComoLida(String idNotificacao) async {
    await _supabase
        .from('notificacao')
        .update({'lida': true})
        .eq('id_notificacao', idNotificacao);
  }

  // ── RF-08 / RF-10: Listas ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> buscarMinhasListas() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    return await _supabase
        .from('lista')
        .select('*, lista_album(count)')
        .eq('id_usuario', userId)
        .order('created_at', ascending: false);
  }

  Future<void> criarLista({required String titulo, String? descricao}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    await _supabase.from('lista').insert({
      'id_usuario': userId,
      'titulo':     titulo,
      'descricao':  descricao,
    });
  }

  Future<void> adicionarAlbumNaLista({
    required String idLista,
    required String albumMbid,
    int posicao = 0,
  }) async {
    await _supabase.from('lista_album').upsert(
      {'id_lista': idLista, 'album_mbid': albumMbid, 'posicao': posicao},
      onConflict: 'id_lista,album_mbid',
    );
  }

  Future<void> removerAlbumDaLista({
    required String idLista,
    required String albumMbid,
  }) async {
    await _supabase
        .from('lista_album')
        .delete()
        .eq('id_lista',   idLista)
        .eq('album_mbid', albumMbid);
  }

  // ── RF-09: Perfil com estatísticas ───────────────────────────────────────
  Future<Map<String, dynamic>?> buscarPerfil(String userId) async {
    return await _supabase
        .from('vw_usuario_perfil')
        .select()
        .eq('id_usuario', userId)
        .maybeSingle();
  }

  // ── Realtime: notificações em tempo real ──────────────────────────────────
  //
  // Uso na widget:
  //   final channel = AlbumService.instance.escutarNotificacoes((p) {
  //     setState(() { /* atualiza badge */ });
  //   });
  //   // no dispose: channel.unsubscribe();
  RealtimeChannel escutarNotificacoes(void Function(Map payload) onNew) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado.');

    return _supabase
        .channel('notificacoes-$userId')
        .onPostgresChanges(
          event:  PostgresChangeEvent.insert,
          schema: 'public',
          table:  'notificacao',
          filter: PostgresChangeFilter(
            type:   PostgresChangeFilterType.eq,
            column: 'id_usuario',
            value:  userId,
          ),
          callback: (payload) => onNew(payload.newRecord),
        )
        .subscribe();
  }
}