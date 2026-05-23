import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

class LoadRootFolders extends FolderEvent {
  const LoadRootFolders();
}

class NavigateToFolder extends FolderEvent {
  final Folder folder;

  const NavigateToFolder(this.folder);

  @override
  List<Object?> get props => [folder];
}

class NavigateUp extends FolderEvent {
  const NavigateUp();
}

class PlayFolder extends FolderEvent {
  final Folder folder;
  final int startIndex;

  const PlayFolder({
    required this.folder,
    this.startIndex = 0,
  });

  @override
  List<Object?> get props => [folder, startIndex];
}

class PlaySongFromFolder extends FolderEvent {
  final Song song;
  final List<Song> allSongs;

  const PlaySongFromFolder({
    required this.song,
    required this.allSongs,
  });

  @override
  List<Object?> get props => [song, allSongs];
}
