import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final int? id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String filePath;
  final String? albumArtPath;
  final String? artistImagePath;
  final DateTime? dateAdded;
  final bool isHidden;

  const Song({
    this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.albumArtPath,
    this.artistImagePath,
    this.dateAdded,
    this.isHidden = false,
  });

  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? filePath,
    String? albumArtPath,
    String? artistImagePath,
    DateTime? dateAdded,
    bool? isHidden,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      artistImagePath: artistImagePath ?? this.artistImagePath,
      dateAdded: dateAdded ?? this.dateAdded,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        duration,
        filePath,
        albumArtPath,
        artistImagePath,
        dateAdded,
        isHidden,
      ];
}
