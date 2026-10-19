import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/db/models/note.dart';
import '../../features/private_notes/private_notes_controller.dart';
import '../../features/spotify/spotify_providers.dart';
import 'neu_surface.dart';

class NoteCard extends ConsumerWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.compact = false,
    this.selected = false,
  });

  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final privateState = ref.watch(privateNotesProvider);
    final locked = note.isPrivate && !privateState.isUnlocked;
    final spotifyCount = ref
        .watch(spotifyLinkCountByNoteProvider(note.id))
        .value;
    final hasSpotify = (spotifyCount ?? 0) > 0 && !locked;

    final title = locked ? 'Nota privada' : (note.title.isEmpty ? 'Sin título' : note.title);
    final preview = locked ? '•••••• contenido protegido' : _previewLine(note);
    final accent = locked ? null : AppColors.accentFromHex(note.accentHex);

    return NeuSurface(
      radius: 22,
      padding: compact
          ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
          : const EdgeInsets.fromLTRB(18, 16, 18, 18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          if (accent != null)
            _HeatPoint(color: accent, size: compact ? 80 : 120),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check_circle,
                        size: compact ? 14 : 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (note.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.push_pin,
                        size: compact ? 12 : 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  if (locked)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.lock,
                        size: compact ? 12 : 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  if (note.reminderAt != null && !locked)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        size: compact ? 12 : 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  if (hasSpotify)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.music_note,
                        size: compact ? 12 : 14,
                        color: const Color(0xFF1DB954),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (compact
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        fontStyle: locked ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                preview,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: (compact
                        ? theme.textTheme.bodySmall
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.3,
                ),
              ),
              SizedBox(height: compact ? 6 : 10),
              _DateLine(
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                showEdited: !compact,
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

class _DateLine extends StatelessWidget {
  const _DateLine({
    required this.createdAt,
    required this.updatedAt,
    required this.showEdited,
  });

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool showEdited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
    );
    final created = NoteCard._formatDate(createdAt);
    final updated = NoteCard._formatDate(updatedAt);
    final edited = showEdited && !_sameMinute(createdAt, updatedAt);

    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Creada $created', style: base),
        if (edited) ...[
          Text(
            '·',
            style: base?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          Text('editada $updated', style: base),
        ],
      ],
    );
  }

  static bool _sameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}

class _HeatPoint extends StatelessWidget {
  const _HeatPoint({required this.color, this.size = 120});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: size,
              height: size,
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
