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
