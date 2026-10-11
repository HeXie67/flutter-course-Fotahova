import 'package:flutter/material.dart';

enum AlbumCategory {
  rock,
  classic,
  pop,
  other,
}

class Album {
  final int id;
  final String title;
  final String subtitle;
  final AlbumCategory category;
  final String? description;
  final Color coverColor;
  final IconData categoryIcon;
  final List<String> genres;

  const Album({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    required this.coverColor,
    required this.categoryIcon,
    required this.genres,
  });
}