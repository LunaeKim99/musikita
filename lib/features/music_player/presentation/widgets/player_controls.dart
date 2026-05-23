import 'package:flutter/material.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_enums.dart'; // ADDED: Import enum
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart';

class PlayerControls extends StatelessWidget {
  final MusicPlayerState state;
  final void Function(PlayerEvent) onEvent;

  const PlayerControls({
    super.key,
    required this.state,
    required this.onEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (state is PlayerReady) {
      final playerState = state as PlayerReady;
      final isPlaying = playerState.isPlaying;
      final hasQueue = playerState.hasQueue;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildShuffleButton(context, playerState.isShuffled),
          _buildPreviousButton(context, hasQueue),
          _buildPlayPauseButton(context, isPlaying),
          _buildNextButton(context, hasQueue),
          _buildRepeatButton(context, playerState.repeatMode),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildShuffleButton(BuildContext context, bool isShuffled) {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        color: isShuffled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24,
      ),
      onPressed: () => onEvent(const ToggleShuffle()),
    );
  }

  Widget _buildPreviousButton(BuildContext context, bool hasQueue) {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      iconSize: 36,
      onPressed: hasQueue ? () => onEvent(const PreviousSong()) : null,
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, bool isPlaying) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        iconSize: 32,
        onPressed: () {
          if (isPlaying) {
            onEvent(const PausePlayback());
          } else {
            onEvent(const ResumePlayback());
          }
        },
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, bool hasQueue) {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      iconSize: 36,
      onPressed: hasQueue ? () => onEvent(const NextSong()) : null,
    );
  }

  // CHANGED: Gunakan switch expression untuk inisialisasi yang aman
  Widget _buildRepeatButton(BuildContext context, RepeatModeState mode) {
    final (icon, color) = switch (mode) {
      RepeatModeState.off => (
          Icons.repeat,
          Theme.of(context).colorScheme.onSurfaceVariant
        ),
      RepeatModeState.all => (
          Icons.repeat,
          Theme.of(context).colorScheme.primary
        ),
      RepeatModeState.one => (
          Icons.repeat_one,
          Theme.of(context).colorScheme.primary
        ),
    };

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => onEvent(const CycleRepeatMode()),
    );
  }
}
