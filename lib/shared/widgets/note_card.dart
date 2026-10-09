import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/db/models/note.dart';
import 'neu_surface.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.accentFromHex(note.accentHex);
    final title = note.title.isEmpty ? 'Sin título' : note.title;
    final preview = _previewLine(note);

    return NeuSurface(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          if (accent != null) _HeatPoint(color: accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (note.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _previewLine(NoteEntity n) {
    for (final line in n.bodyPlain) {
      final t = line.trim();
      if (t.isNotEmpty) return t;
    }
    return 'Nota vacía';
  }

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _HeatPoint extends StatelessWidget {
  const _HeatPoint({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 0.95,
                  colors: [color, color.withValues(alpha: 0.0)],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
