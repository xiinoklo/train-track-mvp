import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const String _enabledKey = 'daily_session_reminder_enabled';
  static const String _channelId = 'daily_training_reminders';
  static const String _channelName = 'Recordatorios de entrenamiento';
  static const String _channelDescription =
      'Recordatorio diario para registrar tu sesión en TrainTrack.';

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const timeZone = String.fromEnvironment(
      'APP_TIMEZONE',
      defaultValue: 'America/Santiago',
    );
    tz.setLocalLocation(tz.getLocation(timeZone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    if (await isDailyReminderEnabled()) {
      await scheduleDailyReminder();
    }
  }

  static Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<bool> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    final allowed = await _requestPermission();

    if (!allowed) {
      return false;
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'TrainTrack',
      body: 'Recuerda registrar tu sesión y RPE de hoy.',
      scheduledDate: _nextDailyTime(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    return true;
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: _dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }

  static tz.TZDateTime _nextDailyTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<bool> _requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (android != null) {
        return await android.requestNotificationsPermission() ?? true;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      return true;
    } catch (error) {
      developer.log(
        'No se pudo solicitar permisos de notificacion: $error',
        name: 'NotificationService',
      );
      return false;
    }
  }
}
