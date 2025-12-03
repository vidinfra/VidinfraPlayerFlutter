import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvideo/kvideo.dart' as k;
import 'package:kvideo/player_view.dart';
import 'package:vidinfra_player/authentication/aes_auth.dart';

import '../extensions.dart';
import 'models.dart';

part 'ui_controller_mixin.dart';

class VidinfraPlayerController extends ChangeNotifier
    with AESAuthMixin, UiControllerMixin {
  /// Internal implementation, Not to be used outside of the package
  @override
  late final kController = k.PlayerController(
    androidViewMode: AndroidViewMode.hybrid,
  );

  final Completer _init = Completer();

  /// Internal implementation, Not to be used outside of the package
  @override
  k.PlayerState get kState => kController.state;

  Media? nowPlaying;

  @override
  final VidinfraConfiguration configuration;

  VidinfraPlayerController({
    this.configuration = const VidinfraConfiguration(),
  }) {
    kController.initialize().then(_init.complete);

    kState.status.addListener(_statusUpdater);

    controlsVisible.addListener(autoHideControls);
    if (controlsVisible.value) autoHideControls();
  }

  Future<void> play(Media media) async {
    if (!_init.isCompleted) await _init.future;
    nowPlaying = media;
    kController.play(
      k.Media(
        url: media.url,
        headers: {...aesAuthHeaders, ...media.headers},
        startFromSecond: media.startFromSecond,
      ),
    );

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    if (!_init.isCompleted) _init.completeError("Disposed before init");

    kState.status.removeListener(_statusUpdater);
    controlsVisible.removeListener(autoHideControls);

    controlsVisible.dispose();
    kController.dispose();
  }
}
