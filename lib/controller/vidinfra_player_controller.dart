import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kvideo/kvideo.dart' as k;

import 'models.dart';

class VidinfraPlayerController {
  /// Internal implementation, Not to be used outside of the package
  final kController = k.PlayerController();
  final Completer _init = Completer();

  VidinfraPlayerController() {
    kController.initialize().then(_init.complete);
  }

  final ValueNotifier<bool> controlsVisible = ValueNotifier(true);
  final ValueNotifier<bool> loading = ValueNotifier(false);

  Future<void> play(Media media) async {
    if (!_init.isCompleted) await _init.future;
    kController.play(k.Media(url: media.url));
  }

  void dispose() {
    if (!_init.isCompleted) _init.completeError("Disposed before init");
    controlsVisible.dispose();
  }
}
