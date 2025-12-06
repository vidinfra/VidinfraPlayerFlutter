import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kvideo/kvideo.dart' as k;
import 'package:kvideo/player_view.dart';
import 'package:video_preview_thumbnails/video_preview_thumbnails.dart';
import 'package:vidinfra_player/authentication/aes_auth.dart';
import 'package:vidinfra_player/controller/models.dart';
import 'package:volume_controller/volume_controller.dart';

part 'playback_settings_mixin.dart';
part 'ui_controller_mixin.dart';

class VidinfraPlayerController extends ChangeNotifier
    with AESAuthMixin, UiControllerMixin, PlaybackSettingsMixin {
  /// Internal implementation, Not to be used outside of the package
  @override
  late final kController = k.PlayerController(
    androidViewMode: AndroidViewMode.hybrid,
  );

  final Completer _init = Completer();

  /// Internal implementation, Not to be used outside of the package
  @override
  k.PlayerState get kState => kController.state;

  @override
  final ValueNotifier<Media?> _nowPlaying = ValueNotifier(null);

  Media? get nowPlaying => _nowPlaying.value;

  @override
  final VidinfraConfiguration configuration;

  bool _disposed = false;

  @override
  bool get disposed => _disposed;

  final _kConfiguration = k.PlayerConfiguration(
    seekConfig: k.SeekConfig(seekBackMs: 10, seekForwardMs: 10),
    initializeIMA: false,
  );

  VidinfraPlayerController({
    this.configuration = const VidinfraConfiguration(),
  }) {
    kController.initialize(configuration: _kConfiguration).then(_init.complete);
    kState.status.addListener(_statusUpdater);
    kState.progress.addListener(_progressUpdater);
    kState.buffer.addListener(_progressUpdater);
    kState.duration.addListener(_progressUpdater);
    controlsVisible.addListener(autoHideControls);
    if (controlsVisible.value) autoHideControls();
    initializeUiControllerMixin();
    initializePlaybackSettingsMixin();
  }

  // Progress Handler ----------------------------------------------------------
  void _progressUpdater() {
    final progress = kState.progress.value.inSeconds;
    final duration = kState.duration.value.inSeconds;
    final buffer = kState.buffer.value.inSeconds;

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
    previewThumbnailController.setCurrentTime(-1);
  }

  // ---------------------------------------------------------------------------

  Future<void> play(Media media) async {
    if (!_init.isCompleted) await _init.future;
    _nowPlaying.value = media;
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
    _disposed = true;

    kState.status.removeListener(_statusUpdater);
    controlsVisible.removeListener(autoHideControls);

    controlsVisible.dispose();
    kController.dispose();

    disposePlaybackSettingsMixin();
    disposeUiControllerMixin();
  }
}
