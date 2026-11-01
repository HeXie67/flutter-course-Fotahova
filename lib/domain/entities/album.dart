import 'package:cloud_firestore/cloud_firestore.dart';

enum AlbumCategory { rock, classic, pop, other }

class Album {
  final String id;
  final String title;
  final String subtitle;
  final AlbumCategory category;
  final String? description;
  final String coverColor;
  final List<String> genres;

  const Album({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    required this.coverColor,
    required this.genres,
  });

  factory Album.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final desc = data['description'] as String?;
    return Album(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      category: AlbumCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => AlbumCategory.other,
      ),
      description: (desc == null || desc.isEmpty) ? null : desc,
      coverColor: data['coverColor'] as String? ?? '#9E9E9E',
      genres: (data['genres'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'description': description ?? '',
      'coverColor': coverColor,
      'genres': genres,
    };
  }
}