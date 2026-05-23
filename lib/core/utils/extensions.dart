import 'package:intl/intl.dart';

extension DurationExtensions on Duration {
  String formatMmSs() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String formatHhMmSs() {
    if (inHours > 0) {
      final hours = inHours;
      final minutes = inMinutes.remainder(60);
      final seconds = inSeconds.remainder(60);
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return formatMmSs();
  }
}

extension DateTimeExtensions on DateTime {
  String formatDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String formatDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return formatDate();
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}

extension StringExtensions on String? {
  String toTitleCase() {
    if (this == null || this!.isEmpty) return '';
    return this!.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

extension IntExtensions on int? {
  String formatNumber() {
    if (this == null) return '0';
    return NumberFormat.decimalPattern().format(this);
  }
}
