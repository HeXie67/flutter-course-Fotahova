import 'package:flutter/material.dart';

import '../../domain/entities/album.dart';
import 'album_category_ui.dart';

class AddAlbumSheet extends StatefulWidget {
  const AddAlbumSheet({super.key, required this.onSubmit});

  final void Function(Album album) onSubmit;

  @override
  State<AddAlbumSheet> createState() => _AddAlbumSheetState();
}

class _AddAlbumSheetState extends State<AddAlbumSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genresController = TextEditingController();
  AlbumCategory _category = AlbumCategory.rock;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Введите название');
      return;
    }
    final description = _descriptionController.text.trim();
    final genres = _genresController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    widget.onSubmit(Album(
      id: '', // id выдаст Firestore
      title: title,
      subtitle: _subtitleController.text.trim(),
      category: _category,
      description: description.isEmpty ? null : description,
      coverColor: _category.defaultCoverHex,
      genres: genres,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // viewInsets.bottom поднимает форму над клавиатурой
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Новый альбом',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Название',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Исполнитель · год',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _genresController,
              decoration: const InputDecoration(
                labelText: 'Жанры через запятую',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: AlbumCategory.values
                  .map(
                    (c) => ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}