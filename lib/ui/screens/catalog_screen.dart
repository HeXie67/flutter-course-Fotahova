import 'package:flutter/material.dart';
import '../../domain/entities/album.dart';
import '../widgets/album_card.dart';

class MusicCatalogScreen extends StatefulWidget {
  const MusicCatalogScreen({super.key});

  @override
  State<MusicCatalogScreen> createState() => _MusicCatalogScreenState();
}

class _MusicCatalogScreenState extends State<MusicCatalogScreen> {
  // Хранилище лайков по id элементов
  final Set<int> _likedIds = {1, 3, 5, 8};
  bool _onlyFavorites = false;

  // Список из 8+ элементов объявлен константой вне build
  static const List<Album> _albums = [
    Album(
      id: 1,
      title: 'The Dark Side of the Moon',
      subtitle: 'Pink Floyd · 1973',
      category: AlbumCategory.rock,
      description: 'Легендарный прог-рок альбом',
      coverColor: Color(0xFF2D3250),
      categoryIcon: Icons.album,
      genres: ['Прог-рок', 'Рок'],
    ),
    Album(
      id: 2,
      title: 'Worldenddominator',
      subtitle: 'zts · 2009',
      category: AlbumCategory.rock,
      coverColor: Color(0xFF2C5E3B),
      categoryIcon: Icons.music_note,
      genres: ['Рок', 'Поп'],
    ),
    Album(
      id: 3,
      title: 'Claire De Lune',
      subtitle: 'Клод Дебюсси · 1890',
      category: AlbumCategory.classic,
      description: 'Шедевр классической музыки',
      coverColor: Color(0xFF8B4513),
      categoryIcon: Icons.graphic_eq,
      genres: ['Классика'],
    ),
    Album(
      id: 4,
      title: 'Колыбельная',
      subtitle: 'Петр Ильич Чайковский · 1893',
      category: AlbumCategory.classic,
      coverColor: Color(0xFF800020),
      categoryIcon: Icons.music_note,
      genres: ['Классика'],
    ),
    Album(
      id: 5,
      title: 'Nevermind',
      subtitle: 'Nirvana · 1991',
      category: AlbumCategory.rock,
      coverColor: Color(0xFF1E3A8A),
      categoryIcon: Icons.album,
      genres: ['Гранж', 'Альт-рок'],
    ),
    Album(
      id: 6,
      title: 'Still with you',
      subtitle: 'JungKook · 2020',
      category: AlbumCategory.pop,
      coverColor: Color(0xFF374151),
      categoryIcon: Icons.music_note,
      genres: ['K-поп'],
    ),
    Album(
      id: 7,
      title: 'A Night at the Opera',
      subtitle: 'Queen · 1975',
      category: AlbumCategory.rock,
      coverColor: Color(0xFF7C3AED),
      categoryIcon: Icons.album,
      genres: ['Рок', 'Оперный рок'],
    ),
    Album(
      id: 8,
      title: 'Last Twilight',
      subtitle: 'William Jakrapart · 2024',
      category: AlbumCategory.pop,
      coverColor: Color(0xFF0F766E),
      categoryIcon: Icons.graphic_eq,
      genres: ['T-поп'],
    ),
  ];

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Динамическая фильтрация списка через .where()
    final displayedAlbums = _onlyFavorites
        ? _albums.where((album) => _likedIds.contains(album.id)).toList()
        : _albums;

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
            // Шапка с заголовком, счётчиком и кнопкой фильтра
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Каталог альбомов',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _onlyFavorites = !_onlyFavorites;
                          });
                        },
                        icon: Icon(
                          _onlyFavorites ? Icons.filter_alt : Icons.filter_alt_outlined,
                          size: 18,
                          color: _onlyFavorites ? Colors.white : Colors.black,
                        ),
                        label: Text(
                          _onlyFavorites ? 'Все' : 'Избранные',
                          style: TextStyle(
                            color: _onlyFavorites ? Colors.white : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _onlyFavorites ? Colors.redAccent : Colors.grey[200],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Всего: ${_albums.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      // Счётчик избранного в шапке
                      Text(
                        'В избранном: ${_likedIds.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // Вывод списка карточек или заглушки при пустом результате
            if (displayedAlbums.isEmpty)
              Container(
                padding: const EdgeInsets.all(32.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ничего не нашлось',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...displayedAlbums.map(
                (album) => AlbumCard(
                  album: album,
                  isLiked: _likedIds.contains(album.id),
                  onLikeTap: () => _toggleLike(album.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}