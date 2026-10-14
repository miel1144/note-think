import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/isar_service.dart';
import 'core/storage/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.open();
  final container = ProviderContainer();
  await container.read(notesRepositoryProvider).purgeExpiredTrash();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NoteThinkApp(),
    ),
  );
}
