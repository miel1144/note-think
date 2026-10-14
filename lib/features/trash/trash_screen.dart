import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/note_card.dart';
import '../notes/notes_providers.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papelera'),
        actions: [
          trashAsync.maybeWhen(
            data: (notes) => notes.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('¿Vaciar papelera?'),
                          content: const Text(
                            'Se eliminarán todas las notas de la papelera de forma permanente.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('Vaciar'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref.read(notesRepositoryProvider).emptyTrash();
                      }
                    },
                    child: const Text('Vaciar'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: trashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text('La papelera está vacía'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final n = notes[i];
              return Dismissible(
                key: ValueKey('trash-${n.id}'),
                background: Container(),
                onDismissed: (_) async {
                  await ref.read(notesRepositoryProvider).permanentDelete(n.id);
                },
                child: NoteCard(
                  note: n,
                  onTap: () => _showOptions(context, ref, n),
                  onLongPress: () => _showOptions(context, ref, n),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, NoteEntity n) {
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
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restaurar'),
                subtitle: Text(
                  'Borrada el ${DateFormat('dd/MM/yyyy HH:mm').format(n.deletedAt!)}',
                ),
                onTap: () {
                  ref.read(notesRepositoryProvider).restore(n.id);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Eliminar definitivamente'),
                onTap: () {
                  ref.read(notesRepositoryProvider).permanentDelete(n.id);
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
