import 'package:flutter/foundation.dart';

extension ValueNotifierExtensions on ValueNotifier<bool> {
  void toggle() => value = !value;
}

extension DurationExtensions on Duration {
  String toHHMMSS() {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);
    return h > 0 ? "${two(h)}:${two(m)}:${two(s)}" : "${two(m)}:${two(s)}";
  }
}
