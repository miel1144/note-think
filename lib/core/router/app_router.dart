import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/categories_screen.dart';
import '../../features/folders/folder_detail_screen.dart';
import '../../features/notes/editor_screen.dart';
import '../../features/notes/notes_list_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/trash/trash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNav(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: NotesListScreen()),
          ),
          GoRoute(
            path: '/folders',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: CategoriesScreen()),
          ),
          GoRoute(
            path: '/trash',
            pageBuilder: (_, _) => const NoTransitionPage(child: TrashScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => EditorScreen(
          folderId: int.tryParse(state.uri.queryParameters['folderId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => EditorScreen(
          noteId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/folders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => FolderDetailScreen(
          folderId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
});

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child, required this.location});
  final Widget child;
  final String location;

  int get _index {
    if (location.startsWith('/folders')) return 1;
    if (location.startsWith('/trash')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/folders');
              break;
            case 2:
              context.go('/trash');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            activeIcon: Icon(Icons.sticky_note_2),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Carpetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline),
            activeIcon: Icon(Icons.delete),
            label: 'Papelera',
          ),
        ],
      ),
    );
  }
}
