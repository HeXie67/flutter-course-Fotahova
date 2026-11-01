import '../../domain/entities/album.dart';

sealed class AlbumsEvent {}

// События от пользователя
class AlbumsLoadRequested extends AlbumsEvent {}

class AlbumLikeToggled extends AlbumsEvent {
  final String id;
  AlbumLikeToggled(this.id);
}

class FavoritesFilterToggled extends AlbumsEvent {}

class SearchChanged extends AlbumsEvent {
  final String query;
  SearchChanged(this.query);
}

class AlbumAdded extends AlbumsEvent {
  final Album album;
  AlbumAdded(this.album);
}

// Внутренние события: данные пришли из потоков репозитория
class AlbumsDataChanged extends AlbumsEvent {
  final List<Album> albums;
  AlbumsDataChanged(this.albums);
}

class LikedIdsChanged extends AlbumsEvent {
  final Set<String> ids;
  LikedIdsChanged(this.ids);
}

class AlbumsStreamFailed extends AlbumsEvent {}