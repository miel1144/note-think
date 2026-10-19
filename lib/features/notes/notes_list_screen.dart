import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/repositories.dart';
import '../../core/db/models/note.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/neu_surface.dart';
import '../../shared/widgets/note_card.dart';
import '../folders/folder_picker_sheet.dart';
import '../reminders/reminders_service.dart';
import 'filter_bar.dart';
import 'notes_filter.dart';
import 'notes_layout.dart';
import 'notes_providers.dart';
import 'notes_selection.dart';
import 'notes_sort.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  List<int> _visibleNoteIds = const [];

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(displayedNotesProvider);
    final filter = ref.watch(notesFilterProvider);
    final layout = ref.watch(notesLayoutProvider).value ?? NotesLayout.list;
    final selection = ref.watch(notesSelectionProvider);

    return PopScope(
      canPop: !selection.enabled,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(notesSelectionProvider.notifier).exit();
      },
      child: Scaffold(
        appBar: selection.enabled
            ? _buildSelectionAppBar(context, selection)
            : _buildMainAppBar(context, layout),
        body: Column(
          children: [
            const NotesFilterBar(),
            Expanded(
              child: notesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (notes) {
                  _visibleNoteIds = notes.map((n) => n.id).toList();
                  if (notes.isEmpty) {
                    if (selection.enabled) {
                      return const _SelectionEmptyState();
                    }
                    return filter.hasAny
                        ? _EmptyFilteredState(
                            onClear: () => ref
                                .read(notesFilterProvider.notifier)
                                .clear(),
                          )
                        : const _EmptyState();
                  }
                  if (layout == NotesLayout.grid) {
                    return _NotesGrid(
                      notes: notes,
                      selection: selection,
                      onTap: (n) => _handleTap(n),
                      onLongPress: (n) => _handleLongPress(n),
                    );
                  }
                  return _NotesList(
                    notes: notes,
                    selection: selection,
                    onTap: (n) => _handleTap(n),
                    onLongPress: (n) => _handleLongPress(n),
                    onSwipeDelete: !selection.enabled
                        ? (n) async {
                            await ref
                                .read(notesRepositoryProvider)
                                .softDelete(n.id);
                            if (n.reminderAt != null) {
                              await RemindersService.instance.cancel(n.id);
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
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
                onPressed: () => context.push('/edit'),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildMainAppBar(BuildContext context, NotesLayout layout) {
    return AppBar(
      title: const Text('NoteThink'),
      actions: [
        NeuIconButton(
          icon: Icons.search,
          tooltip: 'Buscar',
          onPressed: () => context.push('/search'),
        ),
        const SizedBox(width: 6),
        NeuIconButton(
          icon: layout == NotesLayout.list
              ? Icons.grid_view_outlined
              : Icons.view_agenda_outlined,
          tooltip: layout == NotesLayout.list
              ? 'Vista en cuadrícula'
              : 'Vista en lista',
          onPressed: () =>
              ref.read(notesLayoutProvider.notifier).toggle(),
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

  void _handleTap(NoteEntity note) {
    final controller = ref.read(notesSelectionProvider.notifier);
    if (ref.read(notesSelectionProvider).enabled) {
      controller.toggle(note.id);
      return;
    }
    context.push('/edit/${note.id}');
  }

  void _handleLongPress(NoteEntity note) {
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
    final messenger = ScaffoldMessenger.of(context);
    final picked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.create_new_folder_outlined),
                title: Text(
                  selection.count == 1
                      ? 'Mover 1 nota a carpeta'
                      : 'Mover ${selection.count} notas a carpeta',
                ),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: Text(
                  selection.count == 1
                      ? 'Quitar 1 nota de carpeta'
                      : 'Quitar ${selection.count} notas de carpeta',
                ),
                onTap: () => Navigator.pop(context, false),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (picked == null) return;
    if (picked) {
      // Refresh the current category id guess for the picker (use first
      // selected note's folder as the "current" marker — if all share it).
      final notes = ref.read(notesListProvider).value ?? const <NoteEntity>[];
      final ids = selection.selectedIds;
      final selectedNotes =
          notes.where((n) => ids.contains(n.id)).toList();
      final folders = selectedNotes
          .map((n) => n.categoryId)
          .toSet();
      final sharedCategory = folders.length == 1 ? folders.first : null;
      await showFolderPickerSheet(
        context,
        ref,
        noteIds: selection.selectedIds.toList(),
        currentCategoryId: sharedCategory,
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
          content: Text(
            'Sacadas de carpeta: $count',
          ),
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
    final notes = ref.read(notesListProvider).value ?? const <NoteEntity>[];
    final reminderIds = <int>[];
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

class _EmptyFilteredState extends StatelessWidget {
  const _EmptyFilteredState({required this.onClear});
  final VoidCallback onClear;
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
              Icons.filter_alt_off_outlined,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin coincidencias',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No hay notas que coincidan con los filtros activos.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            NeuSurface(
              radius: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              onTap: onClear,
              child: const Text(
                'Limpiar filtros',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
    required this.selection,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeDelete,
  });

  final List<NoteEntity> notes;
  final NotesSelectionState selection;
  final void Function(NoteEntity) onTap;
  final void Function(NoteEntity) onLongPress;
  final Future<void> Function(NoteEntity)? onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget card(NoteEntity n) => NoteCard(
      note: n,
      selected: selection.contains(n.id),
      onTap: () => onTap(n),
      onLongPress: () => onLongPress(n),
    );
    if (onSwipeDelete == null) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: notes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => card(notes[i]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final n = notes[i];
        return Dismissible(
          key: ValueKey('note-${n.id}'),
          direction: DismissDirection.endToStart,
          background: const SizedBox.shrink(),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline, color: scheme.error),
                const SizedBox(width: 8),
                Text(
                  'Mover a papelera',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            return showConfirmDialog(
              context,
              icon: Icons.delete_outline,
              title: '¿Mover a papelera?',
              message:
                  'Podrás restaurarla desde la papelera durante 30 días. Pasado ese tiempo se eliminará definitivamente.',
              confirmLabel: 'Mover',
            );
          },
          onDismissed: (_) => onSwipeDelete!(n),
          child: card(n),
        );
      },
    );
  }
}

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({
    required this.notes,
    required this.selection,
    required this.onTap,
    required this.onLongPress,
  });

  final List<NoteEntity> notes;
  final NotesSelectionState selection;
  final void Function(NoteEntity) onTap;
  final void Function(NoteEntity) onLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: notes.length,
      itemBuilder: (_, i) => NoteCard(
        note: notes[i],
        compact: true,
        selected: selection.contains(notes[i].id),
        onTap: () => onTap(notes[i]),
        onLongPress: () => onLongPress(notes[i]),
      ),
    );
  }
}

class _SelectionEmptyState extends StatelessWidget {
  const _SelectionEmptyState();
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
              'No hay notas para seleccionar',
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
