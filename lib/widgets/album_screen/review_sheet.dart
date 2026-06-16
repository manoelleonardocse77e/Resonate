import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewSheet extends StatefulWidget {
  final String albumMbid;
  final String albumTitle;
  final String albumYear;
  final String albumArtist;
  final String? albumArtUrl;
  final String artista_mbid;

  const ReviewSheet({
    super.key,
    required this.albumMbid,
    required this.albumTitle,
    required this.albumYear,
    required this.albumArtist,
    required this.artista_mbid,
    this.albumArtUrl,
  });

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();

  int _nota = 0;
  int _hoveredNota = 0;
  bool _liked = false;
  bool _loading = false;

  static const _purple = Color(0xFF6C4EE4);
  static const _bg = Color(0xFF121212);
  static const _surface = Color(0xFF1C1C1C);

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

Future<void> _publicar() async {
  if (_nota == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione uma nota antes de publicar.')),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final userId = _supabase.auth.currentUser?.id;

    // 1️⃣ Garante que o artista existe
    await _supabase.from('artista').upsert(
      {
        'artista_mbid': widget.artista_mbid,
        'nome': widget.albumArtist,
      },
      onConflict: 'artista_mbid',
    );

    // 2️⃣ Garante que o álbum existe
    await _supabase.from('album').upsert(
      {
        'album_mbid': widget.albumMbid,
        'titulo': widget.albumTitle,
        'lancamento': widget.albumYear,
        'cover_url': widget.albumArtUrl,
        'artista_mbid': widget.artista_mbid,
      },
      onConflict: 'album_mbid',
    );

    // 3️⃣ Insere a review
    await _supabase.from('review').insert({
      'id_usuario': userId,
      'album_mbid': widget.albumMbid,
      'nota': _nota,
      'corpo': _controller.text.trim(),
    });

    if (mounted) Navigator.pop(context, true);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Header: voltar + título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 20),
                ),
                const Text(
                  'Avalie esse álbum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Conteúdo com scroll (para teclado não cortar)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Álbum info + capa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.albumTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.albumYear,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Data da avaliação
                            const Text(
                              'Data da avaliação',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _purple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formattedDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.white38, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Capa do álbum
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: widget.albumArtUrl != null
                            ? Image.network(
                                widget.albumArtUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _albumArtPlaceholder(),
                              )
                            : _albumArtPlaceholder(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Estrelas
                  const Text(
                    'Avalie',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled =
                            i < (_hoveredNota > 0 ? _hoveredNota : _nota);
                        return GestureDetector(
                          onTap: () => setState(() => _nota = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 32,
                              color: filled ? _purple : Colors.white24,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => _liked = !_liked),
                        child: Icon(
                          _liked
                              ? Icons.thumb_up_rounded
                              : Icons.thumb_up_outlined,
                          size: 26,
                          color: _liked ? _purple : Colors.white30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Campo de texto
                  TextField(
                    controller: _controller,
                    maxLines: 7,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Escreva aqui sua avaliação...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1), width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1), width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _purple, width: 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão publicar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _publicar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        disabledBackgroundColor: _purple.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Publicar',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _albumArtPlaceholder() {
    return Container(
      width: 88,
      height: 88,
      color: _surface,
      child: const Icon(Icons.album_rounded, color: Colors.white12, size: 36),
    );
  }
}