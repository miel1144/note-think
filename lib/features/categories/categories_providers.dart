import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/category.dart';
import '../../core/storage/repositories.dart';

final foldersListProvider = StreamProvider<List<CategoryEntity>>(
  (ref) => ref.watch(foldersRepositoryProvider).watchAll(),
);

final folderByIdProvider = FutureProvider.family<CategoryEntity?, int>(
  (ref, id) => ref.watch(foldersRepositoryProvider).getById(id),
);

final noteCountByFolderProvider = StreamProvider.family<int, int>((ref, id) {
  return ref
      .watch(notesRepositoryProvider)
      .watchByCategory(id)
      .map((notes) => notes.length);
});
