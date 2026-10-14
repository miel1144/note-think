import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';

final notesListProvider = StreamProvider<List<NoteEntity>>(
  (ref) => ref.watch(notesRepositoryProvider).watchActive(),
);

final notesByFolderProvider = StreamProvider.family<List<NoteEntity>, int>(
  (ref, folderId) =>
      ref.watch(notesRepositoryProvider).watchByCategory(folderId),
);

final trashListProvider = StreamProvider<List<NoteEntity>>(
  (ref) => ref.watch(notesRepositoryProvider).watchTrash(),
);

final noteByIdProvider = FutureProvider.family<NoteEntity?, int>(
  (ref, id) => ref.watch(notesRepositoryProvider).getById(id),
);

class SearchController extends AsyncNotifier<List<NoteEntity>> {
  Timer? _debounce;

  @override
  Future<List<NoteEntity>> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return const <NoteEntity>[];
  }

  void query(String term) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      state = const AsyncValue.loading();
      try {
        final repo = ref.read(notesRepositoryProvider);
        final results = await repo.search(term);
        state = AsyncValue.data(results);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const AsyncValue.data(<NoteEntity>[]);
  }
}

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, List<NoteEntity>>(
      SearchController.new,
    );
