import 'package:flutter/material.dart';
import 'package:musikita/core/utils/extensions.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool showTimeLabels;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
    this.showTimeLabels = true,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inMilliseconds.toDouble();
    final value = _dragValue ?? widget.position.inMilliseconds.toDouble();
    final clampedValue = value.clamp(0.0, max);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          min: 0,
          max: max > 0 ? max : 1,
          value: clampedValue,
          onChanged: max > 0
              ? (v) {
                  setState(() => _dragValue = v);
                  widget.onChanged?.call(Duration(milliseconds: v.round()));
                }
              : null,
          onChangeEnd: max > 0
              ? (v) {
                  setState(() => _dragValue = null);
                  widget.onChangeEnd?.call(Duration(milliseconds: v.round()));
                }
              : null,
        ),
        if (widget.showTimeLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.position.formatMmSs(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  widget.duration.formatMmSs(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
