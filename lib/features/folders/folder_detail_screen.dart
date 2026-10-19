import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/neu_surface.dart';
import '../../shared/widgets/note_card.dart';
import '../categories/categories_providers.dart';
import '../notes/notes_providers.dart';
import '../notes/notes_selection.dart';
import '../reminders/reminders_service.dart';
import 'folder_picker_sheet.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  const FolderDetailScreen({super.key, required this.folderId});

  final int folderId;

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  List<int> _visibleNoteIds = const [];

  @override
  Widget build(BuildContext context) {
    final folderAsync = ref.watch(folderByIdProvider(widget.folderId));
    final notesAsync = ref.watch(notesByFolderProvider(widget.folderId));
    final selection = ref.watch(notesSelectionProvider);

    final folderName = folderAsync.maybeWhen(
      data: (f) => f?.name ?? 'Carpeta',
      orElse: () => 'Carpeta',
    );

    return PopScope(
      canPop: !selection.enabled,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(notesSelectionProvider.notifier).exit();
      },
      child: Scaffold(
        appBar: selection.enabled
            ? _buildSelectionAppBar(context, selection)
            : _buildMainAppBar(context, folderAsync, folderName),
        body: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (notes) {
            _visibleNoteIds = notes.map((n) => n.id).toList();
            if (notes.isEmpty) {
              if (selection.enabled) {
                return _SelectionEmptyState(folderName: folderName);
              }
              return _EmptyFolder(folderName: folderName);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              itemCount: notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final n = notes[i];
                return NoteCard(
                  note: n,
                  selected: selection.contains(n.id),
                  onTap: () => _handleTap(context, n),
                  onLongPress: () => _handleLongPress(context, n),
                );
              },
            );
          },
        ),
        bottomNavigationBar: selection.enabled
            ? _SelectionActionBar(
                count: selection.count,
                onMoveToFolder: () => _bulkMoveToFolder(),
                onMoveToTrash: () => _bulkMoveToTrash(),
              )
            : null,
        floatingActionButton: selection.enabled
            ? null
            : FloatingActionButton(
                onPressed: () =>
                    context.push('/edit?folderId=${widget.folderId}'),
                tooltip: 'Nueva nota en esta carpeta',
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildMainAppBar(
    BuildContext context,
    AsyncValue folderAsync,
    String folderName,
  ) {
    return AppBar(
      title: Text(folderName),
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
                  onPressed: () =>
                      _rename(context, ref, f.id, f.name),
                ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    NotesSelectionState selection,
  ) {
    final allSelected =
        _visibleNoteIds.isNotEmpty &&
        _visibleNoteIds.every((id) => selection.contains(id));
    return AppBar(
      leading: IconButton(
        tooltip: 'Salir de selección',
        icon: const Icon(Icons.close),
        onPressed: () =>
            ref.read(notesSelectionProvider.notifier).exit(),
      ),
      title: Text(
        selection.count == 1
            ? '1 seleccionada'
            : '${selection.count} seleccionadas',
      ),
      actions: [
        TextButton.icon(
          onPressed: _visibleNoteIds.isEmpty
              ? null
              : () {
                  final controller =
                      ref.read(notesSelectionProvider.notifier);
                  if (allSelected) {
                    controller.clearSelectionKeepingMode();
                  } else {
                    controller.selectAll(_visibleNoteIds);
                  }
                },
          icon: Icon(
            allSelected
                ? Icons.deselect_outlined
                : Icons.select_all_outlined,
          ),
          label: Text(allSelected ? 'Ninguna' : 'Todas'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _handleTap(BuildContext context, NoteEntity note) {
    final controller = ref.read(notesSelectionProvider.notifier);
    if (ref.read(notesSelectionProvider).enabled) {
      controller.toggle(note.id);
      return;
    }
    context.push('/edit/${note.id}');
  }

  void _handleLongPress(BuildContext context, NoteEntity note) {
    final controller = ref.read(notesSelectionProvider.notifier);
    final selection = ref.read(notesSelectionProvider);
    if (selection.enabled) {
      controller.toggle(note.id);
      return;
    }
    controller.enterWith(note.id);
  }

  Future<void> _bulkMoveToFolder() async {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isEmpty) return;
    if (!mounted) return;
    final picked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.onSurface
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.create_new_folder_outlined),
                title: Text(
                  selection.count == 1
                      ? 'Mover 1 nota a otra carpeta'
                      : 'Mover ${selection.count} notas a otra carpeta',
                ),
                onTap: () => Navigator.pop(sheetContext, true),
              ),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: Text(
                  selection.count == 1
                      ? 'Quitar 1 nota de esta carpeta'
                      : 'Quitar ${selection.count} notas de esta carpeta',
                ),
                onTap: () => Navigator.pop(sheetContext, false),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (picked == null) return;
    if (picked) {
      await showFolderPickerSheet(
        context,
        ref,
        noteIds: selection.selectedIds.toList(),
        currentCategoryId: widget.folderId,
      );
    } else {
      final repo = ref.read(notesRepositoryProvider);
      final count = await repo.setCategoryBulk(
        selection.selectedIds.toList(),
        null,
      );
      ref.read(notesSelectionProvider.notifier).exit();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Sacadas de la carpeta: $count'),
        ),
      );
    }
  }

  Future<void> _bulkMoveToTrash() async {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isEmpty) return;
    final ok = await showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      title: selection.count == 1
          ? '¿Mover 1 nota a papelera?'
          : '¿Mover ${selection.count} notas a papelera?',
      message:
          'Podrás restaurarlas desde la papelera durante 30 días. Pasado ese tiempo se eliminarán definitivamente.',
      confirmLabel: 'Mover',
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(notesRepositoryProvider);
    final ids = selection.selectedIds.toList();
    final notesAsync = ref.read(notesByFolderProvider(widget.folderId));
    final reminderIds = <int>[];
    final notes = notesAsync.value ?? const <NoteEntity>[];
    for (final n in notes) {
      if (ids.contains(n.id) && n.reminderAt != null) {
        reminderIds.add(n.id);
      }
    }
    final moved = await repo.softDeleteBulk(ids);
    for (final id in reminderIds) {
      await RemindersService.instance.cancel(id);
    }
    ref.read(notesSelectionProvider.notifier).exit();
    messenger.showSnackBar(
      SnackBar(content: Text('Movidas a papelera: ${moved.length}')),
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

class _SelectionEmptyState extends StatelessWidget {
  const _SelectionEmptyState({required this.folderName});
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
              Icons.checklist_outlined,
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
              'Sal del modo selección tocando la X de arriba.',
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

class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.count,
    required this.onMoveToFolder,
    required this.onMoveToTrash,
  });
  final int count;
  final VoidCallback onMoveToFolder;
  final VoidCallback onMoveToTrash;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: NeuSurface(
                radius: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onTap: count == 0 ? null : onMoveToFolder,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.create_new_folder_outlined,
                      color: scheme.onSurface,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Carpeta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeuSurface(
                radius: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onTap: count == 0 ? null : onMoveToTrash,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: scheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Papelera',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
