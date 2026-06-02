import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/track.dart';

class TabFaixas extends StatelessWidget {
  final List<Track> tracks;

  const TabFaixas({required this.tracks, super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    if (tracks.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(screenW * 0.05),
        child: Center(
          child: Text(
            'Nenhuma faixa encontrada',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Akshar',
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Cabeçalho ──────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * 0.05,
            vertical: 8,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '#',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Título',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Icon(
                Icons.access_time,
                color: Colors.white.withValues(alpha: 0.4),
                size: 14,
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF2A2A2A), thickness: 1),

        // ── Lista de faixas ────────────────────────────────
        ...tracks.map((track) => _TrackItem(track: track, screenW: screenW)),
      ],
    );
  }
}

// ─── Track Item ───────────────────────────────────────────────────────────────

class _TrackItem extends StatelessWidget {
  final Track track;
  final double screenW;

  const _TrackItem({required this.track, required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.05,
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${track.number}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            track.duration,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}