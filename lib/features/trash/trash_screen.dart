import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/note_card.dart';
import '../notes/notes_providers.dart';
import '../reminders/reminders_service.dart';

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
                      final ok = await showConfirmDialog(
                        context,
                        icon: Icons.delete_forever,
                        title: '¿Vaciar papelera?',
                        message:
                            'Se eliminarán ${notes.length} ${notes.length == 1 ? "nota" : "notas"} de forma permanente. Esta acción no se puede deshacer.',
                        confirmLabel: 'Vaciar',
                        destructive: true,
                      );
                      if (ok) {
                        final ids = await ref
                            .read(notesRepositoryProvider)
                            .emptyTrash();
                        for (final id in ids) {
                          await ref
                              .read(spotifyRepositoryProvider)
                              .removeAllForNote(id);
                        }
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
            itemBuilder: (itemContext, i) {
              final n = notes[i];
              return Dismissible(
                key: ValueKey('trash-${n.id}'),
                background: _swipeBg(
                  itemContext,
                  align: Alignment.centerLeft,
                  icon: Icons.delete_forever,
                ),
                secondaryBackground: _swipeBg(
                  itemContext,
                  align: Alignment.centerRight,
                  icon: Icons.delete_forever,
                ),
                confirmDismiss: (_) async {
                  return showConfirmDialog(
                    itemContext,
                    icon: Icons.delete_forever,
                    title: '¿Eliminar definitivamente?',
                    message:
                        'Esta nota se borrará para siempre y no se puede recuperar.',
                    confirmLabel: 'Eliminar',
                    destructive: true,
                  );
                },
                onDismissed: (_) async {
                  await ref
                      .read(spotifyRepositoryProvider)
                      .removeAllForNote(n.id);
                  await ref
                      .read(notesRepositoryProvider)
                      .permanentDelete(n.id);
                  await RemindersService.instance.cancel(n.id);
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

  Widget _swipeBg(
    BuildContext ctx, {
    required Alignment align,
    required IconData icon,
  }) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: scheme.error),
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
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Eliminar definitivamente'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await showConfirmDialog(
                    context,
                    icon: Icons.delete_forever,
                    title: '¿Eliminar definitivamente?',
                    message:
                        'Esta nota se borrará para siempre y no se puede recuperar.',
                    confirmLabel: 'Eliminar',
                    destructive: true,
                  );
                  if (ok) {
                    await ref
                        .read(spotifyRepositoryProvider)
                        .removeAllForNote(n.id);
                    await ref
                        .read(notesRepositoryProvider)
                        .permanentDelete(n.id);
                    await RemindersService.instance.cancel(n.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
