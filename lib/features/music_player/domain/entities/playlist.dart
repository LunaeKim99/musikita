import 'package:equatable/equatable.dart';
import 'song.dart';

class Playlist extends Equatable {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final List<Song>? songs;
  final int songCount;

  const Playlist({
    this.id,
    required this.name,
    this.createdAt,
    this.songs,
    this.songCount = 0,
  });

  Playlist copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    List<Song>? songs,
    int? songCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
      songCount: songCount ?? this.songCount,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, songs, songCount];
}
