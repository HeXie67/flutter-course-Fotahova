import '../../domain/entities/album.dart';

sealed class AlbumsState {}

class AlbumsLoadInProgress extends AlbumsState {}

class AlbumsLoadSuccess extends AlbumsState {
  final List<Album> albums;
  final Set<String> likedIds;
  final bool onlyFavorites;
  final String query;

  // Разовое сообщение для SnackBar (например, ошибка добавления)
  final String? message;

  AlbumsLoadSuccess({
    required this.albums,
    required this.likedIds,
    required this.onlyFavorites,
    required this.query,
    this.message,
  });

  // Список после фильтра "Только избранные" и поиска
  List<Album> get visibleAlbums {
    final q = query.trim().toLowerCase();
    return albums.where((a) {
      if (onlyFavorites && !likedIds.contains(a.id)) return false;
      if (q.isNotEmpty && !a.title.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  int get favoritesCount => albums.where((a) => likedIds.contains(a.id)).length;
}

class AlbumsLoadFailure extends AlbumsState {
  final String message;
  AlbumsLoadFailure(this.message);
}