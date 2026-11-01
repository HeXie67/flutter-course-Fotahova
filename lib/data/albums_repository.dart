import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/album.dart';

class AlbumsRepository {
  AlbumsRepository({required this.uid, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _albums =>
      _db.collection('albums');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(uid);

  // Каталог в реальном времени
  Stream<List<Album>> watchAlbums() => _albums
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Album.fromFirestore).toList());

  // Избранное текущего пользователя в реальном времени
  Stream<Set<String>> watchLikedIds() => _userDoc.snapshots().map((doc) {
        final list = doc.data()?['likedIds'] as List<dynamic>? ?? [];
        return list.map((e) => e.toString()).toSet();
      });

  Future<void> addAlbum(Album album) => _albums.add(album.toJson());

  Future<void> setLiked(String albumId, bool liked) {
    return _userDoc.set({
      'likedIds': liked
          ? FieldValue.arrayUnion([albumId])
          : FieldValue.arrayRemove([albumId]),
    }, SetOptions(merge: true));
  }
}