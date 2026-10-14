import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final t = Theme.of(dialogContext);
      final scheme = t.colorScheme;
      final confirmColor = destructive ? scheme.error : null;
      final confirmFg = destructive ? scheme.onError : null;
      return AlertDialog(
        icon: icon == null
            ? null
            : Icon(
                icon,
                color: destructive ? scheme.error : null,
              ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: confirmColor == null
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: confirmFg,
                  ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
