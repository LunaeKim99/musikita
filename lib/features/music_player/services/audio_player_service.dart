import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

enum RepeatModeService {
  off,
  one,
  all,
}

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _audioSource;
  List<Song> _currentQueue = [];
  int _currentIndex = 0;

  AudioPlayerService() {
    _init();
  }

  Future<void> _init() async {
    // TODO: Implement proper audio attributes for Android
    // The following code is commented out due to API changes in just_audio
    // await _audioPlayer.setAndroidAudioAttributes(
    //   const AndroidAudioAttributes(
    //     contentType: AndroidAudioContentType.music,
    //     usage: AndroidAudioUsage.media,
    //   ),
    // );
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _audioPlayer.sequenceStateStream;
  Stream<bool> get shuffleModeEnabledStream => _audioPlayer.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;
  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  PlayerState? get currentState => _audioPlayer.playerState;
  SequenceState? get sequence => _audioPlayer.sequenceState;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  bool get shuffleModeEnabled => _audioPlayer.shuffleModeEnabled;
  LoopMode get loopMode => _audioPlayer.loopMode;
  double get volume => _audioPlayer.volume;
  int? get currentIndex => _audioPlayer.currentIndex;
  List<Song> get currentQueue => List.unmodifiable(_currentQueue);
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _currentQueue.length
      ? _currentQueue[_currentIndex]
      : null;

  Future<void> playFromQueue({
    required List<Song> songs,
    int initialIndex = 0,
    Duration? initialPosition,
  }) async {
    if (songs.isEmpty) return;

    _currentQueue = List.from(songs);
    _currentIndex = initialIndex.clamp(0, songs.length - 1);

    final audioSources = songs.map((song) {
      return AudioSource.file(
        song.filePath,
        tag: _songToMediaItem(song),
      );
    }).toList();

    _audioSource = ConcatenatingAudioSource(children: audioSources);

    try {
      await _audioPlayer.setAudioSource(
        _audioSource!,
        initialIndex: _currentIndex,
        initialPosition: initialPosition,
      );
      await _audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playSingleSong(Song song) async {
    await playFromQueue(songs: [song], initialIndex: 0);
  }

  Future<void> playFromIndex(int index) async {
    if (index < 0 || index >= _currentQueue.length) return;
    _currentIndex = index;
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> seekToIndex(int index, {Duration position = Duration.zero}) async {
    if (index >= 0 && index < _currentQueue.length) {
      _currentIndex = index;
      await _audioPlayer.seek(position, index: index);
    }
  }

  Future<void> next() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> previous({bool allowJumpToStart = true}) async {
    if (_audioPlayer.position.inSeconds > 3 && allowJumpToStart) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> setShuffle(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> toggleShuffle() async {
    await _audioPlayer.setShuffleModeEnabled(!_audioPlayer.shuffleModeEnabled);
  }

  Future<void> setRepeatMode(RepeatModeService mode) async {
    final loopMode = _mapToLoopMode(mode);
    await _audioPlayer.setLoopMode(loopMode);
  }

  Future<void> cycleRepeatMode() async {
    final currentLoop = _audioPlayer.loopMode;
    final modes = [LoopMode.off, LoopMode.all, LoopMode.one];
    final currentIndex = modes.indexOf(currentLoop);
    final nextIndex = (currentIndex + 1) % modes.length;
    await _audioPlayer.setLoopMode(modes[nextIndex]);
  }

  RepeatModeService get currentRepeatModeService {
    return _mapFromLoopMode(_audioPlayer.loopMode);
  }

  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clampedVolume);
  }

  Future<void> addToQueue(Song song) async {
    if (_audioSource != null) {
      _currentQueue.add(song);
      final audioSource = AudioSource.file(
        song.filePath,
        tag: _songToMediaItem(song),
      );
      await _audioSource!.add(audioSource);
    } else {
      await playSingleSong(song);
    }
  }

  Future<void> addAllToQueue(List<Song> songs) async {
    if (_audioSource != null) {
      final audioSources = songs.map((song) {
        _currentQueue.add(song);
        return AudioSource.file(
          song.filePath,
          tag: _songToMediaItem(song),
        );
      }).toList();
      await _audioSource!.addAll(audioSources);
    } else if (songs.isNotEmpty) {
      await playFromQueue(songs: songs);
    }
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _currentQueue.length && _audioSource != null) {
      _currentQueue.removeAt(index);
      await _audioSource!.removeAt(index);
    }
  }

  Future<void> clearQueue() async {
    _currentQueue.clear();
    _currentIndex = 0;
    await _audioPlayer.stop();
    _audioSource = null;
  }

  Map<String, dynamic> _songToMediaItem(Song song) {
    return {
      'id': song.id?.toString() ?? song.filePath,
      'title': song.title,
      'artist': song.artist,
      'album': song.album,
      'duration': song.duration,
      'filePath': song.filePath,
      'albumArtPath': song.albumArtPath,
    };
  }

  LoopMode _mapToLoopMode(RepeatModeService mode) {
    switch (mode) {
      case RepeatModeService.off:
        return LoopMode.off;
      case RepeatModeService.one:
        return LoopMode.one;
      case RepeatModeService.all:
        return LoopMode.all;
    }
  }

  RepeatModeService _mapFromLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return RepeatModeService.off;
      case LoopMode.one:
        return RepeatModeService.one;
      case LoopMode.all:
        return RepeatModeService.all;
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
