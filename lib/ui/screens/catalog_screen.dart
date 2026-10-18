import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/album.dart';
import '../widgets/album_card.dart';
import '../widgets/album_category_ui.dart';

// Базовый адрес API и имя ресурса
const baseUrl = 'https://6ad4556c59dd78397bbc6c4f.mockapi.io';
const resource = 'music';

class MusicCatalogScreen extends StatefulWidget {
  const MusicCatalogScreen({super.key});

  @override
  State<MusicCatalogScreen> createState() => _MusicCatalogScreenState();
}

class _MusicCatalogScreenState extends State<MusicCatalogScreen> {
  // Лайки хранятся локально по id. Сначала пусто, счётчик начинается с 0
  final Set<int> _likedIds = {};
  bool _onlyFavorites = false;

  // Данные с сервера
  List<Album> _albums = [];
  bool _isLoading = true;
  String? _error;

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
  void initState() {
    super.initState();
    _loadAlbums(); // загрузка при открытии экрана
  }

  @override
  void dispose() {
    // Контроллеры обязательно освобождаем
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  // ---------- GET: загрузка каталога ----------
  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/$resource'));
      if (response.statusCode != 200) {
        throw Exception('Статус ${response.statusCode}');
      }
      // utf8.decode, чтобы русский текст не превращался в кракозябры
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final albums = list
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить каталог: $e';
        _isLoading = false;
      });
    }
  }

  // ---------- POST: добавление альбома ----------
  Future<void> _createAlbum() async {
    final title = _titleController.text.trim();

    // Обязательное поле одно: название. Пустое не отправляем
    if (title.isEmpty) {
      setState(() => _formError = 'Введите название');
      return;
    }

    // Необязательные поля: если пусто, значения по умолчанию
    final subtitle = _subtitleController.text.trim();
    final description = _descriptionController.text.trim();
    final genres = _genresController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    final newAlbum = Album(
      id: 0, // настоящий id выдаст сервер, в toJson он не попадает
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
      final response = await http.post(
        Uri.parse('$baseUrl/$resource'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newAlbum.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Статус ${response.statusCode}');
      }

      // Новый элемент берём из ответа сервера (в нём уже есть id)
      final created = Album.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );

      if (!mounted) return;
      setState(() {
        _albums = [created, ..._albums]; // в НАЧАЛО списка
        _isSaving = false;
        _clearForm();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _formError = 'Не удалось отправить альбом. Попробуйте ещё раз';
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

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  // ---------- Шапка: заголовок, счётчики, фильтр ----------
  Widget _buildHeader() {
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
                'Всего: ${_albums.length}',
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
    // Ограничиваем высоту формы, чтобы вместе с клавиатурой она не
    // выдавливала список и не вызывала overflow: внутри форма прокручивается
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
              // Обязательное поле + кнопка. TextField в Row, значит Expanded
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
              // Необязательные поля сворачиваются
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

  // ---------- Ошибка загрузки ----------
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAlbums,
              child: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Заглушка пустого списка ----------
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
    // Фильтрация списка через .where()
    final displayedAlbums = _onlyFavorites
        ? _albums.where((album) => _likedIds.contains(album.id)).toList()
        : _albums;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог альбомов'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Кнопка "+" / "×" показывает и скрывает форму
          IconButton(
            tooltip: _showForm ? 'Скрыть форму' : 'Показать форму',
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(),
                        if (_showForm) _buildForm(),
                        // Список занимает всё оставшееся место
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
                  ),
      ),
    );
  }
}