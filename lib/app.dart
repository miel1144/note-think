import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/private_notes/private_notes_controller.dart';

class NoteThinkApp extends ConsumerStatefulWidget {
  const NoteThinkApp({super.key});

  @override
  ConsumerState<NoteThinkApp> createState() => _NoteThinkAppState();
}

class _NoteThinkAppState extends ConsumerState<NoteThinkApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: _lockPrivate,
      onInactive: _lockPrivate,
      onHide: _lockPrivate,
    );
  }

  void _lockPrivate() {
    ref.read(privateNotesProvider.notifier).lock();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'NoteThink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
    );
  }
}
