import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/services/audio_player_service.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _audioPlayerService;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _sequenceSubscription;
  StreamSubscription? _shuffleSubscription;
  StreamSubscription? _loopModeSubscription;

  PlayerBloc({
    required AudioPlayerService audioPlayerService,
  })  : _audioPlayerService = audioPlayerService,
        super(PlayerInitial()) {
    on<PlaySingleSong>(_onPlaySingleSong);
    on<PlayFromQueue>(_onPlayFromQueue);
    on<ResumePlayback>(_onResumePlayback);
    on<PausePlayback>(_onPausePlayback);
    on<StopPlayback>(_onStopPlayback);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekToPosition>(_onSeekToPosition);
    on<SeekToIndex>(_onSeekToIndex);
    on<ToggleShuffle>(_onToggleShuffle);
    on<SetShuffle>(_onSetShuffle);
    on<CycleRepeatMode>(_onCycleRepeatMode);
    on<SetRepeatMode>(_onSetRepeatMode);
    on<SetVolume>(_onSetVolume);
    on<UpdatePlayerPosition>(_onUpdatePlayerPosition);
    on<AddSongToQueue>(_onAddSongToQueue);
    on<AddSongsToQueue>(_onAddSongsToQueue);
    on<RemoveSongFromQueue>(_onRemoveSongFromQueue);
    on<ClearQueue>(_onClearQueue);
    on<UpdateShuffleMode>(_onUpdateShuffleMode);
    on<UpdateRepeatMode>(_onUpdateRepeatMode);

    _initStreams();
  }

  void _initStreams() {
    _positionSubscription = _audioPlayerService.positionStream.listen((position) {
      if (state is PlayerReady) {
        add(UpdatePlayerPosition(
          position: position,
          duration: _audioPlayerService.duration ?? Duration.zero,
          currentIndex: _audioPlayerService.currentIndex,
        ));
      }
    });

    _playerStateSubscription = _audioPlayerService.playerStateStream.listen((playerState) {
      if (state is PlayerReady) {
        final stateType = _mapToStateType(playerState);
        add(UpdatePlayerPosition(
          position: _audioPlayerService.position,
          duration: _audioPlayerService.duration ?? Duration.zero,
          currentIndex: _audioPlayerService.currentIndex,
          state: stateType,
        ));
      }
    });

    _sequenceSubscription = _audioPlayerService.sequenceStateStream.listen((sequence) {
      if (state is PlayerReady && sequence != null) {
        add(UpdatePlayerPosition(
          position: _audioPlayerService.position,
          duration: _audioPlayerService.duration ?? Duration.zero,
          currentIndex: sequence.currentIndex,
        ));
      }
    });

    _shuffleSubscription = _audioPlayerService.shuffleModeEnabledStream.listen((enabled) {
      if (state is PlayerReady) {
        add(UpdateShuffleMode(enabled));
      }
    });

    _loopModeSubscription = _audioPlayerService.loopModeStream.listen((loopMode) {
      if (state is PlayerReady) {
        final repeatMode = _mapToRepeatModeState(_audioPlayerService.currentRepeatModeService);
        add(UpdateRepeatMode(repeatMode));
      }
    });
  }

  Future<void> _onPlaySingleSong(PlaySingleSong event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());
    try {
      await _audioPlayerService.playSingleSong(event.song);
      emit(PlayerReady(
        currentSong: event.song,
        queue: [event.song],
        currentIndex: 0,
        state: PlayerStateType.playing,
        isShuffled: _audioPlayerService.shuffleModeEnabled,
        repeatMode: _mapToRepeatModeState(_audioPlayerService.currentRepeatModeService),
        volume: _audioPlayerService.volume,
      ));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  Future<void> _onPlayFromQueue(PlayFromQueue event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());
    try {
      await _audioPlayerService.playFromQueue(
        songs: event.songs,
        initialIndex: event.initialIndex,
      );
      final initialSong = event.songs.isNotEmpty ? event.songs[event.initialIndex] : null;
      emit(PlayerReady(
        currentSong: initialSong,
        queue: event.songs,
        currentIndex: event.initialIndex,
        state: PlayerStateType.playing,
        isShuffled: _audioPlayerService.shuffleModeEnabled,
        repeatMode: _mapToRepeatModeState(_audioPlayerService.currentRepeatModeService),
        volume: _audioPlayerService.volume,
      ));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  Future<void> _onResumePlayback(ResumePlayback event, Emitter<PlayerState> emit) async {
    if (state is PlayerReady) {
      await _audioPlayerService.play();
    }
  }

  Future<void> _onPausePlayback(PausePlayback event, Emitter<PlayerState> emit) async {
    if (state is PlayerReady) {
      await _audioPlayerService.pause();
    }
  }

  Future<void> _onStopPlayback(StopPlayback event, Emitter<PlayerState> emit) async {
    if (state is PlayerReady) {
      await _audioPlayerService.stop();
      emit((state as PlayerReady).copyWith(
        state: PlayerStateType.stopped,
        position: Duration.zero,
      ));
    }
  }

  Future<void> _onNextSong(NextSong event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.next();
  }

  Future<void> _onPreviousSong(PreviousSong event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.previous(allowJumpToStart: event.jumpToStartIfPastThreshold);
  }

  Future<void> _onSeekToPosition(SeekToPosition event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.seek(event.position);
  }

  Future<void> _onSeekToIndex(SeekToIndex event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.seekToIndex(event.index, position: event.position ?? Duration.zero);
  }

  Future<void> _onToggleShuffle(ToggleShuffle event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.toggleShuffle();
  }

  Future<void> _onSetShuffle(SetShuffle event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.setShuffle(event.enabled);
  }

  Future<void> _onCycleRepeatMode(CycleRepeatMode event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.cycleRepeatMode();
  }

  Future<void> _onSetRepeatMode(SetRepeatMode event, Emitter<PlayerState> emit) async {
    final serviceMode = _mapToServiceRepeatMode(event.mode);
    await _audioPlayerService.setRepeatMode(serviceMode);
  }

  Future<void> _onSetVolume(SetVolume event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.setVolume(event.volume);
    if (state is PlayerReady) {
      emit((state as PlayerReady).copyWith(volume: event.volume));
    }
  }

  void _onUpdatePlayerPosition(UpdatePlayerPosition event, Emitter<PlayerState> emit) {
    if (state is PlayerReady) {
      final currentState = state as PlayerReady;
      final currentSong = event.currentIndex != null &&
              event.currentIndex! >= 0 &&
              event.currentIndex! < currentState.queue.length
          ? currentState.queue[event.currentIndex!]
          : currentState.currentSong;

      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
        currentIndex: event.currentIndex ?? currentState.currentIndex,
        currentSong: currentSong,
        state: event.state ?? currentState.state,
      ));
    }
  }

  Future<void> _onAddSongToQueue(AddSongToQueue event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.addToQueue(event.song);
    if (state is PlayerReady) {
      final currentState = state as PlayerReady;
      final newQueue = List<Song>.from(currentState.queue)..add(event.song);
      emit(currentState.copyWith(queue: newQueue));
    }
  }

  Future<void> _onAddSongsToQueue(AddSongsToQueue event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.addAllToQueue(event.songs);
    if (state is PlayerReady) {
      final currentState = state as PlayerReady;
      final newQueue = List<Song>.from(currentState.queue)..addAll(event.songs);
      emit(currentState.copyWith(queue: newQueue));
    }
  }

  Future<void> _onRemoveSongFromQueue(RemoveSongFromQueue event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.removeFromQueue(event.index);
    if (state is PlayerReady) {
      final currentState = state as PlayerReady;
      if (event.index >= 0 && event.index < currentState.queue.length) {
        final newQueue = List<Song>.from(currentState.queue)..removeAt(event.index);
        emit(currentState.copyWith(queue: newQueue));
      }
    }
  }

  Future<void> _onClearQueue(ClearQueue event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.clearQueue();
    emit(PlayerReady(
      currentSong: null,
      queue: [],
      currentIndex: 0,
      state: PlayerStateType.idle,
    ));
  }

  void _onUpdateShuffleMode(UpdateShuffleMode event, Emitter<PlayerState> emit) {
    if (state is PlayerReady) {
      emit((state as PlayerReady).copyWith(isShuffled: event.enabled));
    }
  }

  void _onUpdateRepeatMode(UpdateRepeatMode event, Emitter<PlayerState> emit) {
    if (state is PlayerReady) {
      emit((state as PlayerReady).copyWith(repeatMode: event.mode));
    }
  }

  PlayerStateType _mapToStateType(ja.PlayerState? playerState) {
    if (playerState == null) return PlayerStateType.idle;
    if (playerState.processingState == ja.ProcessingState.loading ||
        playerState.processingState == ja.ProcessingState.buffering) {
      return PlayerStateType.loading;
    }
    if (playerState.processingState == ja.ProcessingState.completed) {
      return PlayerStateType.completed;
    }
    if (playerState.playing) {
      return PlayerStateType.playing;
    }
    return PlayerStateType.paused;
  }

  RepeatModeState _mapToRepeatModeState(RepeatModeService mode) {
    switch (mode) {
      case RepeatModeService.off:
        return RepeatModeState.off;
      case RepeatModeService.one:
        return RepeatModeState.one;
      case RepeatModeService.all:
        return RepeatModeState.all;
    }
  }

  RepeatModeService _mapToServiceRepeatMode(RepeatModeState mode) {
    switch (mode) {
      case RepeatModeState.off:
        return RepeatModeService.off;
      case RepeatModeState.one:
        return RepeatModeService.one;
      case RepeatModeState.all:
        return RepeatModeService.all;
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _sequenceSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopModeSubscription?.cancel();
    return super.close();
  }
}
