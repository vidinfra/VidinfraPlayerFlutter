import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvideo/kvideo.dart' as k;
import 'package:kvideo/player_view.dart';
import 'package:vidinfra_player/authentication/aes_auth.dart';
import 'package:volume_controller/volume_controller.dart';

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
    kState.progress.addListener(_progressUpdater);
    kState.buffer.addListener(_progressUpdater);
    kState.duration.addListener(_progressUpdater);

    prepareVolumeBrightnessControls();

    controlsVisible.addListener(autoHideControls);
    if (controlsVisible.value) autoHideControls();
  }

  // Progress Handler ----------------------------------------------------------
  void _progressUpdater() {
    final progress = kState.progress.value.inSeconds;
    final duration = kState.duration.value.inSeconds;
    final buffer = kState.buffer.value.inSeconds;

    print("$progress $duration $buffer $_buffer");

    _progress = (duration > 0) ? progress / duration : null;
    _buffer = (duration > 0) ? buffer / duration : null;
    notifyListeners();
  }

  double? _progress, _buffer;

  // Media Progress between 0.0 to 1.0 <br> May be null if unavailable (e.g live)
  double? get progress => _progress?.clamp(0, 1);

  // Media Buffer Progress between 0.0 to 1.0
  double get buffer => _buffer?.clamp(0, 1) ?? 0.0;

  void seekTo(double value) {
    value = value.clamp(0.0, 1.0);
    final duration = kState.duration.value.inSeconds;
    if (duration <= 0) return;

    final target = Duration(seconds: (value * duration).round());
    kController.seekTo(target);
  }

  // ---------------------------------------------------------------------------

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

    prepareThumbnailPreviews();
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
