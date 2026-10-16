import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SpotifyThumbnailCache {
  SpotifyThumbnailCache({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, Future<File?>> _inFlight = {};

  Future<File?> fileFor(String? url, {Directory? dirOverride}) {
    if (url == null || url.isEmpty) return Future.value(null);
    return _inFlight.putIfAbsent(url, () => _resolve(url, dirOverride));
  }

  Future<File?> _resolve(String url, Directory? dirOverride) async {
    try {
      final dir = await _ensureDir(dirOverride);
      final file = File(p.join(dir.path, filenameFor(url)));
      if (await file.exists()) return file;
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  static Future<Directory> _ensureDir(Directory? override) async {
    final dir = override ?? Directory(p.join(
      (await getApplicationDocumentsDirectory()).path,
      'spotify_covers',
    ));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static String filenameFor(String url) =>
      '${sha1.convert(utf8.encode(url))}.jpg';
}