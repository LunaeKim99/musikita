import 'package:equatable/equatable.dart';
import 'song.dart';

class Folder extends Equatable {
  final String path;
  final String name;
  final int songCount;
  final List<Song>? songs;
  final List<Folder>? subfolders;
  final String? parentPath;

  const Folder({
    required this.path,
    required this.name,
    this.songCount = 0,
    this.songs,
    this.subfolders,
    this.parentPath,
  });

  Folder copyWith({
    String? path,
    String? name,
    int? songCount,
    List<Song>? songs,
    List<Folder>? subfolders,
    String? parentPath,
  }) {
    return Folder(
      path: path ?? this.path,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      songs: songs ?? this.songs,
      subfolders: subfolders ?? this.subfolders,
      parentPath: parentPath ?? this.parentPath,
    );
  }

  @override
  List<Object?> get props => [path, name, songCount, songs, subfolders, parentPath];
}
