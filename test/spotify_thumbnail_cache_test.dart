import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notethink/features/spotify/spotify_thumbnail_cache.dart';

void main() {
  group('SpotifyThumbnailCache.fileFor', () {
    test('returns null for null or empty url', () async {
      final cache = SpotifyThumbnailCache();
      expect(await cache.fileFor(null), isNull);
      expect(await cache.fileFor(''), isNull);
    });

    test('downloads image on miss and writes to cache dir', () async {
      final dir = await Directory.systemTemp.createTemp('spotify_thumb_1');
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      const url = 'https://i.scdn.co/image/abc?width=300';
      final client = MockClient((req) async {
        expect(req.url.toString(), url);
        return http.Response.bytes(bytes, 200);
      });
      final cache = SpotifyThumbnailCache(client: client);

      final file = await cache.fileFor(url, dirOverride: dir);

      expect(file, isNotNull);
      expect(await file!.exists(), isTrue);
      expect(await file.readAsBytes(), bytes);
    });

    test('returns existing file without hitting http on hit', () async {
      final dir = await Directory.systemTemp.createTemp('spotify_thumb_2');
      const url = 'https://i.scdn.co/image/cached?width=300';
      final filename = SpotifyThumbnailCache.filenameFor(url);
      File('${dir.path}/$filename').writeAsBytesSync([7, 7, 7]);

      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        return http.Response.bytes([], 500);
      });
      final cache = SpotifyThumbnailCache(client: client);

      final file = await cache.fileFor(url, dirOverride: dir);

      expect(file, isNotNull);
      expect(await file!.readAsBytes(), [7, 7, 7]);
      expect(httpCalls, 0);
    });

    test('returns null when http returns non-200', () async {
      final dir = await Directory.systemTemp.createTemp('spotify_thumb_3');
      final client = MockClient((_) async => http.Response('', 404));
      final cache = SpotifyThumbnailCache(client: client);

      final file = await cache.fileFor(
        'https://i.scdn.co/image/x?width=300',
        dirOverride: dir,
      );

      expect(file, isNull);
    });

    test('same URL maps to the same filename', () {
      const url = 'https://i.scdn.co/image/abc?width=300';
      expect(
        SpotifyThumbnailCache.filenameFor(url),
        SpotifyThumbnailCache.filenameFor(url),
      );
    });
  });
}