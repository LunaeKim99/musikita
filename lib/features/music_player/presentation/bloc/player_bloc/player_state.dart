import 'package:equatable/equatable.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'player_event.dart';

sealed class MusicPlayerState extends Equatable {
  const MusicPlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends MusicPlayerState {}

class PlayerLoading extends MusicPlayerState {}

class PlayerReady extends MusicPlayerState {
  final Song? currentSong;
  final List<Song> queue;
  final Duration position;
  final Duration duration;
  final int currentIndex;
  final PlayerStateType state;
  final bool isShuffled;
  final RepeatModeState repeatMode;
  final double volume;
  final bool hasError;
  final String? errorMessage;

  const PlayerReady({
    this.currentSong,
    this.queue = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = 0,
    this.state = PlayerStateType.idle,
    this.isShuffled = false,
    this.repeatMode = RepeatModeState.off,
    this.volume = 1.0,
    this.hasError = false,
    this.errorMessage,
  });

  PlayerReady copyWith({
    Song? currentSong,
    List<Song>? queue,
    Duration? position,
    Duration? duration,
    int? currentIndex,
    PlayerStateType? state,
    bool? isShuffled,
    RepeatModeState? repeatMode,
    double? volume,
    bool? hasError,
    String? errorMessage,
  }) {
    return PlayerReady(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
      state: state ?? this.state,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentSong,
        queue,
        position,
        duration,
        currentIndex,
        state,
        isShuffled,
        repeatMode,
        volume,
        hasError,
        errorMessage,
      ];

  bool get isPlaying => state == PlayerStateType.playing;
  bool get isPaused => state == PlayerStateType.paused;
  bool get isCompleted => state == PlayerStateType.completed;
  bool get isStopped => state == PlayerStateType.stopped;
  bool get isIdle => state == PlayerStateType.idle;
  bool get isLoadingState => state == PlayerStateType.loading;

  double get progressPercent {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  bool get hasCurrentSong => currentSong != null;
  bool get hasQueue => queue.isNotEmpty;
  int get queueLength => queue.length;
}

class PlayerError extends MusicPlayerState {
  final String message;

  const PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
