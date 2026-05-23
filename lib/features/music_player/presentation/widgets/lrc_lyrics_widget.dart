import 'package:flutter/material.dart';
import 'package:musikita/features/music_player/utils/lrc_parser.dart';

class LrcLyricsWidget extends StatefulWidget {
  final List<LyricLine> lyrics;
  final Duration currentPosition;
  final VoidCallback? onLyricTap;
  final Function(Duration)? onSeek;

  const LrcLyricsWidget({
    super.key,
    required this.lyrics,
    required this.currentPosition,
    this.onLyricTap,
    this.onSeek,
  });

  @override
  State<LrcLyricsWidget> createState() => _LrcLyricsWidgetState();
}

class _LrcLyricsWidgetState extends State<LrcLyricsWidget> {
  final ScrollController _scrollController = ScrollController();
  int? _currentIndex;

  @override
  void didUpdateWidget(covariant LrcLyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition) {
      _updateCurrentLine();
    }
  }

  void _updateCurrentLine() {
    final newIndex = LrcParser.findCurrentLyricIndex(
      widget.currentPosition,
      widget.lyrics,
    );

    if (newIndex != _currentIndex && newIndex != null) {
      setState(() => _currentIndex = newIndex);
      _scrollToCurrentLine(newIndex);
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!_scrollController.hasClients) return;

    final itemHeight = 48.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final centerOffset = index * itemHeight - (screenHeight / 2) + (itemHeight / 2);

    _scrollController.animateTo(
      centerOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No lyrics available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 100),
      itemCount: widget.lyrics.length,
      itemBuilder: (context, index) {
        final lyric = widget.lyrics[index];
        final isCurrentLine = index == _currentIndex;

        return GestureDetector(
          onTap: () {
            widget.onSeek?.call(lyric.time);
            widget.onLyricTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            child: Center(
              child: Text(
                lyric.text,
                textAlign: TextAlign.center,
                style: isCurrentLine
                    ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )
                     : Theme.of(context).textTheme.titleMedium?.copyWith(
                           color: Theme.of(context)
                               .colorScheme
                               .onSurfaceVariant
                               .withValues(alpha: 0.6),
                         ),
              ),
            ),
          ),
        );
      },
    );
  }
}
