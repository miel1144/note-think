import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/category.dart';
import 'models/note.dart';
import 'models/spotify_link.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get isar {
    final i = _isar;
    if (i == null) {
      throw StateError('IsarService.open() must be awaited before use.');
    }
    return i;
  }

  Future<Isar> open() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [NoteEntitySchema, CategoryEntitySchema, SpotifyLinkEntitySchema],
      directory: dir.path,
      name: 'notethink',
      inspector: false,
    );
    return _isar!;
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
