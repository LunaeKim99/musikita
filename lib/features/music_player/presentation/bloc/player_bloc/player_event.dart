import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlaySingleSong extends PlayerEvent {
  final Song song;

  const PlaySingleSong(this.song);

  @override
  List<Object?> get props => [song];
}

class PlayFromQueue extends PlayerEvent {
  final List<Song> songs;
  final int initialIndex;

  const PlayFromQueue({
    required this.songs,
    this.initialIndex = 0,
  });

  @override
  List<Object?> get props => [songs, initialIndex];
}

class ResumePlayback extends PlayerEvent {
  const ResumePlayback();
}

class PausePlayback extends PlayerEvent {
  const PausePlayback();
}

class StopPlayback extends PlayerEvent {
  const StopPlayback();
}

class NextSong extends PlayerEvent {
  const NextSong();
}

class PreviousSong extends PlayerEvent {
  final bool jumpToStartIfPastThreshold;

  const PreviousSong({this.jumpToStartIfPastThreshold = true});

  @override
  List<Object?> get props => [jumpToStartIfPastThreshold];
}

class SeekToPosition extends PlayerEvent {
  final Duration position;

  const SeekToPosition(this.position);

  @override
  List<Object?> get props => [position];
}

class SeekToIndex extends PlayerEvent {
  final int index;
  final Duration? position;

  const SeekToIndex(this.index, {this.position});

  @override
  List<Object?> get props => [index, position];
}

class ToggleShuffle extends PlayerEvent {
  const ToggleShuffle();
}

class SetShuffle extends PlayerEvent {
  final bool enabled;

  const SetShuffle(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class CycleRepeatMode extends PlayerEvent {
  const CycleRepeatMode();
}

class SetRepeatMode extends PlayerEvent {
  final RepeatModeState mode;

  const SetRepeatMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetVolume extends PlayerEvent {
  final double volume;

  const SetVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class UpdatePlayerPosition extends PlayerEvent {
  final Duration position;
  final Duration duration;
  final int? currentIndex;
  final PlayerStateType? state;

  const UpdatePlayerPosition({
    required this.position,
    required this.duration,
    this.currentIndex,
    this.state,
  });

  @override
  List<Object?> get props => [position, duration, currentIndex, state];
}

class AddSongToQueue extends PlayerEvent {
  final Song song;

  const AddSongToQueue(this.song);

  @override
  List<Object?> get props => [song];
}

class AddSongsToQueue extends PlayerEvent {
  final List<Song> songs;

  const AddSongsToQueue(this.songs);

  @override
  List<Object?> get props => [songs];
}

class RemoveSongFromQueue extends PlayerEvent {
  final int index;

  const RemoveSongFromQueue(this.index);

  @override
  List<Object?> get props => [index];
}

class ClearQueue extends PlayerEvent {
  const ClearQueue();
}

class UpdateShuffleMode extends PlayerEvent {
  final bool enabled;

  const UpdateShuffleMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateRepeatMode extends PlayerEvent {
  final RepeatModeState mode;

  const UpdateRepeatMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

enum PlayerStateType {
  idle,
  loading,
  playing,
  paused,
  completed,
  stopped,
}

enum RepeatModeState {
  off,
  one,
  all,
}
