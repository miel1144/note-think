import 'package:isar_community/isar.dart';

import '../db/models/category.dart';

class CategoriesRepository {
  CategoriesRepository(this._isar);
  final Isar _isar;

  IsarCollection<CategoryEntity> get _col => _isar.categoryEntitys;

  Stream<List<CategoryEntity>> watchAll() {
    return _col.where().sortByCreatedAt().build().watch(fireImmediately: true);
  }

  Future<int> create(String name, {bool isTag = false}) async {
    final c = CategoryEntity()
      ..name = name.trim()
      ..isTag = isTag
      ..createdAt = DateTime.now();
    return _isar.writeTxn(() => _col.put(c));
  }

  Future<void> rename(int id, String name) async {
    await _isar.writeTxn(() async {
      final c = await _col.get(id);
      if (c == null) return;
      c.name = name.trim();
      await _col.put(c);
    });
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _col.delete(id));
  }
}
