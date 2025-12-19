import 'package:flutter/services.dart';

class Configuration {
  final FullscreenExitAppState fullscreenExitAppState;

  final List<double> playbackSpeeds;
  final Controls controls;

  const Configuration({
    this.fullscreenExitAppState = const FullscreenExitAppState(),
    this.playbackSpeeds = const [0.5, 1.0, 1.5, 2],
    this.controls = const Controls(),
  });
}

class FullscreenExitAppState {
  final List<DeviceOrientation> orientations;
  final SystemUiMode mode;

  const FullscreenExitAppState({
    this.orientations = const [DeviceOrientation.portraitUp],
    this.mode = SystemUiMode.edgeToEdge,
  });
}

class Controls {
  final bool backward;
  final bool forward;
  final bool bigPlayButton;
  final bool currentTime;
  final bool fullscreen;
  final bool mute;
  final bool pictureInPicture;
  final bool playPause;
  final bool seekBar;
  final bool settings;
  final bool branding;

  const Controls({
    this.backward = true,
    this.forward = true,
    this.bigPlayButton = true,
    this.currentTime = true,
    this.fullscreen = true,
    this.mute = true,
    this.pictureInPicture = true,
    this.playPause = true,
    this.seekBar = true,
    this.settings = true,
    this.branding = true,
  });
}
