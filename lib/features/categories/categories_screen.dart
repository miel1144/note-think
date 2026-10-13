import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/category.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/neu_surface.dart';
import 'categories_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpetas'),
        actions: [
          IconButton(
            tooltip: 'Nueva carpeta',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _addFolder(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: foldersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyFolders();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _FolderTile(
              folder: list[i],
              onTap: () => context.push('/folders/${list[i].id}'),
              onRename: () => _rename(context, ref, list[i]),
              onDelete: () => _delete(context, ref, list[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addFolder(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la carpeta',
          ),
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
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(foldersRepositoryProvider).create(name);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity c,
  ) async {
    final ctrl = TextEditingController(text: c.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar'),
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
      await ref.read(foldersRepositoryProvider).rename(c.id, name);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity c,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Eliminar carpeta "${c.name}"?'),
        content: const Text(
          'Las notas dentro de esta carpeta se conservarán, pero dejarán de estar en ella.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(foldersRepositoryProvider).delete(c.id);
    }
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });
  final CategoryEntity folder;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return NeuSurface(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onTap: onTap,
      onLongPress: onRename,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.folder_outlined,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              folder.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Renombrar',
            onPressed: onRename,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Eliminar',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptyFolders extends StatelessWidget {
  const _EmptyFolders();
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
              Icons.folder_outlined,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay carpetas',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Crea una carpeta desde el botón de arriba para agrupar tus notas.',
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
