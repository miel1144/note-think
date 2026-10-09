import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.open();
  runApp(const ProviderScope(child: NoteThinkApp()));
}
