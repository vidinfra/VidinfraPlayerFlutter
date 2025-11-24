library;

import 'package:flutter/foundation.dart';

export 'controller/vidinfra_player_controller.dart';
export 'ui/components/assets.dart';
export 'ui/vidinfra_player_view.dart';

extension ValueNotifierBoolToggle on ValueNotifier<bool> {
  void toggle() => value = !value;
}
