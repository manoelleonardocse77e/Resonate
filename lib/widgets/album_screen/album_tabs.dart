import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/track.dart';
import '../../models/credit.dart';
import 'tab_generos.dart';
import 'tab_faixas.dart';
import 'tab_detalhes.dart';
import 'tab_creditos.dart';

class AlbumTabs extends StatefulWidget {
  final List<String> genres;
  final List<Track> tracks;
  final Map<String, String> details;
  final List<Credit> credits;

  const AlbumTabs({
    required this.genres,
    required this.tracks,
    required this.details,
    required this.credits,
    super.key,
  });

  @override
  State<AlbumTabs> createState() => _AlbumTabsState();
}

class _AlbumTabsState extends State<AlbumTabs> {
  int _currentTab = 0;

  final _tabs = ['Gênero', 'Faixas', 'Detalhes', 'Créditos'];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tab Bar ────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isActive = index == _currentTab;
              return GestureDetector(
                onTap: () => setState(() => _currentTab = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isActive
                          ? AppColors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontFamily: 'Roboto',
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // ── Tab Content ────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildTab(),
        ),
      ],
    );
  }

  Widget _buildTab() {
    switch (_currentTab) {
      case 0:
        return TabGeneros(
          key: const ValueKey('generos'),
          genres: widget.genres,
        );
      case 1:
        return TabFaixas(
          key: const ValueKey('faixas'),
          tracks: widget.tracks,
        );
      case 2:
        return TabDetalhes(
          key: const ValueKey('detalhes'),
          details: widget.details,
        );
      case 3:
        return TabCreditos(
          key: const ValueKey('creditos'),
          credits: widget.credits,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}