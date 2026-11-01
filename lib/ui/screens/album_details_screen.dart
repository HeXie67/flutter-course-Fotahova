import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/albums_bloc.dart';
import '../bloc/albums_event.dart';
import '../bloc/albums_state.dart';
import '../widgets/album_category_ui.dart';
import '../widgets/like_button.dart';

class AlbumDetailsScreen extends StatelessWidget {
  const AlbumDetailsScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumsBloc, AlbumsState>(
      builder: (context, state) {
        if (state is! AlbumsLoadSuccess) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final album = state.albums.where((a) => a.id == albumId).firstOrNull;
        if (album == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Альбом не найден')),
          );
        }
        final isLiked = state.likedIds.contains(album.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(album.title),
            backgroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Hero(
                  tag: 'cover-${album.id}',
                  child: Container(
                    width: 200,
                    height: 240,
                    decoration: BoxDecoration(
                      color: colorFromHex(album.coverColor),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      album.category.icon,
                      color: Colors.white.withAlpha(204),
                      size: 96,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            album.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        LikeButton(
                          isLiked: isLiked,
                          size: 30,
                          onTap: () => context
                              .read<AlbumsBloc>()
                              .add(AlbumLikeToggled(album.id)),
                        ),
                      ],
                    ),
                    if (album.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        album.subtitle,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Chip(
                      avatar: Icon(album.category.icon, size: 18),
                      label: Text(album.category.label),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      album.description ?? 'Описания пока нет',
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (album.genres.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: album.genres
                            .map((g) => Chip(label: Text(g)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}