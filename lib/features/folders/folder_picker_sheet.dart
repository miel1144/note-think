import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../core/db/models/category.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/neu_surface.dart';
import '../categories/categories_providers.dart';

Future<void> showFolderPickerSheet(
  BuildContext context,
  WidgetRef ref, {
  required int noteId,
  int? currentCategoryId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _FolderPickerSheet(
      noteId: noteId,
      currentCategoryId: currentCategoryId,
    ),
  );
}

class _FolderPickerSheet extends ConsumerStatefulWidget {
  const _FolderPickerSheet({
    required this.noteId,
    required this.currentCategoryId,
  });
  final int noteId;
  final int? currentCategoryId;

  @override
  ConsumerState<_FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends ConsumerState<_FolderPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(foldersListProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Agregar a carpeta',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeuSurface(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar carpeta...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: foldersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (list) {
                    final filtered = _filter(list, _query);
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filtered.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _NewFolderTile(
                            query: _query,
                            onCreate: () => _createAndAssign(context),
                          );
                        }
                        final f = filtered[i - 1];
                        return _FolderRow(
                          folder: f,
                          selected: f.id == widget.currentCategoryId,
                          onTap: () => _assign(context, f.id),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  List<CategoryEntity> _filter(List<CategoryEntity> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((c) => c.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _createAndAssign(BuildContext context) async {
    final suggested = _query.trim();
    final name = suggested.isEmpty
        ? await _promptForName(context)
        : suggested;
    if (name == null || name.isEmpty) return;
    final repo = ref.read(foldersRepositoryProvider);
    final notes = ref.read(notesRepositoryProvider);
    final newId = await repo.create(name);
    if (newId == Isar.autoIncrement) return;
    await notes.setCategory(widget.noteId, newId);
    if (context.mounted) Navigator.pop(context);
  }

  Future<String?> _promptForName(BuildContext context) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre'),
          onSubmitted: (v) => Navigator.pop(dialogContext, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _assign(BuildContext context, int folderId) async {
    await ref
        .read(notesRepositoryProvider)
        .setCategory(widget.noteId, folderId);
    if (context.mounted) Navigator.pop(context);
  }
}

class _NewFolderTile extends StatelessWidget {
  const _NewFolderTile({required this.query, required this.onCreate});
  final String query;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final background = theme.scaffoldBackgroundColor;
    return NeuSurface(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onCreate,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: background,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              query.trim().isEmpty
                  ? 'Crear nueva carpeta'
                  : 'Crear "${query.trim()}"',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.folder,
    required this.selected,
    required this.onTap,
  });
  final CategoryEntity folder;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final background = theme.scaffoldBackgroundColor;
    return NeuSurface(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? text : text.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selected ? Icons.check : Icons.folder_outlined,
              color: selected ? background : text.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              folder.name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
