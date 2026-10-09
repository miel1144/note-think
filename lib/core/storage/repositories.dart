import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/isar_service.dart';
import '../storage/categories_repository.dart';
import '../storage/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(IsarService.instance.isar),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => CategoriesRepository(IsarService.instance.isar),
);
