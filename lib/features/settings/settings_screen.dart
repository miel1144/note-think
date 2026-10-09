import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/neu_surface.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
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
          const _SectionLabel('Próximamente'),
          const _SettingTile(
            title: 'Bloqueo con biometría',
            subtitle: 'Disponible en una próxima fase',
            leading: Icons.fingerprint,
          ),
          const _SettingTile(
            title: 'Recordatorios',
            subtitle: 'Disponible en una próxima fase',
            leading: Icons.notifications_none,
          ),
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
  });
  final String title;
  final String subtitle;
  final IconData leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeuSurface(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
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
