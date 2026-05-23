import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/utils/extensions.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_event.dart' as fav_ev;
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart' as player_ev;
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/playlist_bloc/playlist_event.dart' as pl_ev;

class SongTile extends StatelessWidget {
  final Song song;
  final int index;
  final List<Song>? queueContext;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTrailing;
  final bool showFavorite;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    this.queueContext,
    this.onTap,
    this.onLongPress,
    this.showTrailing = true,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? () => _playSong(context),
      onLongPress: onLongPress ?? () => _showSongMenu(context),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailing(context),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final playerState = context.watch<PlayerBloc>().state;
    final isCurrentlyPlaying =
        playerState is PlayerReady && playerState.currentSong?.id == song.id;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 24,
            color: isCurrentlyPlaying
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          if (isCurrentlyPlaying)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 8,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final playerState = context.watch<PlayerBloc>().state;
    final isCurrentlyPlaying =
        playerState is PlayerReady && playerState.currentSong?.id == song.id;

    return Text(
      song.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSubtitle() {
    final durationText = Duration(milliseconds: song.duration).formatMmSs();
    return Text(
      '${song.artist} • $durationText',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (!showTrailing) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFavorite)
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              bool isFavorite = false;
              if (state is FavoritesLoaded && song.id != null) {
                isFavorite = state.isFavorite(song.id!);
              }

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Theme.of(context).colorScheme.primary : null,
                  size: 20,
                ),
                onPressed: () {
                  if (song.id != null) {
                    context.read<FavoriteBloc>().add(fav_ev.ToggleFavorite(song.id!));
                  }
                },
                splashRadius: 18,
              );
            },
          ),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () => _showSongMenu(context),
          splashRadius: 18,
        ),
      ],
    );
  }

  void _playSong(BuildContext context) {
    if (queueContext != null) {
      final startIndex = queueContext!.indexOf(song);
      if (startIndex != -1) {
        context.read<PlayerBloc>().add(player_ev.PlayFromQueue(
              songs: queueContext!,
              initialIndex: startIndex,
            ));
      } else {
        context.read<PlayerBloc>().add(player_ev.PlaySingleSong(song));
      }
    } else {
      context.read<PlayerBloc>().add(player_ev.PlaySingleSong(song));
    }
  }

  void _showSongMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Play Now'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _playSong(context);
                },
              ),
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (favContext, state) {
                  bool isFavorite = false;
                  if (state is FavoritesLoaded && song.id != null) {
                    isFavorite = state.isFavorite(song.id!);
                  }
                  return ListTile(
                    leading: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      if (song.id != null) {
                        context.read<FavoriteBloc>().add(fav_ev.ToggleFavorite(song.id!));
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<PlaylistBloc>().add(pl_ev.ShowAddToPlaylistDialog(song));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Metadata'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(
                    context,
                    '/edit-metadata',
                    arguments: song,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.album),
                title: const Text('Change Cover Art'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(
                    context,
                    '/edit-cover',
                    arguments: song,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Song Info'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showSongInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(song.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Artist', song.artist),
              _infoRow('Album', song.album),
              _infoRow('Duration', Duration(milliseconds: song.duration).formatMmSs()),
              _infoRow('File Path', song.filePath),
              if (song.dateAdded != null)
                _infoRow('Date Added', song.dateAdded!.formatDate()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
