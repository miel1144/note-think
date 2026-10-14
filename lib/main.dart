import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/isar_service.dart';
import 'core/storage/repositories.dart';
import 'features/private_notes/private_notes_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.open();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  await container.read(notesRepositoryProvider).purgeExpiredTrash();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NoteThinkApp(),
    ),
  );
}
