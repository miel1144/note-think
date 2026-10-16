import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/spotify_link.dart';
import '../../core/storage/repositories.dart';
import 'spotify_thumbnail_cache.dart';

final spotifyLinksByNoteProvider =
    StreamProvider.family<List<SpotifyLinkEntity>, int>((ref, noteId) {
  return ref.watch(spotifyRepositoryProvider).watchByNote(noteId);
});

final spotifyLinkCountByNoteProvider =
    StreamProvider.family<int, int>((ref, noteId) {
  return ref
      .watch(spotifyRepositoryProvider)
      .watchByNote(noteId)
      .map((links) => links.length);
});

final spotifyThumbnailCacheProvider =
    Provider<SpotifyThumbnailCache>((ref) => SpotifyThumbnailCache());
