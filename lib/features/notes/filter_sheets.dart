import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../categories/categories_providers.dart';
import 'notes_filter.dart';

Future<void> showFolderFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _FolderFilterSheet(),
  );
}

class _FolderFilterSheet extends ConsumerWidget {
  const _FolderFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersListProvider);
    final current = ref.watch(notesFilterProvider).categoryId;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Filtrar por carpeta',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            _FilterTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Todas las carpetas'),
              selected: current == null,
              onTap: () {
                ref.read(notesFilterProvider.notifier).setCategory(null);
                Navigator.pop(context);
              },
            ),
            foldersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
              data: (folders) {
                if (folders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'No tienes carpetas aún.',
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                }
                final sorted = [...folders]
                  ..sort((a, b) => a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      ));
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final CategoryEntity c in sorted)
                      _FilterTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(c.name),
                        selected: current == c.id,
                        onTap: () {
                          ref
                              .read(notesFilterProvider.notifier)
                              .setCategory(c.id);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAccentFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AccentFilterSheet(),
  );
}

class _AccentFilterSheet extends ConsumerWidget {
  const _AccentFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(notesFilterProvider).accentHex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por color',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _AccentOption(
              label: 'Todos los colores',
              selected: current == null,
              swatch: null,
              onTap: () {
                ref.read(notesFilterProvider.notifier).setAccent(null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _AccentOption(
              label: 'Sin color',
              selected: current == NotesFilter.noAccentSentinel,
              swatch: null,
              empty: true,
              onTap: () {
                ref
                    .read(notesFilterProvider.notifier)
                    .setAccent(NotesFilter.noAccentSentinel);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < AppColors.noteAccents.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Builder(builder: (_) {
                final hex =
                    '#${AppColors.noteAccents[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                return _AccentOption(
                  label: accentLabelFor(hex) ?? 'Color $i',
                  swatch: AppColors.noteAccents[i],
                  selected: current == hex,
                  onTap: () {
                    ref.read(notesFilterProvider.notifier).setAccent(hex);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showPinnedFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _PinnedFilterSheet(),
  );
}

class _PinnedFilterSheet extends ConsumerWidget {
  const _PinnedFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(notesFilterProvider).pinnedOnly;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Filtrar por fijación',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            _FilterTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Todas las notas'),
              selected: !current,
              onTap: () {
                ref.read(notesFilterProvider.notifier).setPinnedOnly(false);
                Navigator.pop(context);
              },
            ),
            _FilterTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Solo fijadas'),
              selected: current,
              onTap: () {
                ref.read(notesFilterProvider.notifier).setPinnedOnly(true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.leading,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final Widget leading;
  final Widget title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListTile(
      leading: leading,
      title: title,
      trailing: selected
          ? Icon(
              Icons.check,
              color: t.colorScheme.onSurface.withValues(alpha: 0.7),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _AccentOption extends StatelessWidget {
  const _AccentOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
    this.empty = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? swatch;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? t.colorScheme.onSurface.withValues(alpha: 0.06)
              : null,
          border: Border.all(
            color: t.colorScheme.onSurface.withValues(
              alpha: selected ? 0.18 : 0.10,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: empty ? Colors.transparent : swatch,
                borderRadius: BorderRadius.circular(8),
                border: empty
                    ? Border.all(
                        color: t.colorScheme.onSurface.withValues(
                          alpha: 0.35,
                        ),
                      )
                    : null,
              ),
              child: empty
                  ? Icon(
                      Icons.block,
                      size: 14,
                      color: t.colorScheme.onSurface.withValues(alpha: 0.55),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                size: 18,
                color: t.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
