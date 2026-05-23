import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FoldersLoaded extends FolderState {
  final List<Folder> rootFolders;
  final List<Folder> navigationStack;

  const FoldersLoaded({
    required this.rootFolders,
    this.navigationStack = const [],
  });

  Folder get currentFolder {
    if (navigationStack.isNotEmpty) {
      return navigationStack.last;
    }
    return const Folder(
      path: '',
      name: 'Root',
    );
  }

  bool get canNavigateUp => navigationStack.isNotEmpty;

  List<Folder> get visibleFolders {
    if (navigationStack.isNotEmpty) {
      return navigationStack.last.subfolders ?? [];
    }
    return rootFolders;
  }

  List<Song> get currentSongs {
    if (navigationStack.isNotEmpty) {
      return navigationStack.last.songs ?? <Song>[];
    }
    return rootFolders.expand((f) => f.songs ?? <Song>[]).toList();
  }

  FoldersLoaded copyWith({
    List<Folder>? rootFolders,
    List<Folder>? navigationStack,
  }) {
    return FoldersLoaded(
      rootFolders: rootFolders ?? this.rootFolders,
      navigationStack: navigationStack ?? this.navigationStack,
    );
  }

  @override
  List<Object?> get props => [rootFolders, navigationStack];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object?> get props => [message];
}
