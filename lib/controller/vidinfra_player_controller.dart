import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kvideo/kvideo.dart' as k;
import 'package:vidinfra_player/authentication/aes_auth.dart';

import 'models.dart';

part 'ui_controller_mixin.dart';

class VidinfraPlayerController with AESAuthMixin, UiControllerMixin {
  /// Internal implementation, Not to be used outside of the package
  final kController = k.PlayerController();
  final Completer _init = Completer();

  /// Internal implementation, Not to be used outside of the package
  @override
  k.PlayerState get kState => kController.state;

  VidinfraPlayerController() {
    kController.initialize().then(_init.complete);

    kState.status.addListener(_statusUpdater);

    controlsVisible.addListener(autoHideControls);
    if (controlsVisible.value) autoHideControls();
  }

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

  void dispose() {
    if (!_init.isCompleted) _init.completeError("Disposed before init");

    kState.status.removeListener(_statusUpdater);
    controlsVisible.removeListener(autoHideControls);

    controlsVisible.dispose();
    kController.dispose();
  }
}
