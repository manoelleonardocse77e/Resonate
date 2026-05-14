import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/album.dart';
import '../services/musicbrainz_service.dart';
import '../widgets/home_screen/home_header.dart';
import '../widgets/home_screen/home_greeting.dart';
import '../widgets/home_screen/section_header.dart';
import '../widgets/home_screen/album_carousel.dart';
import '../widgets/home_screen/placeholder_carousel.dart';
import '../widgets/home_screen/placeholder_list.dart';
import '../widgets/home_screen/side_menu.dart';
import '../widgets/home_screen/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Album> _weekReleases = [];
  List<Album> _weekSingles = [];
  List<Album> _upcomingReleases = [];
  bool _loading = true;
  bool _showingSingles = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final week = await MusicBrainzService.fetchWeekReleases();
    final singles = await MusicBrainzService.fetchWeekSingles();
    final upcoming = await MusicBrainzService.fetchUpcomingReleases();
    setState(() {
      _weekReleases = week;
      _weekSingles = singles;
      _upcomingReleases = upcoming;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenW = mediaQuery.size.width;
    final screenH = mediaQuery.size.height
        - mediaQuery.padding.top
        - mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenu(),
      bottomNavigationBar: BottomNavBar( // ← adicione isso
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // TODO: navegar para as telas correspondentes
        },
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────
                    HomeHeader(screenW: screenW),

                    // ── Saudação ────────────────────────────────────
                    HomeGreeting(
                      username: 'Jefersson',
                      screenW: screenW,
                    ),
                    SizedBox(height: screenH * 0.025),

                    // ── Novidades entre amigos (placeholder) ────────
                    SectionHeader(
                      title: 'Novidade entre os amigos',
                      screenW: screenW,
                      onVerMais: () {},
                    ),
                    const SizedBox(height: 12),
                    PlaceholderCarousel(screenW: screenW),
                    SizedBox(height: screenH * 0.025),

                    // ── Lançamentos da semana ───────────────────────
                    SectionHeader(
                      title: 'Lançamentos da semana',
                      screenW: screenW,
                      toggleLabel: _showingSingles ? 'Singles' : 'Álbuns',
                      onToggle: () {
                        setState(() {
                          _showingSingles = !_showingSingles;
                        });
                      },
                      onVerMais: () {},
                    ),
                    const SizedBox(height: 12),
                    AlbumCarousel(
                      albums: _showingSingles ? _weekSingles : _weekReleases,
                      screenW: screenW,
                    ),
                    SizedBox(height: screenH * 0.025),

                    // ── Próximos lançamentos ────────────────────────
                    SectionHeader(
                      title: 'Próximos Lançamentos',
                      screenW: screenW,
                      onVerMais: () {},
                    ),
                    const SizedBox(height: 12),
                    AlbumCarousel(
                      albums: _upcomingReleases,
                      screenW: screenW,
                    ),
                    SizedBox(height: screenH * 0.025),

                    // ── Análises recentes (placeholder) ─────────────
                    SectionHeader(
                      title: 'Análises recentes',
                      screenW: screenW,
                      onVerMais: () {},
                    ),
                    const SizedBox(height: 12),
                    PlaceholderList(screenW: screenW),
                    SizedBox(height: screenH * 0.025),

                    // ── Listas populares (placeholder) ──────────────
                    SectionHeader(
                      title: 'Listas populares do mês',
                      screenW: screenW,
                      onVerMais: () {},
                    ),
                    const SizedBox(height: 12),
                    PlaceholderCarousel(screenW: screenW),
                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
      ),
    );
  }
}