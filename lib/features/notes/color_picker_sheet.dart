import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/repositories.dart';
import '../../core/db/models/note.dart';
import '../../shared/widgets/neu_surface.dart';

Future<void> showNoteColorPickerSheet(
  BuildContext context,
  WidgetRef ref, {
  required NoteEntity note,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color de la nota',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < AppColors.noteAccents.length; i++) ...[
                    _ColorSwatch(
                      color: AppColors.noteAccents[i],
                      onTap: () {
                        ref
                            .read(notesRepositoryProvider)
                            .setAccent(note.id, i);
                        Navigator.pop(sheetContext);
                      },
                    ),
                    if (i < AppColors.noteAccents.length - 1)
                      const SizedBox(width: 8),
                  ],
                  const SizedBox(width: 8),
                  _RemoveColor(
                    onTap: () {
                      ref
                          .read(notesRepositoryProvider)
                          .setAccent(note.id, null);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: NeuSurface(
          radius: 18,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveColor extends StatelessWidget {
  const _RemoveColor({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: NeuSurface(
          radius: 18,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: const Center(child: Icon(Icons.block, size: 22)),
        ),
      ),
    );
  }
}
