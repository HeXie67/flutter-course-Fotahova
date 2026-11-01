import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/album.dart';
import '../bloc/albums_bloc.dart';
import '../bloc/albums_event.dart';
import '../bloc/albums_state.dart';
import '../widgets/add_album_sheet.dart';
import '../widgets/album_card.dart';
import 'album_details_screen.dart';

class MusicCatalogScreen extends StatelessWidget {
  const MusicCatalogScreen({super.key});

  void _openAddSheet(BuildContext context) {
    // Bottom sheet живёт вне BlocProvider, поэтому берём Bloc заранее
    final bloc = context.read<AlbumsBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddAlbumSheet(
        onSubmit: (album) => bloc.add(AlbumAdded(album)),
      ),
    );
  }

  void _openDetails(BuildContext context, Album album) {
    // Новый экран тоже вне BlocProvider: передаём тот же Bloc через .value,
    // иначе лайки в списке и в деталях разошлись бы
    final bloc = context.read<AlbumsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AlbumDetailsScreen(albumId: album.id),
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
            tooltip: 'Добавить альбом',
            icon: const Icon(Icons.add),
            onPressed: () => _openAddSheet(context),
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<AlbumsBloc, AlbumsState>(
          // SnackBar только когда пришло новое сообщение
          listenWhen: (previous, current) =>
              current is AlbumsLoadSuccess && current.message != null,
          listener: (context, state) {
            final message = (state as AlbumsLoadSuccess).message!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            return switch (state) {
              AlbumsLoadInProgress() =>
                const Center(child: CircularProgressIndicator()),
              AlbumsLoadFailure(:final message) => _ErrorView(message: message),
              AlbumsLoadSuccess() => _Content(
                  state: state,
                  onAlbumTap: (album) => _openDetails(context, album),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onAlbumTap});

  final AlbumsLoadSuccess state;
  final void Function(Album album) onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final albums = state.visibleAlbums;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _Header(state: state),
          Expanded(
            child: albums.isEmpty
                ? _EmptyView(text: _emptyText(state))
                : ListView.builder(
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () => onAlbumTap(album),
                        child: AlbumCard(
                          album: album,
                          isLiked: state.likedIds.contains(album.id),
                          onLikeTap: () => context
                              .read<AlbumsBloc>()
                              .add(AlbumLikeToggled(album.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _emptyText(AlbumsLoadSuccess s) {
    if (s.query.trim().isNotEmpty) return 'Ничего не найдено';
    if (s.onlyFavorites) return 'В избранном пока пусто';
    return 'Каталог пока пуст';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AlbumsLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final onlyFavorites = state.onlyFavorites;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              const Expanded(
                child: Text(
                  'Каталог альбомов',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<AlbumsBloc>().add(FavoritesFilterToggled()),
                icon: Icon(
                  onlyFavorites ? Icons.filter_alt : Icons.filter_alt_outlined,
                  size: 18,
                  color: onlyFavorites ? Colors.white : Colors.black,
                ),
                label: Text(
                  onlyFavorites ? 'Все' : 'Избранные',
                  style: TextStyle(
                    color: onlyFavorites ? Colors.white : Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      onlyFavorites ? Colors.redAccent : Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Поиск по названию во время ввода, без учёта регистра
          TextField(
            onChanged: (value) =>
                context.read<AlbumsBloc>().add(SearchChanged(value)),
            decoration: const InputDecoration(
              hintText: 'Поиск по названию',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Всего: ${state.albums.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'В избранном: ${state.favoritesCount}',
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
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<AlbumsBloc>().add(AlbumsLoadRequested()),
              child: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}