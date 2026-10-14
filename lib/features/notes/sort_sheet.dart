import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notes_sort.dart';

Future<void> showSortSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _SortSheet(),
  );
}

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(notesSortProvider).value ?? NotesSort.defaultSort;
    final t = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Ordenar notas',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'POR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            _FieldOption(
              icon: Icons.edit_calendar_outlined,
              label: 'Modificación',
              hint: 'Fecha de última edición',
              selected: sort.field == NotesSortField.modified,
              onTap: () {
                ref
                    .read(notesSortProvider.notifier)
                    .setField(NotesSortField.modified);
              },
            ),
            _FieldOption(
              icon: Icons.event_outlined,
              label: 'Creación',
              hint: 'Fecha en que se creó la nota',
              selected: sort.field == NotesSortField.created,
              onTap: () {
                ref
                    .read(notesSortProvider.notifier)
                    .setField(NotesSortField.created);
              },
            ),
            _FieldOption(
              icon: Icons.sort_by_alpha,
              label: 'Título',
              hint: 'Orden alfabético',
              selected: sort.field == NotesSortField.title,
              onTap: () {
                ref
                    .read(notesSortProvider.notifier)
                    .setField(NotesSortField.title);
              },
            ),
            _FieldOption(
              icon: Icons.palette_outlined,
              label: 'Color',
              hint: 'Por color de acento (sin color al final)',
              selected: sort.field == NotesSortField.color,
              onTap: () {
                ref
                    .read(notesSortProvider.notifier)
                    .setField(NotesSortField.color);
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'DIRECCIÓN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DirectionSegment(
                        icon: Icons.arrow_upward,
                        label: 'Ascendente',
                        selected:
                            sort.direction == NotesSortDirection.asc,
                        onTap: () {
                          ref
                              .read(notesSortProvider.notifier)
                              .setDirection(NotesSortDirection.asc);
                        },
                      ),
                    ),
                    Expanded(
                      child: _DirectionSegment(
                        icon: Icons.arrow_downward,
                        label: 'Descendente',
                        selected:
                            sort.direction == NotesSortDirection.desc,
                        onTap: () {
                          ref
                              .read(notesSortProvider.notifier)
                              .setDirection(NotesSortDirection.desc);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!sort.isDefault) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(notesSortProvider.notifier).reset();
                },
                child: const Text('Restablecer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldOption extends StatelessWidget {
  const _FieldOption({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: t.colorScheme.onSurface.withValues(
                alpha: selected ? 0.9 : 0.65,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 11,
                      color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
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

class _DirectionSegment extends StatelessWidget {
  const _DirectionSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? t.colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: t.brightness == Brightness.dark ? 0.30 : 0.08,
                      ),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: t.colorScheme.onSurface.withValues(
                  alpha: selected ? 0.9 : 0.55,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
