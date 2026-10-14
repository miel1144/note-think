import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'private_notes_controller.dart';

enum PasswordDialogMode { set, change, verify }

class PasswordDialogResult {
  const PasswordDialogResult({required this.success, this.message});
  final bool success;
  final String? message;
}

Future<PasswordDialogResult> showPasswordDialog(
  BuildContext context,
  WidgetRef ref, {
  required PasswordDialogMode mode,
  String? title,
}) async {
  final isSet = mode == PasswordDialogMode.set;
  final isChange = mode == PasswordDialogMode.change;
  final isVerify = mode == PasswordDialogMode.verify;

  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final currentCtrl = TextEditingController();

  final result = await showDialog<PasswordDialogResult>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(Icons.lock_outline),
        title: Text(
          title ??
              switch (mode) {
                PasswordDialogMode.set => 'Activar notas privadas',
                PasswordDialogMode.change => 'Cambiar palabra clave',
                PasswordDialogMode.verify => 'Notas privadas',
              },
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isChange || isVerify) ...[
              TextField(
                controller: currentCtrl,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Palabra clave actual',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: newCtrl,
              obscureText: true,
              autofocus: !isChange && !isVerify,
              decoration: InputDecoration(
                labelText: isVerify ? 'Palabra clave' : 'Nueva palabra clave',
                helperText: isSet ? 'Mínimo 4 caracteres' : null,
              ),
            ),
            if (isSet || isChange) ...[
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repetir palabra clave',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              const PasswordDialogResult(success: false),
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final newPwd = newCtrl.text;
              if (isSet || isChange) {
                if (newPwd.length < 4) {
                  Navigator.pop(
                    dialogContext,
                    const PasswordDialogResult(
                      success: false,
                      message: 'Mínimo 4 caracteres',
                    ),
                  );
                  return;
                }
                if (newPwd != confirmCtrl.text) {
                  Navigator.pop(
                    dialogContext,
                    const PasswordDialogResult(
                      success: false,
                      message: 'No coinciden',
                    ),
                  );
                  return;
                }
              }
              final notifier = ref.read(privateNotesProvider.notifier);
              if (isSet) {
                await notifier.setPassword(newPwd);
                if (!dialogContext.mounted) return;
                Navigator.pop(
                  dialogContext,
                  const PasswordDialogResult(success: true),
                );
              } else if (isChange) {
                final ok = await notifier.changePassword(
                  current: currentCtrl.text,
                  next: newPwd,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(
                  dialogContext,
                  PasswordDialogResult(
                    success: ok,
                    message: ok ? null : 'La clave actual no es correcta',
                  ),
                );
              } else {
                final ok = await notifier.verify(newPwd);
                if (!dialogContext.mounted) return;
                Navigator.pop(
                  dialogContext,
                  PasswordDialogResult(
                    success: ok,
                    message: ok ? null : 'Palabra clave incorrecta',
                  ),
                );
              }
            },
            child: Text(
              switch (mode) {
                PasswordDialogMode.set => 'Activar',
                PasswordDialogMode.change => 'Cambiar',
                PasswordDialogMode.verify => 'Desbloquear',
              },
            ),
          ),
        ],
      );
    },
  );

  return result ?? const PasswordDialogResult(success: false);
}
