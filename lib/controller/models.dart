import 'package:flutter/services.dart';

class Media {
  /// Video Title
  final String title;

  /// Video Description (Optional)
  final String? description;

  /// The Dash URL of the media (required)
  final String url;

  /// Widevine License URL if the media is DRM protected
  // final String? drmLicenseUrl;

  /// Fairplay certificate. Can be either URL or Base64 encoded certificate
  // final String? drmCertificate;

  /// External subtitles url
  final List<SubtitleData> subtitles;

  /// Where to start media from (in seconds)
  final int startFromSecond;

  /// Player headers
  final Map<String, String> headers;

  /// IMA Ads
  // final String? imaTagUrl;

  final String? spriteVttUrl, chaptersVttUrl;

  Media({
    required this.title,
    this.description,
    required this.url,
    // this.drmLicenseUrl,
    // this.drmCertificate,
    this.subtitles = const [],
    this.startFromSecond = 0,
    this.headers = const {},
    // this.imaTagUrl,
    this.spriteVttUrl,
    this.chaptersVttUrl,
  });
}

class SubtitleData {
  final String? label;
  final String language, url;

  SubtitleData({this.label, required this.language, required this.url});
}

/// Configurations -------------------------------------------------------------

class VidinfraConfiguration {
  final FullscreenExitAppState fullscreenExitAppState;
  // final Appearance appearance;

  const VidinfraConfiguration({
    this.fullscreenExitAppState = const FullscreenExitAppState(),
    // required this.appearance,
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

/// Configurations - Remote ----------------------------------------------------
class PlayerConfig {
  final List<double> playbackSpeeds;
  final Appearance appearance;
  final Controls controls;
  final String organizationId;
  final String id;
  final String libraryId;
  final bool isBetaEnabled;
  final bool isDefault;
  final bool enableResumablePosition;

  PlayerConfig({
    required this.playbackSpeeds,
    required this.appearance,
    required this.controls,
    required this.organizationId,
    required this.id,
    required this.libraryId,
    required this.isBetaEnabled,
    required this.isDefault,
    required this.enableResumablePosition,
  });

  factory PlayerConfig.fromJson(Map<String, dynamic> json) {
    return PlayerConfig(
      playbackSpeeds: List<double>.from(
        json["playback_speeds"].map((x) => x.toDouble()),
      ),
      appearance: Appearance.fromJson(json["appearance"]),
      controls: Controls.fromJson(json["controls"]),
      organizationId: json["organization_id"],
      id: json["id"],
      libraryId: json["library_id"],
      isBetaEnabled: json["is_beta_enabled"],
      isDefault: json["is_default"],
      enableResumablePosition: json["enable_resumable_position"],
    );
  }

  Map<String, dynamic> toJson() => {
    "playback_speeds": playbackSpeeds,
    "appearance": appearance.toJson(),
    "controls": controls.toJson(),
    "organization_id": organizationId,
    "id": id,
    "library_id": libraryId,
    "is_beta_enabled": isBetaEnabled,
    "is_default": isDefault,
    "enable_resumable_position": enableResumablePosition,
  };
}

class Appearance {
  final String primaryColor;
  final String captionFontColor;
  final String captionBackgroundColor;
  final String logo;
  final String logoDestinationUrl;
  final int fontSize;
  final int captionFontSize;

  Appearance({
    required this.primaryColor,
    required this.captionFontColor,
    required this.captionBackgroundColor,
    required this.logo,
    required this.logoDestinationUrl,
    required this.fontSize,
    required this.captionFontSize,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      primaryColor: json["primary_color"],
      captionFontColor: json["caption_font_color"],
      captionBackgroundColor: json["caption_background_color"],
      logo: json["logo"],
      logoDestinationUrl: json["logo_destination_url"],
      fontSize: json["font_size"],
      captionFontSize: json["caption_font_size"],
    );
  }

  Map<String, dynamic> toJson() => {
    "primary_color": primaryColor,
    "caption_font_color": captionFontColor,
    "caption_background_color": captionBackgroundColor,
    "logo": logo,
    "logo_destination_url": logoDestinationUrl,
    "font_size": fontSize,
    "caption_font_size": captionFontSize,
  };
}

class Controls {
  final bool backward;
  final bool forward;
  final bool cast;
  final bool bigPlayButton;
  final bool captions;
  final bool chapters;
  final bool currentTime;
  final bool duration;
  final bool fullscreen;
  final bool mute;
  final bool pictureInPicture;
  final bool playPause;
  final bool progress;
  final bool settings;
  final bool volume;
  final bool hideBranding;
  final bool preload;
  final bool controlsVisible;
  final bool enableDownloadButton;
  final bool loop;

  Controls({
    required this.backward,
    required this.forward,
    required this.cast,
    required this.bigPlayButton,
    required this.captions,
    required this.chapters,
    required this.currentTime,
    required this.duration,
    required this.fullscreen,
    required this.mute,
    required this.pictureInPicture,
    required this.playPause,
    required this.progress,
    required this.settings,
    required this.volume,
    required this.hideBranding,
    required this.preload,
    required this.controlsVisible,
    required this.enableDownloadButton,
    required this.loop,
  });

  factory Controls.fromJson(Map<String, dynamic> json) {
    return Controls(
      backward: json["backward"],
      forward: json["forward"],
      cast: json["cast"],
      bigPlayButton: json["big_play_button"],
      captions: json["captions"],
      chapters: json["chapters"],
      currentTime: json["current_time"],
      duration: json["duration"],
      fullscreen: json["fullscreen"],
      mute: json["mute"],
      pictureInPicture: json["picture_in_picture"],
      playPause: json["play_pause"],
      progress: json["progress"],
      settings: json["settings"],
      volume: json["volume"],
      hideBranding: json["hide_branding"],
      preload: json["preload"],
      controlsVisible: json["controls_visible"],
      enableDownloadButton: json["enable_download_button"],
      loop: json["loop"],
    );
  }

  Map<String, dynamic> toJson() => {
    "backward": backward,
    "forward": forward,
    "cast": cast,
    "big_play_button": bigPlayButton,
    "captions": captions,
    "chapters": chapters,
    "current_time": currentTime,
    "duration": duration,
    "fullscreen": fullscreen,
    "mute": mute,
    "picture_in_picture": pictureInPicture,
    "play_pause": playPause,
    "progress": progress,
    "settings": settings,
    "volume": volume,
    "hide_branding": hideBranding,
    "preload": preload,
    "controls_visible": controlsVisible,
    "enable_download_button": enableDownloadButton,
    "loop": loop,
  };
}
