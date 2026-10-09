import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/category.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/neu_surface.dart';
import 'categories_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            tooltip: 'Nueva carpeta',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _addCategory(context, ref, isTag: false),
          ),
          IconButton(
            tooltip: 'Nuevo tag',
            icon: const Icon(Icons.label_outline),
            onPressed: () => _addCategory(context, ref, isTag: true),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const _EmptyCategories();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              const _SectionLabel('Carpetas'),
              for (final c in list.where((e) => !e.isTag))
                _CategoryTile(
                  category: c,
                  onEdit: () => _rename(context, ref, c),
                  onDelete: () => _delete(context, ref, c),
                ),
              const SizedBox(height: 16),
              const _SectionLabel('Tags'),
              for (final c in list.where((e) => e.isTag))
                _CategoryTile(
                  category: c,
                  onEdit: () => _rename(context, ref, c),
                  onDelete: () => _delete(context, ref, c),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref, {
    required bool isTag,
  }) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isTag ? 'Nuevo tag' : 'Nueva carpeta'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isTag ? 'Nombre del tag' : 'Nombre de la carpeta',
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
      await ref.read(categoriesRepositoryProvider).create(name, isTag: isTag);
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
      await ref.read(categoriesRepositoryProvider).rename(c.id, name);
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
        title: Text('¿Eliminar ${c.isTag ? 'tag' : 'carpeta'} "${c.name}"?'),
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
      await ref.read(categoriesRepositoryProvider).delete(c.id);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface
              .withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeuSurface(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        onTap: onEdit,
        child: Row(
          children: [
            Icon(
              category.isTag ? Icons.label_outline : Icons.folder_outlined,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text('Aún no hay carpetas ni tags'),
            const SizedBox(height: 6),
            Text(
              'Crea una carpeta para agrupar notas, o un tag para clasificarlas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
