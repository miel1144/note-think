import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class RemindersService {
  RemindersService._();
  static final RemindersService instance = RemindersService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'note_reminders';
  static const String _channelName = 'Recordatorios de notas';
  static const String _channelDescription =
      'Notificaciones programadas para recordatorios de notas';

  final ValueNotifier<int?> tappedNoteId = ValueNotifier<int?>(null);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> schedule({
    required int noteId,
    required DateTime when,
    required String title,
    required String body,
    bool isPrivate = false,
  }) async {
    if (when.isBefore(DateTime.now())) return;
    final notificationTitle = isPrivate ? 'Tienes un recordatorio' : title;
    final notificationBody = isPrivate
        ? 'Toca para abrir la nota'
        : (body.isEmpty ? 'Toca para abrir la nota' : body);
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    try {
      await _plugin.zonedSchedule(
        id: noteId,
        title: notificationTitle,
        body: notificationBody,
        scheduledDate: tzWhen,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: noteId.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RemindersService.schedule failed: $e');
      }
    }
  }

  Future<void> cancel(int noteId) async {
    try {
      await _plugin.cancel(id: noteId);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  void _onTap(NotificationResponse response) {
    final id = int.tryParse(response.payload ?? '');
    if (id != null) {
      tappedNoteId.value = id;
    }
  }

  String firstBodyLine(List<String> bodyPlain) {
    for (final line in bodyPlain) {
      final t = line.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}
