import 'package:isar_community/isar.dart';

part 'category.g.dart';

@Collection()
class CategoryEntity {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false, type: IndexType.value, unique: true)
  late String name;

  bool isTag = false;

  DateTime createdAt = DateTime.now();
}
