import 'package:flutter/material.dart';
import 'package:musikita/features/music_player/domain/entities/playlist.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.playlist_play,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        _getSubtitle(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing ?? Icon(Icons.chevron_right),
    );
  }

  String _getSubtitle() {
    final count = playlist.songCount;
    if (count == 0) return 'No songs';
    if (count == 1) return '1 song';
    return '$count songs';
  }
}
