import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kvideo/kvideo.dart' as k;
import 'package:vidinfra_player/authentication/aes_auth.dart';

import 'models.dart';

class VidinfraPlayerController with AESAuthSetup {
  /// Internal implementation, Not to be used outside of the package
  final kController = k.PlayerController();
  final Completer _init = Completer();

  VidinfraPlayerController() {
    kController.initialize().then(_init.complete);
    kController.state.status.addListener(_statusUpdater);
  }

  /// This will be used and toggled by ui
  final ValueNotifier<bool> controlsVisible = ValueNotifier(true);

  /// Whether to show loading indicator
  final ValueNotifier<bool> loading = ValueNotifier(false);

  Future<void> play(Media media) async {
    if (!_init.isCompleted) await _init.future;
    kController.play(
      k.Media(
        url: media.url,
        headers: {...aesAuthHeaders, ...media.headers},
        startFromSecond: media.startFromSecond,
      ),
    );
  }

  void _statusUpdater() {
    final status = kController.state.status.value;
    loading.value = status == k.PlaybackStatus.preparing;
  }

  void dispose() {
    if (!_init.isCompleted) _init.completeError("Disposed before init");
    kController.state.status.removeListener(_statusUpdater);
    controlsVisible.dispose();
  }
}
