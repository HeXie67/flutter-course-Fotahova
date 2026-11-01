import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/album.dart';
import 'albums_event.dart';
import 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc() : super(AlbumsLoadInProgress()) {
    on<AlbumsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    AlbumsLoadRequested event,
    Emitter<AlbumsState> emit,
  ) async {
    emit(AlbumsLoadInProgress());

    // Подписка на snapshots(): при любом изменении в Firestore
    // сюда приходит новый список, поэтому обновляется сам
    await emit.forEach<QuerySnapshot<Map<String, dynamic>>>(
      FirebaseFirestore.instance.collection('albums').snapshots(),
      onData: (snapshot) => AlbumsLoadSuccess(
        snapshot.docs.map(Album.fromFirestore).toList(),
      ),
      onError: (error, stackTrace) =>
          AlbumsLoadFailure('Не удалось загрузить каталог'),
    );
  }
}