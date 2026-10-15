import 'dart:async';

import 'package:isar_community/isar.dart';

import '../../core/db/models/spotify_link.dart';
import 'spotify_oembed_service.dart';

class SpotifyRepository {
  SpotifyRepository(this._isar);
  final Isar _isar;

  IsarCollection<SpotifyLinkEntity> get _col => _isar.spotifyLinkEntitys;

  Stream<List<SpotifyLinkEntity>> watchByNote(int noteId) {
    final q = _col
        .filter()
        .noteIdEqualTo(noteId)
        .sortByAddedAtDesc()
        .build();
    return q.watch(fireImmediately: true);
  }

  Future<List<SpotifyLinkEntity>> getByNote(int noteId) {
    return _col.filter().noteIdEqualTo(noteId).sortByAddedAtDesc().findAll();
  }

  Future<int> countByNote(int noteId) {
    return _col.filter().noteIdEqualTo(noteId).count();
  }

  Future<Map<int, int>> countsByNoteIds(List<int> noteIds) async {
    if (noteIds.isEmpty) return const {};
    final result = <int, int>{};
    for (final id in noteIds) {
      result[id] = await _col.filter().noteIdEqualTo(id).count();
    }
    return result;
  }

  Future<SpotifyLinkEntity> addFromInput({
    required int noteId,
    required String input,
  }) async {
    final meta = await SpotifyOembedService.resolveFromInput(input);
    final parsed = SpotifyOembedService.parseInput(input)!;
    final link = SpotifyLinkEntity()
      ..noteId = noteId
      ..spotifyUri = parsed.uri
      ..spotifyUrl = parsed.url
      ..type = meta.type
      ..title = meta.title
      ..subtitle = meta.subtitle
      ..thumbnailUrl = meta.thumbnailUrl
      ..addedAt = DateTime.now();
    await _isar.writeTxn(() async {
      link.id = await _col.put(link);
    });
    return link;
  }

  Future<void> remove(int linkId) async {
    await _isar.writeTxn(() async {
      await _col.delete(linkId);
    });
  }

  Future<void> removeAllForNote(int noteId) async {
    await _isar.writeTxn(() async {
      final ids = await _col
          .filter()
          .noteIdEqualTo(noteId)
          .idProperty()
          .findAll();
      await _col.deleteAll(ids);
    });
  }
}
