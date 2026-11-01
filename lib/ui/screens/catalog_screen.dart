import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/album.dart';
import '../widgets/album_card.dart';
import '../widgets/album_category_ui.dart';

class MusicCatalogScreen extends StatefulWidget {
  const MusicCatalogScreen({super.key});

  @override
  State<MusicCatalogScreen> createState() => _MusicCatalogScreenState();
}

class _MusicCatalogScreenState extends State<MusicCatalogScreen> {
  // Лайки хранятся локально по id документа
  final Set<String> _likedIds = {};
  bool _onlyFavorites = false;

  // Поток каталога из Firestore (поле State, не внутри build)
  final _albumsStream =
      FirebaseFirestore.instance.collection('albums').snapshots();

  // Форма добавления
  bool _showForm = true;
  bool _isSaving = false;
  String? _formError;
  AlbumCategory _selectedCategory = AlbumCategory.rock;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genresController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  // ---------- Добавление альбома в Firestore ----------
  Future<void> _createAlbum() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() => _formError = 'Введите название');
      return;
    }

    final subtitle = _subtitleController.text.trim();
    final description = _descriptionController.text.trim();
    final genres = _genresController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    final newAlbum = Album(
      id: '', // настоящий id выдаст Firestore, в toJson он не попадает
      title: title,
      subtitle: subtitle,
      category: _selectedCategory,
      description: description.isEmpty ? null : description,
      coverColor: _selectedCategory.defaultCoverHex,
      genres: genres,
    );

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('albums')
          .add(newAlbum.toJson());
      // В список вручную ничего не добавляем: StreamBuilder обновится сам

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _clearForm();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _formError = 'Не удалось отправить альбом: $e';
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _subtitleController.clear();
    _descriptionController.clear();
    _genresController.clear();
    _selectedCategory = AlbumCategory.rock;
    _formError = null;
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  // ---------- Шапка: заголовок, счётчики, фильтр ----------
  Widget _buildHeader(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  setState(() => _onlyFavorites = !_onlyFavorites);
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
                  backgroundColor:
                      _onlyFavorites ? Colors.redAccent : Colors.grey[200],
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
                'Всего: $total',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
    );
  }

  // ---------- Форма добавления ----------
  Widget _buildForm() {
    final media = MediaQuery.of(context);
    final maxHeight = (media.size.height - media.viewInsets.bottom) * 0.35;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _createAlbum,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Отправить'),
                  ),
                ],
              ),
              if (_formError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              ExpansionTile(
                title: const Text('Дополнительно'),
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  TextField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Исполнитель · год',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _genresController,
                    decoration: const InputDecoration(
                      labelText: 'Жанры через запятую',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: AlbumCategory.values
                          .map(
                            (category) => ChoiceChip(
                              label: Text(category.label),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Ничего не нашлось',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог альбомов'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _showForm ? 'Скрыть форму' : 'Показать форму',
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _albumsStream,
          builder: (context, snapshot) {
            // Ошибка: показываем текст ошибки
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Ошибка: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            // Загрузка
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final albums =
                snapshot.data!.docs.map(Album.fromFirestore).toList();
            final displayedAlbums = _onlyFavorites
                ? albums.where((a) => _likedIds.contains(a.id)).toList()
                : albums;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(albums.length),
                  if (_showForm) _buildForm(),
                  Expanded(
                    child: displayedAlbums.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            itemCount: displayedAlbums.length,
                            itemBuilder: (context, index) {
                              final album = displayedAlbums[index];
                              return AlbumCard(
                                album: album,
                                isLiked: _likedIds.contains(album.id),
                                onLikeTap: () => _toggleLike(album.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}