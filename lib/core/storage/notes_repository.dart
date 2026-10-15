import 'dart:async';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/models/note.dart';
import '../theme/app_colors.dart';

class NoteImageStore {
  NoteImageStore._();
  static final NoteImageStore instance = NoteImageStore._();

  Future<String> persistFromPicker(String tempPath) async {
    final dir = await _imagesDir();
    final ext = p.extension(tempPath).isEmpty ? '.jpg' : p.extension(tempPath);
    final name = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final dest = p.join(dir.path, name);
    final file = await _copy(tempPath, dest);
    return file.path;
  }

  Future<Directory> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'note_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _copy(String src, String dst) async {
    final source = File(src);
    return source.copy(dst);
  }
}

class NotesRepository {
  NotesRepository(this._isar);
  final Isar _isar;

  IsarCollection<NoteEntity> get _col => _isar.noteEntitys;

  Stream<List<NoteEntity>> watchActive() {
    final query = _col
        .filter()
        .deletedAtIsNull()
        .isPrivateEqualTo(false)
        .sortByPinnedDesc()
        .thenByUpdatedAtDesc()
        .build();
    return query.watch(fireImmediately: true);
  }

  Stream<List<NoteEntity>> watchByCategory(int categoryId) {
    final query = _col
        .filter()
        .deletedAtIsNull()
        .isPrivateEqualTo(false)
        .categoryIdEqualTo(categoryId)
        .sortByPinnedDesc()
        .thenByUpdatedAtDesc()
        .build();
    return query.watch(fireImmediately: true);
  }

  Stream<List<NoteEntity>> watchTrash() {
    final query = _col
        .filter()
        .deletedAtIsNotNull()
        .isPrivateEqualTo(false)
        .sortByDeletedAtDesc()
        .build();
    return query.watch(fireImmediately: true);
  }

  Stream<List<NoteEntity>> watchPrivateActive() {
    final query = _col
        .filter()
        .deletedAtIsNull()
        .isPrivateEqualTo(true)
        .sortByPinnedDesc()
        .thenByUpdatedAtDesc()
        .build();
    return query.watch(fireImmediately: true);
  }

  Future<NoteEntity?> getById(int id) => _col.get(id);

  Future<List<NoteEntity>> getActiveWithReminders() async {
    return _col
        .filter()
        .deletedAtIsNull()
        .reminderAtIsNotNull()
        .findAll();
  }

  Future<int> upsert(NoteEntity note) async {
    note.updatedAt = DateTime.now();
    if (note.id == Isar.autoIncrement) {
      note.createdAt = note.updatedAt;
    }
    return _isar.writeTxn(() => _col.put(note));
  }

  Future<void> setCategory(int noteId, int? categoryId) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(noteId);
      if (n == null) return;
      n.categoryId = categoryId;
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<void> unsetCategoryForDeleted(int categoryId) async {
    await _isar.writeTxn(() async {
      final notes = await _col
          .filter()
          .categoryIdEqualTo(categoryId)
          .findAll();
      for (final n in notes) {
        n.categoryId = null;
        await _col.put(n);
      }
    });
  }

  Future<void> softDelete(int id) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.deletedAt = DateTime.now();
      n.pinned = false;
      await _col.put(n);
    });
  }

  Future<void> restore(int id) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.deletedAt = null;
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<void> permanentDelete(int id) async {
    await _isar.writeTxn(() => _col.delete(id));
  }

  Future<void> togglePin(int id) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.pinned = !n.pinned;
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<void> setAccent(int id, int? index) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.accentHex = index == null
          ? null
          : '#${AppColors.noteAccents[index].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<void> setPrivate(int id, bool isPrivate) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.isPrivate = isPrivate;
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<void> setReminder(int id, DateTime? when) async {
    await _isar.writeTxn(() async {
      final n = await _col.get(id);
      if (n == null) return;
      n.reminderAt = when;
      n.updatedAt = DateTime.now();
      await _col.put(n);
    });
  }

  Future<List<int>> emptyTrash() async {
    return _isar.writeTxn(() async {
      final all = await _col.filter().deletedAtIsNotNull().findAll();
      final ids = all.map((n) => n.id).toList();
      await _col.deleteAll(ids);
      return ids;
    });
  }

  static const Duration trashRetention = Duration(days: 30);

  Future<List<int>> purgeExpiredTrash({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(trashRetention);
    return _isar.writeTxn(() async {
      final expired = await _col
          .filter()
          .deletedAtIsNotNull()
          .deletedAtLessThan(cutoff)
          .findAll();
      if (expired.isEmpty) return const [];
      final ids = expired.map((n) => n.id).toList();
      await _col.deleteAll(ids);
      return ids;
    });
  }

  Future<List<NoteEntity>> search(String term) async {
    final tokens = term
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return const [];

    QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> q = _col
        .filter()
        .deletedAtIsNull()
        .isPrivateEqualTo(false);
    for (final token in tokens) {
      q = q.group((g) {
        return g
            .titleStartsWith(token, caseSensitive: false)
            .or()
            .titleContains(token, caseSensitive: false)
            .or()
            .bodyPlainElementStartsWith(token, caseSensitive: false)
            .or()
            .bodyPlainElementContains(token, caseSensitive: false);
      });
    }
    return q.sortByUpdatedAtDesc().findAll();
  }
}
