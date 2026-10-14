import 'package:isar_community/isar.dart';

part 'note.g.dart';

@Collection()
class NoteEntity {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false, type: IndexType.value)
  late String title;

  @Index(type: IndexType.value)
  List<String> bodyPlain = const [];

  late String bodyDelta;

  late DateTime createdAt;
  late DateTime updatedAt;

  DateTime? deletedAt;

  bool pinned = false;

  String? accentHex;

  @Index()
  int? categoryId;

  bool isPrivate = false;
}
