import 'package:flutter/material.dart';
import '../../models/album.dart';
import 'album_card.dart';

class AlbumCarousel extends StatelessWidget {
  final List<Album> albums;
  final double screenW;

  const AlbumCarousel({
    required this.albums,
    required this.screenW,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = screenW * 0.35;

    if (albums.isEmpty) {
      return SizedBox(
        height: cardW + 50,
        child: Center(
          child: Text(
            'Nenhum álbum encontrado',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Akshar',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: cardW + 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
        itemCount: albums.length,
        separatorBuilder: (_, __) => SizedBox(width: screenW * 0.03),
        itemBuilder: (context, index) {
          return AlbumCard(
            album: albums[index],
            cardW: cardW,
          );
        },
      ),
    );
  }
}