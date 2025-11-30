import 'package:flutter/foundation.dart';
import 'package:kvideo/gen/pigeon.g.dart' as k;
import 'package:vidinfra_player/authentication/aes_auth.dart';

import 'models.dart';

typedef DownloadEventListener = k.DownloadEventListener;
typedef DownloadStatus = k.DownloadStatus;

class VidinfraDownloader with AESAuthMixin {
  final _downloader = k.DownloadManagerApi();

  VidinfraDownloader({DownloadEventListener? listener}) {
    DownloadEventListener.setUp(listener);
  }

  Future<String?> startDownloading(Media media) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _downloader.setAndroidDataSourceHeaders(aesAuthHeaders);
    }

    return _downloader.download(
      k.Media(url: media.url, headers: {...aesAuthHeaders, ...media.headers}),
    );
  }

  Future<void> remove(String id) => _downloader.remove(id);

  Future<void> removeAll() => _downloader.removeAll();

  Future<List<String>> getAllDownloadIds() => _downloader.getAllDownloads();

  Future<k.DownloadData?> getDownloadStatus(String id) =>
      _downloader.getStatusFor(id);
}
