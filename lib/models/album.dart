class Album {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? releaseDate;
  final int listeners; // ← novo campo

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.releaseDate,
    this.listeners = 0, // ← padrão 0
  });
}