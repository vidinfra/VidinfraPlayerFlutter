import 'dart:convert';
import 'dart:math' hide log;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

typedef AESAuthOptions = ({int? nonceLength, int? timestamp, String? nonce});

class AESAuth {
  const AESAuth._();

  static const _alphanumeric =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  static const int defaultNonceLength = 16;
  static const int defaultAuthNonceLength = 24;

  static String _generateNonce([int length = defaultNonceLength]) {
    final targetLength = max(1, length);
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < targetLength; i += 1) {
      final index = random.nextInt(_alphanumeric.length);
      buffer.write(_alphanumeric[index]);
    }
    return buffer.toString();
  }

  static String _bytesToHex(List<int> bytes) =>
      bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();

  static String _generateHmac(String message, String secret) {
    final keyBytes = utf8.encode(secret);
    final messageBytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(messageBytes);
    return _bytesToHex(digest.bytes);
  }

  static Map<String, String> generateHeaders({
    String method = 'GET',
    required String secret,
    String referer = "player.vidinfra.com",
    AESAuthOptions? options,
  }) {
    if (secret.isEmpty) {
      throw ArgumentError('generateAuthHeaders requires a non-empty secret');
    }

    final unixTimestamp =
        options?.timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce =
        options?.nonce ??
        _generateNonce(options?.nonceLength ?? defaultAuthNonceLength);

    final canonical = [
      method.toUpperCase(),
      defaultTargetPlatform.name.toLowerCase(),
      referer,
      unixTimestamp.toString(),
      nonce,
    ].join('|');

    final signature = _generateHmac(
      canonical,
      String.fromCharCodes(secret.runes.toList().reversed),
    );

    return {
      'X-Auth-Signature': signature,
      'X-Auth-Timestamp': unixTimestamp.toString(),
      'X-Auth-Nonce': nonce,
      'Platform': defaultTargetPlatform.name.toLowerCase(),
    };
  }
}

mixin AESAuthSetup {
  /// To be automatically passed in as Media headers
  Map<String, String> aesAuthHeaders = {};

  void setupAESAuth({
    String method = 'GET',
    required String secret,
    String referer = "player.vidinfra.com",
    AESAuthOptions? options,
  }) => aesAuthHeaders = AESAuth.generateHeaders(
    secret: secret,
    method: method,
    referer: referer,
    options: options,
  );
}
