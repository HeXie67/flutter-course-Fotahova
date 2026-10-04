import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Музыкальные альбомы',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFAFAFAF), // Серый фон как на макете
        useMaterial3: true,
      ),
      home: const MusicCatalogScreen(),
    );
  }
}

// Модель данных для альбома
class Album {
  final String title;
  final String artist;
  final int year;
  final List<String> genres;
  final Color coverColor;
  final IconData categoryIcon;
  final bool isFavorite;

  const Album({
    required this.title,
    required this.artist,
    required this.year,
    required this.genres,
    required this.coverColor,
    required this.categoryIcon,
    this.isFavorite = false,
  });
}

class MusicCatalogScreen extends StatelessWidget {
  const MusicCatalogScreen({super.key});

  // Список из 8+ альбомов
  final List<Album> albums = const [
    Album(
      title: 'The Dark Side of the Moon',
      artist: 'Pink Floyd',
      year: 1973,
      genres: ['Прог-рок', 'Рок'],
      coverColor: Color(0xFF2D3250),
      categoryIcon: Icons.album,
      isFavorite: true,
    ),
    Album(
      title: 'Worldenddominator',
      artist: 'zts',
      year: 2009,
      genres: ['Рок', 'Поп'],
      coverColor: Color(0xFF2C5E3B),
      categoryIcon: Icons.music_note,
      isFavorite: false,
    ),
    Album(
      title: 'Claire De Lune',
      artist: 'Клод Дебюсси',
      year: 1890,
      genres: ['Классика'],
      coverColor: Color(0xFF8B4513),
      categoryIcon: Icons.graphic_eq,
      isFavorite: true,
    ),
    Album(
      title: 'Колыбельная',
      artist: 'Петр Ильич Чайковский',
      year: 1893,
      genres: ['Классика'],
      coverColor: Color(0xFF800020),
      categoryIcon: Icons.music_note,
      isFavorite: false,
    ),
    Album(
      title: 'Nevermind',
      artist: 'Nirvana',
      year: 1991,
      genres: ['Гранж', 'Альт-рок'],
      coverColor: Color(0xFF1E3A8A),
      categoryIcon: Icons.album,
      isFavorite: true,
    ),
    Album(
      title: 'Still with you',
      artist: 'JungKook',
      year: 2020,
      genres: ['K-поп'],
      coverColor: Color(0xFF374151),
      categoryIcon: Icons.music_note,
      isFavorite: false,
    ),
    Album(
      title: 'A Night at the Opera',
      artist: 'Queen',
      year: 1975,
      genres: ['Рок', 'Оперный рок'],
      coverColor: Color(0xFF7C3AED),
      categoryIcon: Icons.album,
      isFavorite: false,
    ),
    Album(
      title: 'Last Twilight',
      artist: 'William Jakrapart',
      year: 2024,
      genres: ['T-поп'],
      coverColor: Color(0xFF0F766E),
      categoryIcon: Icons.graphic_eq,
      isFavorite: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог альбомов'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Каталог альбомов',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${albums.length} альбомов в каталоге',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // Список карточек
            ...albums.map((album) => AlbumCard(album: album)),
          ],
        ),
      ),
    );
  }
}

// Виджет отдельной карточки альбома
class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      // 1. Требование: Row - вся карточка
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: album.coverColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    album.categoryIcon, // Иконка категории
                    color: Colors.white.withOpacity(0.8),
                    size: 48,
                  ),
                ),
              ),
              // Иконка лайка поверх обложки в правом верхнем углу
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    album.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: album.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          Expanded(
            // 4. Требование: Column - заголовок, исполнитель и теги сверху вниз
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название альбома с предотвращением переполнения (overflow)
                Text(
                  album.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Подпись: Исполнитель и год
                Text(
                  '${album.artist} · ${album.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Теги жанров
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: album.genres
                      .map(
                        (genre) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}