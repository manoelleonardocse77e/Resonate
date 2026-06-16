import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../widgets/home_screen/side_menu.dart';
import '../widgets/profile_screen/profile_header.dart';
import '../widgets/profile_screen/profile_stats.dart';
import '../widgets/profile_screen/profile_favorite_albums.dart';
import '../widgets/profile_screen/profile_recent_ratings.dart';
import '../widgets/profile_screen/profile_analyses.dart';
import '../widgets/profile_screen/profile_lists.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnProfile;

  const ProfileScreen({
    this.isOwnProfile = true,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _name = user?.userMetadata?['first_name'] ?? 'Usuário';
      _username = user?.userMetadata?['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenH = mediaQuery.size.height
        - mediaQuery.padding.top
        - mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            ProfileHeader(
              name: _name,
              username: _username,
              location: 'Brasil, Recife',
              instagram: 'inofilms...',
              letterboxd: 'inofilms...',
              isOwnProfile: widget.isOwnProfile,
            ),

            // ── Stats ────────────────────────────────────
            const ProfileStats(),
            SizedBox(height: screenH * 0.025),

            // ── Álbuns Favoritos ─────────────────────────
            ProfileFavoriteAlbums(
              isOwnProfile: widget.isOwnProfile,
            ),
            SizedBox(height: screenH * 0.025),

            // ── Avaliados Recentes ───────────────────────
            const ProfileRecentRatings(),
            SizedBox(height: screenH * 0.025),

            // ── Análises ─────────────────────────────────
            const ProfileAnalyses(),
            SizedBox(height: screenH * 0.025),

            // ── Listas ───────────────────────────────────
            const ProfileLists(),
            SizedBox(height: screenH * 0.04),
          ],
        ),
      ),
    );
  }
}