import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/repositories.dart';
import '../../shared/widgets/note_card.dart';
import '../categories/categories_providers.dart';
import '../notes/notes_providers.dart';

class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({super.key, required this.folderId});

  final int folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderAsync = ref.watch(folderByIdProvider(folderId));
    final notesAsync = ref.watch(notesByFolderProvider(folderId));

    final title = folderAsync.maybeWhen(
      data: (f) => f?.name ?? 'Carpeta',
      orElse: () => 'Carpeta',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          folderAsync.maybeWhen(
            data: (f) => f == null
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Renombrar',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _rename(context, ref, f.id, f.name),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (notes.isEmpty) return _EmptyFolder(folderName: title);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => NoteCard(
              note: notes[i],
              onTap: () => context.push('/edit/${notes[i].id}'),
              onLongPress: () => _showNoteActions(context, ref, notes[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit?folderId=$folderId'),
        tooltip: 'Nueva nota en esta carpeta',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    int id,
    String currentName,
  ) async {
    final ctrl = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar carpeta'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(foldersRepositoryProvider).rename(id, name);
    }
  }

  void _showNoteActions(BuildContext context, WidgetRef ref, note) {
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
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('Quitar de esta carpeta'),
                onTap: () {
                  ref
                      .read(notesRepositoryProvider)
                      .setCategory(note.id, null);
                  Navigator.pop(sheetContext);
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
}

class _EmptyFolder extends StatelessWidget {
  const _EmptyFolder({required this.folderName});
  final String folderName;

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
              Icons.folder_open,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Sin notas en "$folderName"',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca el botón + para crear una nota dentro de esta carpeta.',
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
