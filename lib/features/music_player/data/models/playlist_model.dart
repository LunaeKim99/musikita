import 'package:musikita/features/music_player/domain/entities/playlist.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

class PlaylistModel extends Playlist {
  const PlaylistModel({
    super.id,
    required super.name,
    super.createdAt,
    super.songs,
    super.songCount = 0,
  });

  factory PlaylistModel.fromEntity(Playlist entity) {
    return PlaylistModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
      songs: entity.songs,
      songCount: entity.songCount,
    );
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      songCount: map['song_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId && id != null) 'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Playlist toEntity() {
    return Playlist(
      id: id,
      name: name,
      createdAt: createdAt,
      songs: songs,
      songCount: songCount,
    );
  }
}
