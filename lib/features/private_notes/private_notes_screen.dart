import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/neu_surface.dart';
import '../../shared/widgets/note_card.dart';
import '../notes/note_share.dart';
import '../notes/notes_providers.dart';
import '../private_notes/password_dialog.dart';
import '../private_notes/private_notes_controller.dart';
import '../reminders/reminder_picker.dart';
import '../reminders/reminders_service.dart';

class PrivateNotesScreen extends ConsumerWidget {
  const PrivateNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privateState = ref.watch(privateNotesProvider);
    final hasPassword = privateState.hasPassword;
    final isUnlocked = privateState.isUnlocked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privadas'),
        actions: [
          if (hasPassword && isUnlocked)
            IconButton(
              tooltip: 'Bloquear',
              icon: const Icon(Icons.lock_outline),
              onPressed: () {
                ref.read(privateNotesProvider.notifier).lock();
              },
            ),
        ],
      ),
      body: !hasPassword
          ? const _NoPasswordState()
          : !isUnlocked
              ? const _LockedState()
              : const _PrivateList(),
    );
  }
}

class _NoPasswordState extends StatelessWidget {
  const _NoPasswordState();

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
              Icons.lock_open,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin notas privadas',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Activa la protección en Ajustes para empezar a guardar notas privadas.',
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
              onTap: () => context.push('/settings'),
              child: const Text(
                'Ir a Ajustes',
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

class _LockedState extends ConsumerWidget {
  const _LockedState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 72,
              color: t.colorScheme.onSurface.withValues(alpha: 0.40),
            ),
            const SizedBox(height: 16),
            Text(
              'Notas privadas bloqueadas',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Introduce la palabra clave para verlas.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            NeuSurface(
              radius: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await showPasswordDialog(
                  context,
                  ref,
                  mode: PasswordDialogMode.verify,
                );
                if (!context.mounted) return;
                if (!result.success && result.message != null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(result.message!)),
                  );
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_open, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Desbloquear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateList extends ConsumerWidget {
  const _PrivateList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(privateNotesListProvider);
    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        if (notes.isEmpty) {
          return const _EmptyPrivate();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => NoteCard(
            note: notes[i],
            onTap: () => context.push('/edit/${notes[i].id}'),
            onLongPress: () => _showActions(context, ref, notes[i]),
          ),
        );
      },
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, NoteEntity note) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(note.pinned ? 'Desfijar' : 'Fijar'),
                onTap: () {
                  ref.read(notesRepositoryProvider).togglePin(note.id);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Cambiar color'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickColor(context, ref, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Compartir'),
                onTap: () {
                  final box = sheetContext.findRenderObject() as RenderBox?;
                  Navigator.pop(sheetContext);
                  NoteShare.share(
                    context,
                    note,
                    sharePositionOrigin: box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text('Quitar de privadas'),
                onTap: () {
                  ref
                      .read(notesRepositoryProvider)
                      .setPrivate(note.id, false);
                  Navigator.pop(sheetContext);
                },
              ),
              if (note.reminderAt == null)
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Programar recordatorio'),
                  subtitle: const Text(
                    'La notificación no mostrará el título',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final granted =
                        await RemindersService.instance.requestPermission();
                    if (!granted) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Se necesita permiso de notificaciones',
                          ),
                        ),
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    final when = await showReminderPicker(context);
                    if (when == null) return;
                    await ref
                        .read(notesRepositoryProvider)
                        .setReminder(note.id, when);
                    await RemindersService.instance.schedule(
                      noteId: note.id,
                      when: when,
                      title: '',
                      body: '',
                      isPrivate: true,
                    );
                  },
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Cambiar recordatorio'),
                      subtitle: Text(formatReminder(note.reminderAt!)),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final when = await showReminderPicker(context);
                        if (when == null) return;
                        await ref
                            .read(notesRepositoryProvider)
                            .setReminder(note.id, when);
                        await RemindersService.instance.cancel(note.id);
                        await RemindersService.instance.schedule(
                          noteId: note.id,
                          when: when,
                          title: '',
                          body: '',
                          isPrivate: true,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_off_outlined),
                      title: const Text('Quitar recordatorio'),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await ref
                            .read(notesRepositoryProvider)
                            .setReminder(note.id, null);
                        await RemindersService.instance.cancel(note.id);
                      },
                    ),
                  ],
                ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Eliminar definitivamente'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await showConfirmDialog(
                    context,
                    icon: Icons.delete_forever,
                    title: '¿Eliminar nota privada?',
                    message:
                        'Esta nota se borrará para siempre. No se puede recuperar.',
                    confirmLabel: 'Eliminar',
                    destructive: true,
                  );
                  if (ok) {
                    await ref
                        .read(notesRepositoryProvider)
                        .permanentDelete(note.id);
                    await RemindersService.instance.cancel(note.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickColor(BuildContext context, WidgetRef ref, NoteEntity note) {
    showModalBottomSheet<void>(
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

class _EmptyPrivate extends StatelessWidget {
  const _EmptyPrivate();

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
              Icons.lock_outline,
              size: 64,
              color: t.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin notas privadas',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Marca cualquier nota como privada desde su menú para que aparezca aquí.',
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
