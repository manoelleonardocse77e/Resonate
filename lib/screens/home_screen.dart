import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import '../screens/album_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Album> _weekReleases = [];
  List<Album> _weekSingles = [];

  List<Album> _upcomingReleases = [];
  List<Album> _upcomingSingles = [];

  bool _loading = true;

  bool _showingSingles = false;
  bool _showingUpcomingSingles = false;

  int _currentIndex = 0;
  String _username = '';
  

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadData();
  }

  Future<void> _loadUser() async {
  final user = Supabase.instance.client.auth.currentUser;
  setState(() {
    _username = user?.userMetadata?['username'] ??
        user?.userMetadata?['first_name'] ??
        'Usuário';
  });
}

  Future<void> _loadData() async {
    final week = await MusicBrainzService.fetchWeekReleases();

    final singles = await MusicBrainzService.fetchWeekSingles();

    final upcoming =
        await MusicBrainzService.fetchUpcomingReleases();

    final upcomingSingles =
        await MusicBrainzService.fetchUpcomingSingles();

    setState(() {
      _weekReleases = week;
      _weekSingles = singles;

      _upcomingReleases = upcoming;
      _upcomingSingles = upcomingSingles;

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenW = mediaQuery.size.width;

    final screenH = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenu(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // sem currentAlbum pois não estamos na AlbumScreen
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────

                    HomeHeader(screenW: screenW),

                    // ── Saudação ───────────────────────────

                    HomeGreeting(
                      username: _username,
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.025),

                    // ── Novidade entre amigos ─────────────

                    SectionHeader(
                      title: 'Novidade entre os amigos',
                      screenW: screenW,
                      onVerMais: () {},
                    ),

                    const SizedBox(height: 12),

                    PlaceholderCarousel(
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.025),

                    // Lançamentos da semana
                    SectionHeader(
                      title: 'Lançamentos da semana',
                      screenW: screenW,
                      toggleLabel: _showingSingles ? 'Singles' : 'Álbuns',
                      onToggle: () {
                        setState(() {
                          _showingSingles = !_showingSingles;
                        });
                      },
                      onVerMais: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlbumListScreen(
                            title: _showingSingles
                                ? 'Singles da semana'
                                : 'Lançamentos da semana',
                            fetchAlbums: _showingSingles
                                ? MusicBrainzService.fetchWeekSingles
                                : MusicBrainzService.fetchAllWeekReleases,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    AlbumCarousel(
                      albums: _showingSingles ? _weekSingles : _weekReleases,
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.025),

                    // ── Próximos lançamentos ──────────────

                    SectionHeader(
                      title: 'Próximos Lançamentos',
                      screenW: screenW,
                      toggleLabel: _showingUpcomingSingles ? 'Singles' : 'Álbuns',
                      onToggle: () {
                        setState(() {
                          _showingUpcomingSingles = !_showingUpcomingSingles;
                        });
                      },
                      onVerMais: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlbumListScreen(
                            title: _showingUpcomingSingles
                                ? 'Próximos Singles'
                                : 'Próximos Lançamentos',
                            fetchAlbums: _showingUpcomingSingles
                                ? MusicBrainzService.fetchUpcomingSingles
                                : MusicBrainzService.fetchAllUpcomingReleases,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    AlbumCarousel(
                      albums: _showingUpcomingSingles ? _upcomingSingles : _upcomingReleases,
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.025),

                    // ── Análises recentes ─────────────────

                    SectionHeader(
                      title: 'Análises recentes',
                      screenW: screenW,
                      onVerMais: () {},
                    ),

                    const SizedBox(height: 12),

                    PlaceholderList(
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.025),

                    // ── Listas populares ──────────────────

                    SectionHeader(
                      title: 'Listas populares do mês',
                      screenW: screenW,
                      onVerMais: () {},
                    ),

                    const SizedBox(height: 12),

                    PlaceholderCarousel(
                      screenW: screenW,
                    ),

                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
      ),
    );
  }
}