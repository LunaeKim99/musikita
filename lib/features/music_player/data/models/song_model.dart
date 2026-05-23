import 'package:musikita/features/music_player/domain/entities/song.dart';

class SongModel extends Song {
  const SongModel({
    super.id,
    required super.title,
    required super.artist,
    required super.album,
    required super.duration,
    required super.filePath,
    super.albumArtPath,
    super.artistImagePath,
    super.dateAdded,
    super.isHidden,
  });

  factory SongModel.fromEntity(Song entity) {
    return SongModel(
      id: entity.id,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      duration: entity.duration,
      filePath: entity.filePath,
      albumArtPath: entity.albumArtPath,
      artistImagePath: entity.artistImagePath,
      dateAdded: entity.dateAdded,
      isHidden: entity.isHidden,
    );
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      duration: map['duration'] as int? ?? 0,
      filePath: map['file_path'] as String? ?? '',
      albumArtPath: map['album_art_path'] as String?,
      artistImagePath: map['artist_image_path'] as String?,
      dateAdded: map['date_added'] != null
          ? DateTime.parse(map['date_added'] as String)
          : null,
      isHidden: map['is_hidden'] == 1,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId && id != null) 'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'file_path': filePath,
      'album_art_path': albumArtPath,
      'artist_image_path': artistImagePath,
      'date_added': dateAdded?.toIso8601String(),
      'is_hidden': isHidden ? 1 : 0,
    };
  }

  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      filePath: filePath,
      albumArtPath: albumArtPath,
      artistImagePath: artistImagePath,
      dateAdded: dateAdded,
      isHidden: isHidden,
    );
  }
}
