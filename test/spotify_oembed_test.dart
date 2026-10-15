import 'package:flutter_test/flutter_test.dart';
import 'package:notethink/features/spotify/spotify_oembed_service.dart';

void main() {
  group('SpotifyOembedService.parseInput', () {
    test('parses https open.spotify.com track URL', () {
      final r = SpotifyOembedService.parseInput(
        'https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'track');
      expect(r.uri, 'spotify:track:4iV5W9uYEdYUVa79Axb7Rh');
      expect(r.url, 'https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh');
    });

    test('parses https open.spotify.com playlist URL', () {
      final r = SpotifyOembedService.parseInput(
        'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'playlist');
    });

    test('parses https open.spotify.com album URL', () {
      final r = SpotifyOembedService.parseInput(
        'https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'album');
    });

    test('parses spotify: URI for track', () {
      final r = SpotifyOembedService.parseInput(
        'spotify:track:4iV5W9uYEdYUVa79Axb7Rh',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'track');
      expect(r.uri, 'spotify:track:4iV5W9uYEdYUVa79Axb7Rh');
    });

    test('parses URL with query params', () {
      final r = SpotifyOembedService.parseInput(
        'https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh?si=abc123',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'track');
    });

    test('returns null for empty input', () {
      expect(SpotifyOembedService.parseInput(''), isNull);
      expect(SpotifyOembedService.parseInput('   '), isNull);
    });

    test('returns null for invalid URL', () {
      expect(SpotifyOembedService.parseInput('not a spotify url'), isNull);
      expect(
        SpotifyOembedService.parseInput('https://youtube.com/watch?v=123'),
        isNull,
      );
    });

    test('returns null for artist URL (not supported)', () {
      final r = SpotifyOembedService.parseInput(
        'https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGkNZYX',
      );
      expect(r, isNull);
    });

    test('trims whitespace', () {
      final r = SpotifyOembedService.parseInput(
        '   https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh   ',
      );
      expect(r, isNotNull);
      expect(r!.type.name, 'track');
    });
  });
}
