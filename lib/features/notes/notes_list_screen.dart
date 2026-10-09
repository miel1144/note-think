import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/repositories.dart';
import '../../core/db/models/note.dart';
import '../../shared/widgets/neu_surface.dart';
import '../../shared/widgets/note_card.dart';
import 'notes_providers.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteThink'),
        actions: [
          NeuIconButton(
            icon: Icons.search,
            tooltip: 'Buscar',
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            tooltip: 'Más',
            icon: const Icon(Icons.more_horiz),
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'settings') context.push('/settings');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Ajustes')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (notes.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => NoteCard(
              note: notes[i],
              onTap: () => context.push('/edit/${notes[i].id}'),
              onLongPress: () => _showActions(context, ref, notes[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, NoteEntity note) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(note.pinned ? 'Desfijar' : 'Fijar'),
                onTap: () {
                  ref.read(notesRepositoryProvider).togglePin(note.id);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Cambiar color'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickColor(context, ref, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Mover a papelera'),
                onTap: () {
                  ref.read(notesRepositoryProvider).softDelete(note.id);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickColor(BuildContext context, WidgetRef ref, NoteEntity note) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Color de la nota',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < AppColors.noteAccents.length; i++) ...[
                      _ColorSwatch(
                        color: AppColors.noteAccents[i],
                        onTap: () {
                          ref
                              .read(notesRepositoryProvider)
                              .setAccent(note.id, i);
                          Navigator.pop(sheetContext);
                        },
                      ),
                      if (i < AppColors.noteAccents.length - 1)
                        const SizedBox(width: 8),
                    ],
                    const SizedBox(width: 8),
                    _RemoveColor(
                      onTap: () {
                        ref
                            .read(notesRepositoryProvider)
                            .setAccent(note.id, null);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: NeuSurface(
          radius: 18,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveColor extends StatelessWidget {
  const _RemoveColor({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: NeuSurface(
          radius: 18,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: const Center(child: Icon(Icons.block, size: 22)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_note,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay notas',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca el botón + para crear tu primera nota.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
