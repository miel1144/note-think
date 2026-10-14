import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../categories/categories_providers.dart';
import 'filter_sheets.dart';
import 'notes_filter.dart';
import 'notes_sort.dart';
import 'sort_sheet.dart';

class NotesFilterBar extends ConsumerWidget {
  const NotesFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notesFilterProvider);
    final foldersAsync = ref.watch(foldersListProvider);
    final folderName = _folderName(foldersAsync.value, filter.categoryId);
    final sort = ref.watch(notesSortProvider).value ?? NotesSort.defaultSort;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            icon: Icons.folder_outlined,
            label: folderName ?? 'Carpeta',
            active: filter.categoryId != null,
            onTap: () => showFolderFilterSheet(context, ref),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: Icons.palette_outlined,
            label: filter.accentHex == null
                ? 'Color'
                : (filter.accentHex == NotesFilter.noAccentSentinel
                    ? 'Sin color'
                    : (accentLabelFor(filter.accentHex) ?? 'Color')),
            active: filter.accentHex != null,
            swatch: filter.accentHex == null ||
                    filter.accentHex == NotesFilter.noAccentSentinel
                ? null
                : AppColors.accentFromHex(filter.accentHex),
            emptySwatch:
                filter.accentHex == NotesFilter.noAccentSentinel,
            onTap: () => showAccentFilterSheet(context, ref),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: filter.pinnedOnly
                ? Icons.push_pin
                : Icons.push_pin_outlined,
            label: 'Fijadas',
            active: filter.pinnedOnly,
            onTap: () => showPinnedFilterSheet(context, ref),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: _sortIcon(sort),
            label: sort.shortLabel,
            active: !sort.isDefault,
            onTap: () => showSortSheet(context, ref),
          ),
          if (filter.hasAny) ...[
            const SizedBox(width: 8),
            _ClearChip(
              onTap: () =>
                  ref.read(notesFilterProvider.notifier).clear(),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  IconData _sortIcon(NotesSort sort) {
    switch (sort.field) {
      case NotesSortField.modified:
        return sort.direction == NotesSortDirection.desc
            ? Icons.history
            : Icons.history_toggle_off;
      case NotesSortField.created:
        return Icons.event_outlined;
      case NotesSortField.title:
        return Icons.sort_by_alpha;
      case NotesSortField.color:
        return Icons.palette_outlined;
    }
  }

  String? _folderName(List<dynamic>? folders, int? id) {
    if (id == null || folders == null) return null;
    for (final c in folders) {
      if (c.id == id) return c.name as String;
    }
    return null;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.swatch,
    this.emptySwatch = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? swatch;
  final bool emptySwatch;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bg = active
        ? t.colorScheme.onSurface.withValues(alpha: 0.08)
        : t.scaffoldBackgroundColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.colorScheme.onSurface.withValues(
                alpha: active ? 0.20 : 0.10,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatch != null || emptySwatch) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: emptySwatch ? Colors.transparent : swatch,
                    borderRadius: BorderRadius.circular(4),
                    border: emptySwatch
                        ? Border.all(
                            color: t.colorScheme.onSurface.withValues(
                              alpha: 0.45,
                            ),
                            width: 1.2,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Icon(icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 16,
                color: t.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearChip extends StatelessWidget {
  const _ClearChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.colorScheme.onSurface.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                size: 14,
                color: t.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Limpiar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: t.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
