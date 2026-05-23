import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/utils/extensions.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_state.dart';
import 'seek_bar.dart';

class MiniPlayerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayerWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state is PlayerReady && state.hasCurrentSong) {
          return _buildMiniPlayer(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMiniPlayer(BuildContext context, PlayerReady state) {
    final song = state.currentSong!;
    final isPlaying = state.isPlaying;
    final progress = state.progressPercent;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
         boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.1),
             blurRadius: 8,
             offset: const Offset(0, -2),
           ),
         ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 2,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () => Navigator.pushNamed(context, '/now-playing'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.surfaceContainerHighest,
                         borderRadius: BorderRadius.circular(8),
                       ),
                      child: Icon(
                        Icons.music_note,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 24,
                          onPressed: () {
                            context.read<PlayerBloc>().add(const PreviousSong());
                          },
                        ),
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 32,
                          onPressed: () {
                            if (isPlaying) {
                              context.read<PlayerBloc>().add(const PausePlayback());
                            } else {
                              context.read<PlayerBloc>().add(const ResumePlayback());
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          iconSize: 24,
                          onPressed: () {
                            context.read<PlayerBloc>().add(const NextSong());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
