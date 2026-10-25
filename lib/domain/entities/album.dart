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
  final String coverColor; // HEX-строка, например "#2D3250"
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

  // JSON с сервера -> Album
  factory Album.fromJson(Map<String, dynamic> json) {
    final desc = json['description'] as String?;

    return Album(
      // MockAPI отдаёт id строкой ("1"), поэтому приводим к int
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      // имя категории из JSON -> элемент enum (если не нашли, то other)
      category: AlbumCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AlbumCategory.other,
      ),
      // пустая строка означает "описания нет"
      description: (desc == null || desc.isEmpty) ? null : desc,
      coverColor: json['coverColor'] as String? ?? '#9E9E9E',
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  // Album -> JSON для POST. Поля id здесь нет: его выдаёт сервер
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