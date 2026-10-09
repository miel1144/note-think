import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/neu_surface.dart';
import '../../shared/widgets/note_card.dart';
import '../notes/notes_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchControllerProvider.notifier).query('');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    ref.read(searchControllerProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) =>
              ref.read(searchControllerProvider.notifier).query(v),
          decoration: const InputDecoration(
            hintText: 'Buscar en tus notas...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            NeuIconButton(
              icon: Icons.close,
              tooltip: 'Limpiar',
              onPressed: () {
                _ctrl.clear();
                ref.read(searchControllerProvider.notifier).query('');
                setState(() {});
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (_ctrl.text.trim().isEmpty) {
            return const _Hint();
          }
          if (list.isEmpty) {
            return const Center(child: Text('Sin resultados'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => NoteCard(
              note: list[i],
              onTap: () => context.push('/edit/${list[i].id}'),
            ),
          );
        },
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Escribe para buscar en los títulos y el contenido de tus notas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
