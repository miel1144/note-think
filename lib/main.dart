import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/isar_service.dart';
import 'core/storage/repositories.dart';
import 'features/private_notes/private_notes_controller.dart';
import 'features/reminders/reminders_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.open();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  final purgedIds = await container
      .read(notesRepositoryProvider)
      .purgeExpiredTrash();
  final spotify = container.read(spotifyRepositoryProvider);
  for (final id in purgedIds) {
    await spotify.removeAllForNote(id);
  }
  await RemindersService.instance.init();
  final activeReminders =
      await container.read(notesRepositoryProvider).getActiveWithReminders();
  for (final note in activeReminders) {
    final when = note.reminderAt;
    if (when == null) continue;
    final title = note.title.trim().isEmpty ? 'Recordatorio' : note.title.trim();
    final body = RemindersService.instance.firstBodyLine(note.bodyPlain);
    await RemindersService.instance.schedule(
      noteId: note.id,
      when: when,
      title: title,
      body: body,
      isPrivate: note.isPrivate,
    );
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NoteThinkApp(),
    ),
  );
}
