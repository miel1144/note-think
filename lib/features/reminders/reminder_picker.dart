import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showReminderPicker(BuildContext context) async {
  final now = DateTime.now();
  final messenger = ScaffoldMessenger.of(context);

  final date = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365 * 5)),
    helpText: 'Fecha del recordatorio',
  );
  if (date == null) return null;
  if (!context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(
      now.isAfter(date)
          ? now.add(const Duration(minutes: 1))
          : now.add(const Duration(minutes: 5)),
    ),
    helpText: 'Hora del recordatorio',
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  if (time == null) return null;

  final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  if (result.isBefore(now)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('La fecha debe ser en el futuro')),
    );
    return null;
  }
  return result;
}

String formatReminder(DateTime when) {
  final now = DateTime.now();
  final isToday = when.year == now.year && when.month == now.month && when.day == now.day;
  final isTomorrow = when.year == now.year && when.month == now.month && when.day == now.day + 1;
  final hh = when.hour.toString().padLeft(2, '0');
  final mm = when.minute.toString().padLeft(2, '0');
  if (isToday) return 'Hoy $hh:$mm';
  if (isTomorrow) return 'Mañana $hh:$mm';
  return DateFormat('dd/MM/yyyy HH:mm').format(when);
}
