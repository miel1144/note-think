import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/db/models/spotify_link.dart';

class SpotifyOembedService {
  SpotifyOembedService._();

  static const _oembedBase = 'https://open.spotify.com/oembed';

  static SpotifyLinkType? _typeFromPath(String pathSegment) {
    switch (pathSegment) {
      case 'track':
        return SpotifyLinkType.track;
      case 'playlist':
        return SpotifyLinkType.playlist;
      case 'album':
        return SpotifyLinkType.album;
    }
    return null;
  }

  static ({SpotifyLinkType type, String uri, String url})? parseInput(
    String input,
  ) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final uriMatch = RegExp(r'^spotify:(track|playlist|album):([A-Za-z0-9]+)$')
        .firstMatch(trimmed);
    if (uriMatch != null) {
      final type = _typeFromPath(uriMatch.group(1)!);
      final id = uriMatch.group(2)!;
      if (type == null) return null;
      return (
        type: type,
        uri: 'spotify:${uriMatch.group(1)}:$id',
        url: 'https://open.spotify.com/${uriMatch.group(1)}/$id',
      );
    }

    final urlMatch = RegExp(
      r'^https?://open\.spotify\.com/(track|playlist|album)/([A-Za-z0-9]+)',
    ).firstMatch(trimmed);
    if (urlMatch != null) {
      final type = _typeFromPath(urlMatch.group(1)!);
      final id = urlMatch.group(2)!;
      if (type == null) return null;
      return (
        type: type,
        uri: 'spotify:${urlMatch.group(1)}:$id',
        url: 'https://open.spotify.com/${urlMatch.group(1)}/$id',
      );
    }

    return null;
  }

  static Future<SpotifyOembedResult> fetchMetadata({
    required SpotifyLinkType type,
    required String url,
  }) async {
    final uri = Uri.parse(
      '$_oembedBase?url=${Uri.encodeQueryComponent(url)}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw SpotifyOembedException(
        'Spotify rechazó la URL (HTTP ${response.statusCode})',
      );
    }
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const SpotifyOembedException(
        'Respuesta inválida de Spotify',
      );
    }
    final title = (body['title'] as String?)?.trim();
    final author = (body['author_name'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      throw const SpotifyOembedException('Spotify no devolvió título');
    }
    return SpotifyOembedResult(
      type: type,
      title: title,
      subtitle: author ?? '',
      thumbnailUrl: body['thumbnail_url'] as String?,
    );
  }

  static Future<SpotifyOembedResult> resolveFromInput(String input) async {
    final parsed = parseInput(input);
    if (parsed == null) {
      throw const SpotifyOembedException(
        'URL o URI de Spotify inválido. Esperado: open.spotify.com/<track|playlist|album>/<id> o spotify:<type>:<id>',
      );
    }
    return fetchMetadata(type: parsed.type, url: parsed.url);
  }
}

class SpotifyOembedResult {
  const SpotifyOembedResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
  });

  final SpotifyLinkType type;
  final String title;
  final String subtitle;
  final String? thumbnailUrl;
}

class SpotifyOembedException implements Exception {
  const SpotifyOembedException(this.message);
  final String message;
  @override
  String toString() => message;
}
