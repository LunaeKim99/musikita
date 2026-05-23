import 'package:equatable/equatable.dart';
import 'song.dart';

class RecentPlayed extends Equatable {
  final int? id;
  final int songId;
  final DateTime playedAt;
  final Song? song;

  const RecentPlayed({
    this.id,
    required this.songId,
    required this.playedAt,
    this.song,
  });

  RecentPlayed copyWith({
    int? id,
    int? songId,
    DateTime? playedAt,
    Song? song,
  }) {
    return RecentPlayed(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      playedAt: playedAt ?? this.playedAt,
      song: song ?? this.song,
    );
  }

  @override
  List<Object?> get props => [id, songId, playedAt, song];
}
