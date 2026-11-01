import '../../domain/entities/album.dart';

sealed class AlbumsState {}

class AlbumsLoadInProgress extends AlbumsState {}

class AlbumsLoadSuccess extends AlbumsState {
  final List<Album> albums;
  AlbumsLoadSuccess(this.albums);
}

class AlbumsLoadFailure extends AlbumsState {
  final String message;
  AlbumsLoadFailure(this.message);
}