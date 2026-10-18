import 'package:flutter/material.dart';

import '../../domain/entities/album.dart';

extension AlbumCategoryUi on AlbumCategory {
  // Иконка всегда соответствует категории
  IconData get icon {
    switch (this) {
      case AlbumCategory.rock:
        return Icons.album;
      case AlbumCategory.classic:
        return Icons.graphic_eq;
      case AlbumCategory.pop:
        return Icons.music_note;
      case AlbumCategory.other:
        return Icons.library_music;
    }
  }

  String get label {
    switch (this) {
      case AlbumCategory.rock:
        return 'Рок';
      case AlbumCategory.classic:
        return 'Классика';
      case AlbumCategory.pop:
        return 'Поп';
      case AlbumCategory.other:
        return 'Другое';
    }
  }

  // Цвет обложки по умолчанию для новых альбомов (HEX-строка для сервера)
  String get defaultCoverHex {
    switch (this) {
      case AlbumCategory.rock:
        return '#1E3A8A';
      case AlbumCategory.classic:
        return '#8B4513';
      case AlbumCategory.pop:
        return '#0F766E';
      case AlbumCategory.other:
        return '#374151';
    }
  }
}

// HEX-строка ("#2D3250" или "2D3250") -> Color. Нужна только виджетам
Color colorFromHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.tryParse('FF$clean', radix: 16);
  return Color(value ?? 0xFF9E9E9E);
}