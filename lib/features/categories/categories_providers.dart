import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/category.dart';
import '../../core/storage/repositories.dart';

final categoriesListProvider = StreamProvider<List<CategoryEntity>>(
  (ref) => ref.watch(categoriesRepositoryProvider).watchAll(),
);
