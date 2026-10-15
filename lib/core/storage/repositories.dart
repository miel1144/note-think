import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/isar_service.dart';
import '../storage/categories_repository.dart';
import '../storage/notes_repository.dart';
import '../../features/spotify/spotify_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(IsarService.instance.isar),
);

final foldersRepositoryProvider = Provider<FoldersRepository>(
  (ref) => FoldersRepository(
    IsarService.instance.isar,
    ref.watch(notesRepositoryProvider),
  ),
);

final spotifyRepositoryProvider = Provider<SpotifyRepository>(
  (ref) => SpotifyRepository(IsarService.instance.isar),
);
