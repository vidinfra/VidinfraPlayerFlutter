import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:http/http.dart' as http;
import 'package:kvideo/gen/pigeon.g.dart' as k;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_preview_thumbnails/video_preview_thumbnails.dart';
import 'package:vidinfra_player/authentication/aes_auth.dart';

import 'models.dart';

typedef DownloadEventListener = k.DownloadEventListener;
typedef DownloadStatus = k.DownloadStatus;

class VidinfraDownloader with AESAuthMixin implements DownloadEventListener {
  final _downloader = k.DownloadManagerApi();

  late final Directory _extrasPath;

  VidinfraDownloader() {
    DownloadEventListener.setUp(this);
    getApplicationSupportDirectory().then(
      (value) => _extrasPath = Directory(
        p.join(value.path, "vidinfra_downloads_extra"),
      )..createSync(),
    );
  }

  // Will return a UUID if no customIdentifier is provided
  Future<String?> startDownloading(
    Media media, {
    String? customIdentifier,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _downloader.setAndroidDataSourceHeaders(aesAuthHeaders);
    }

    if (customIdentifier != null && customIdentifier.trim().isEmpty) {
      customIdentifier = null;
    }

    late final String url;
    try {
      final playlistUri = Uri.parse(media.url);
      final content = await http.get(playlistUri);
      final master = await HlsPlaylistParser.create().parseString(
        playlistUri,
        content.body,
      );

      if (master is HlsMasterPlaylist) {
        url = await _pickVideoTrack(master);
      } else {
        url = media.url;
      }
    } catch (e, s) {
      if (kDebugMode) debugPrintStack(stackTrace: s, label: e.toString());
      url = media.url;
    }

    final id = await _downloader.download(
      k.Media(url: url, headers: {...aesAuthHeaders, ...media.headers}),
      customIdentifier,
    );

    if (id != null) _downloadExtras(media, id);
    return id;
  }

  Future<void> remove(String id) async {
    if (id.trim().isEmpty) return;
    _removeExtras(id);
    return _downloader.remove(id);
  }

  Future<void> removeAll() {
    _removeAllExtras();
    return _downloader.removeAll();
  }

  Future<List<String>> getAllDownloadIds() => _downloader.getAllDownloads();

  Future<k.DownloadData?> getDownloadStatus(String id) {
    final data = k.DownloadData();

    return _downloader.getStatusFor(id);
  }

  /// Event Callbacks ----------------------------------------------------------
  final List<DownloadEventListener> _listeners = List.of([]);

  void addListener(DownloadEventListener listener) => _listeners.add(listener);

  void removeListener(DownloadEventListener listener) =>
      _listeners.remove(listener);

  @override
  void onCompletion(String id, String location) {
    for (var element in _listeners) {
      element.onCompletion(id, location);
    }
  }

  @override
  void onError(String id, String error) {
    for (var element in _listeners) {
      element.onError(id, error);
    }
  }

  @override
  void onProgress(String id, int progress) {
    for (var element in _listeners) {
      element.onProgress(id, progress);
    }
  }

  @override
  void onRemoved(String id) {
    for (var element in _listeners) {
      element.onRemoved(id);
    }
  }

  /// --------------------------------------------------------------------------

  /// Media Extras Downloader---------------------------------------------------

  Directory _dir(String id) => Directory(p.join(_extrasPath.path, id));

  Future<void> _downloadExtras(Media media, String id) async {
    _dir(id).createSync();
    final sprite = Uri.tryParse(media.spriteVttUrl ?? "");
    if (sprite != null) {
      /// Download VTT Sprite
      Future.microtask(() async {
        final vttData = await http.get(sprite);
        final path = File(p.join(_dir(id).path, "sprite.vtt"));
        path.writeAsBytesSync(vttData.bodyBytes);
        final vtt = path.readAsStringSync();

        final controller = VttDataController.string(vtt);
        final imagePathSegments = List.of(sprite.pathSegments);
        imagePathSegments.last = controller.vttData.first.imageUrl;

        final imgData = http.get(
          sprite.replace(pathSegments: imagePathSegments),
        );
        final image = File(p.join(_dir(id).path, imagePathSegments.last));
        image.writeAsBytes((await imgData).bodyBytes);
      });
    }
  }

  void _removeExtras(String id) => _dir(id).delete(recursive: true);

  void _removeAllExtras() => _dir("").delete(recursive: true);

  /// Returns locally stored sprites if exists
  String? localSpritePath(String id) {
    final path = File(p.join(_dir(id).path, "sprite.vtt"));
    if (path.existsSync()) return path.uri.toString();
    return null;
  }

  /// --------------------------------------------------------------------------

  /// Track Picker -------------------------------------------------------------
  Future<String> _pickVideoTrack(HlsMasterPlaylist master) async {
    // final tracks = List.of(master.variants);
    final tracks = List.of(master.mediaPlaylistUrls.map((e) => e.toString()));
    return tracks.first; // Highest Quality
  }
}
