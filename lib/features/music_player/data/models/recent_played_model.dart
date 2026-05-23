import 'package:musikita/features/music_player/domain/entities/recent_played.dart';

class RecentPlayedModel extends RecentPlayed {
  const RecentPlayedModel({
    super.id,
    required super.songId,
    required super.playedAt,
    super.song,
  });

  factory RecentPlayedModel.fromEntity(RecentPlayed entity) {
    return RecentPlayedModel(
      id: entity.id,
      songId: entity.songId,
      playedAt: entity.playedAt,
      song: entity.song,
    );
  }

  factory RecentPlayedModel.fromMap(Map<String, dynamic> map) {
    return RecentPlayedModel(
      id: map['id'] as int?,
      songId: map['song_id'] as int? ?? 0,
      playedAt: map['played_at'] != null
          ? DateTime.parse(map['played_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId && id != null) 'id': id,
      'song_id': songId,
      'played_at': playedAt.toIso8601String(),
    };
  }

  RecentPlayed toEntity() {
    return RecentPlayed(
      id: id,
      songId: songId,
      playedAt: playedAt,
      song: song,
    );
  }
}
