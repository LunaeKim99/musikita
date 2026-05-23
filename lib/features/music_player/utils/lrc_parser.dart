import 'dart:io';
import 'package:musikita/core/constants/app_constants.dart';

class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});

  @override
  String toString() => '${time.inMilliseconds}: $text';
}

class LrcParser {
  static Future<List<LyricLine>> parseFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      return parseContent(content);
    } catch (_) {
      return [];
    }
  }

  static List<LyricLine> parseContent(String content) {
    final lines = <LyricLine>[];
    final rawLines = content.split('\n');

    final timePattern = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

    for (final line in rawLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final matches = timePattern.allMatches(trimmed);
      if (matches.isEmpty) continue;

      String text = '';
      final lastMatch = matches.last;
      if (lastMatch.end < trimmed.length) {
        text = trimmed.substring(lastMatch.end).trim();
      }

      for (final match in matches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisecondsStr = match.group(3)!;
        final milliseconds = millisecondsStr.length == 3
            ? int.parse(millisecondsStr)
            : (int.parse(millisecondsStr) * 10);

        final time = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        if (text.isNotEmpty) {
          lines.add(LyricLine(time: time, text: text));
        }
      }
    }

    lines.sort((a, b) => a.time.compareTo(b.time));

    return lines;
  }

  static LyricLine? findCurrentLyric(
    Duration currentPosition,
    List<LyricLine> lyrics,
  ) {
    if (lyrics.isEmpty) return null;

    LyricLine? current;
    for (final lyric in lyrics) {
      if (lyric.time <= currentPosition) {
        current = lyric;
      } else {
        break;
      }
    }
    return current;
  }

  static int? findCurrentLyricIndex(
    Duration currentPosition,
    List<LyricLine> lyrics,
  ) {
    if (lyrics.isEmpty) return null;

    int index = -1;
    for (int i = 0; i < lyrics.length; i++) {
      if (lyrics[i].time <= currentPosition) {
        index = i;
      } else {
        break;
      }
    }
    return index >= 0 ? index : null;
  }
}
