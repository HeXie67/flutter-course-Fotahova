import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/albums_repository.dart';
import '../../domain/entities/album.dart';
import 'albums_event.dart';
import 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc(this._repository) : super(AlbumsLoadInProgress()) {
    on<AlbumsLoadRequested>(_onLoadRequested);
    on<AlbumsDataChanged>((event, emit) {
      _albums = event.albums;
      _emitData(emit);
    });
    on<LikedIdsChanged>((event, emit) {
      _likedIds = event.ids;
      _emitData(emit);
    });
    on<AlbumsStreamFailed>((event, emit) {
      _albums = null;
      emit(AlbumsLoadFailure('Не удалось загрузить каталог'));
    });
    on<AlbumLikeToggled>(_onLikeToggled);
    on<FavoritesFilterToggled>((event, emit) {
      _onlyFavorites = !_onlyFavorites;
      _emitData(emit);
    });
    on<SearchChanged>((event, emit) {
      _query = event.query;
      _emitData(emit);
    });
    on<AlbumAdded>(_onAlbumAdded);
  }

  final AlbumsRepository _repository;

  List<Album>? _albums;
  Set<String> _likedIds = {};
  bool _onlyFavorites = false;
  String _query = '';

  StreamSubscription<List<Album>>? _albumsSub;
  StreamSubscription<Set<String>>? _likesSub;

  void _onLoadRequested(
    AlbumsLoadRequested event,
    Emitter<AlbumsState> emit,
  ) {
    emit(AlbumsLoadInProgress());
    _albumsSub?.cancel();
    _likesSub?.cancel();
    _albums = null;

    _albumsSub = _repository.watchAlbums().listen(
          (albums) => add(AlbumsDataChanged(albums)),
          onError: (_) => add(AlbumsStreamFailed()),
        );
    _likesSub = _repository.watchLikedIds().listen(
          (ids) => add(LikedIdsChanged(ids)),
          onError: (_) => add(AlbumsStreamFailed()),
        );
  }

  Future<void> _onLikeToggled(
    AlbumLikeToggled event,
    Emitter<AlbumsState> emit,
  ) async {
    final liked = !_likedIds.contains(event.id);
    // Сразу обновляем экран, потом сохраняем в Firestore
    _likedIds = liked
        ? {..._likedIds, event.id}
        : ({..._likedIds}..remove(event.id));
    _emitData(emit);

    try {
      await _repository.setLiked(event.id, liked);
    } catch (_) {
      _emitData(emit, message: 'Не удалось сохранить лайк');
    }
  }

  Future<void> _onAlbumAdded(
    AlbumAdded event,
    Emitter<AlbumsState> emit,
  ) async {
    try {
      // Новый документ придёт в список сам через snapshots()
      await _repository.addAlbum(event.album);
    } catch (_) {
      _emitData(emit, message: 'Не удалось добавить альбом');
    }
  }

  void _emitData(Emitter<AlbumsState> emit, {String? message}) {
    final albums = _albums;
    if (albums == null) return; // каталог ещё не пришёл
    emit(AlbumsLoadSuccess(
      albums: albums,
      likedIds: _likedIds,
      onlyFavorites: _onlyFavorites,
      query: _query,
      message: message,
    ));
  }

  @override
  Future<void> close() {
    _albumsSub?.cancel();
    _likesSub?.cancel();
    return super.close();
  }
}