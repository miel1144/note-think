import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/neu_surface.dart';
import '../private_notes/password_dialog.dart';
import '../private_notes/private_notes_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final privateState = ref.watch(privateNotesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionLabel('Apariencia'),
          _SettingTile(
            title: 'Tema',
            subtitle: _modeLabel(mode),
            leading: Icons.contrast,
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Notas privadas'),
          _PrivateNotesTile(state: privateState),
          const SizedBox(height: 24),
          const _SectionLabel('Próximamente'),
          const _SettingTile(
            title: 'Exportar a PDF',
            subtitle: 'Disponible en una próxima fase',
            leading: Icons.picture_as_pdf_outlined,
          ),
        ],
      ),
    );
  }

  String _modeLabel(ThemeMode m) => switch (m) {
    ThemeMode.system => 'Sigue al sistema',
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Oscuro',
  };
}

class _PrivateNotesTile extends ConsumerWidget {
  const _PrivateNotesTile({required this.state});
  final PrivateNotesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    if (!state.hasPassword) {
      return _SettingTile(
        title: 'Activar notas privadas',
        subtitle:
            'Establece una palabra clave para proteger notas individualmente',
        leading: Icons.lock_outline,
        onTap: () async {
          final result = await showPasswordDialog(
            context,
            ref,
            mode: PasswordDialogMode.set,
          );
          if (!context.mounted) return;
          if (result.success) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Notas privadas activadas')),
            );
          }
        },
      );
    }
    return Column(
      children: [
        _SettingTile(
          title: 'Notas privadas',
          subtitle: state.isUnlocked
              ? 'Activadas · sesión desbloqueada'
              : 'Activadas · pulsa para desbloquear',
          leading: state.isUnlocked ? Icons.lock_open : Icons.lock,
          onTap: () async {
            if (state.isUnlocked) {
              context.push('/private');
              return;
            }
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
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
        if (state.isUnlocked) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/private'),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver notas privadas'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(privateNotesProvider.notifier).lock();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Sesión bloqueada')),
                  );
                },
                icon: const Icon(Icons.lock, size: 16),
                label: const Text('Bloquear'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await showPasswordDialog(
                    context,
                    ref,
                    mode: PasswordDialogMode.change,
                  );
                  if (!context.mounted) return;
                  if (result.success) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Palabra clave actualizada'),
                      ),
                    );
                  } else if (result.message != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(result.message!)),
                    );
                  }
                },
                icon: const Icon(Icons.key, size: 16),
                label: const Text('Cambiar clave'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await showPasswordDialog(
                    context,
                    ref,
                    mode: PasswordDialogMode.verify,
                    title: 'Quitar notas privadas',
                  );
                  if (!context.mounted) return;
                  if (result.success) {
                    ref
                        .read(privateNotesProvider.notifier)
                        .removeAfterVerified();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Notas privadas desactivadas'),
                      ),
                    );
                  } else if (result.message != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(result.message!)),
                    );
                  }
                },
                icon: const Icon(Icons.lock_open, size: 16),
                label: const Text('Desactivar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
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

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeuSurface(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              leading,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
