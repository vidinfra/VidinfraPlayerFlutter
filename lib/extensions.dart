import 'package:flutter/foundation.dart';

extension ValueNotifierBoolToggle on ValueNotifier<bool> {
  void toggle() => value = !value;
}
