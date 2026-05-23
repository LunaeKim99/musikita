import 'package:flutter/material.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;
  final bool showSongCount;
  final bool isParent;

  const FolderTile({
    super.key,
    required this.folder,
    this.onTap,
    this.showSongCount = true,
    this.isParent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isParent
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isParent ? Icons.arrow_upward : Icons.folder,
          size: 24,
          color: isParent
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(
        folder.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: showSongCount
          ? Text(
              _getSubtitle(),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: !isParent ? const Icon(Icons.chevron_right) : null,
    );
  }

  String _getSubtitle() {
    final count = folder.songCount;
    final subfolders = folder.subfolders?.length ?? 0;

    final parts = <String>[];
    if (subfolders > 0) {
      parts.add(subfolders == 1 ? '1 folder' : '$subfolders folders');
    }
    if (count > 0) {
      parts.add(count == 1 ? '1 song' : '$count songs');
    }

    return parts.isEmpty ? 'Empty' : parts.join(', ');
  }
}
