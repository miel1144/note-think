import 'package:isar_community/isar.dart';

import '../db/models/category.dart';
import 'notes_repository.dart';

class FoldersRepository {
  FoldersRepository(this._isar, this._notes);
  final Isar _isar;
  final NotesRepository _notes;

  IsarCollection<CategoryEntity> get _col => _isar.categoryEntitys;

  Stream<List<CategoryEntity>> watchAll() {
    final query = _col.where().sortByName().build();
    return query.watch(fireImmediately: true);
  }

  Future<CategoryEntity?> getById(int id) => _col.get(id);

  Future<int> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return Isar.autoIncrement;
    final c = CategoryEntity()
      ..name = trimmed
      ..isTag = false
      ..createdAt = DateTime.now();
    return _isar.writeTxn(() => _col.put(c));
  }

  Future<void> rename(int id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _isar.writeTxn(() async {
      final c = await _col.get(id);
      if (c == null) return;
      c.name = trimmed;
      await _col.put(c);
    });
  }

  Future<void> delete(int id) async {
    await _notes.unsetCategoryForDeleted(id);
    await _isar.writeTxn(() => _col.delete(id));
  }
}
