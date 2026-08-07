import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );
      const macosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      await requestPermissions();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
      return false;
    }
  }

  Future<void> requestPermissions() async {
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[NotificationService] iOS permission granted: $granted');
    }

    final macPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macPlugin != null) {
      final granted = await macPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[NotificationService] macOS permission granted: $granted');
    }
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily milestone and task progress reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.active,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      );

  /// Shows an immediate notification.
  /// NOTE: On iOS, this only shows as a banner when the app is in the BACKGROUND.
  /// Use [showScheduledNotification] with a few seconds delay for reliable testing.
  Future<bool> showTestNotification() async {
    final initialized = await init();
    if (!initialized) return false;

    try {
      debugPrint('[NotificationService] show() called immediately');
      await _notificationsPlugin.show(
        1001,
        'Milestones Daily Reminder 🎯',
        'Time to log your daily progress and check off completed tasks!',
        _notificationDetails,
      );
      debugPrint('[NotificationService] ✅ show() completed');
      return true;
    } catch (e, stack) {
      debugPrint('[NotificationService] ❌ Error: $e\n$stack');
      return false;
    }
  }

  /// Schedules a notification [seconds] from now using the OS scheduler.
  /// This fires even when the app is backgrounded or killed.
  Future<bool> showScheduledNotification({int seconds = 5}) async {
    final initialized = await init();
    if (!initialized) return false;

    try {
      final scheduledTime =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

      debugPrint(
          '[NotificationService] Scheduling notification at $scheduledTime');

      await _notificationsPlugin.zonedSchedule(
        1002,
        'Milestones Daily Reminder 🎯',
        'Time to log your daily progress and check off completed tasks!',
        scheduledTime,
        _notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('[NotificationService] ✅ Scheduled successfully');
      return true;
    } catch (e, stack) {
      debugPrint('[NotificationService] ❌ Schedule error: $e\n$stack');
      return false;
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool> cancelDailyReminder() async {
    try {
      await _notificationsPlugin.cancel(2000);
      debugPrint('[NotificationService] Daily reminder cancelled');
      return true;
    } catch (e) {
      debugPrint('[NotificationService] ❌ Cancel error: $e');
      return false;
    }
  }

  /// Schedules (or reschedules) a daily repeating reminder at [hour]:[minute] LOCAL time.
  /// Uses OS-level scheduling — fires every day even when the app is closed.
  Future<bool> scheduleDailyReminder(int hour, int minute) async {
    final initialized = await init();
    if (!initialized) return false;

    try {
      await _notificationsPlugin.cancel(2000);

      // Use DateTime.now() — always the true device local time
      final now = DateTime.now();
      var target = DateTime(now.year, now.month, now.day, hour, minute);

      // If that time already passed today, schedule for tomorrow
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }

      // Convert local time → UTC for the TZDateTime scheduler
      final targetUtc = target.toUtc();
      final scheduledTime = tz.TZDateTime.utc(
        targetUtc.year,
        targetUtc.month,
        targetUtc.day,
        targetUtc.hour,
        targetUtc.minute,
      );

      final hStr = hour.toString().padLeft(2, '0');
      final mStr = minute.toString().padLeft(2, '0');
      debugPrint('[NotificationService] Daily reminder → local $hStr:$mStr → UTC $scheduledTime (repeating)');

      await _notificationsPlugin.zonedSchedule(
        2000,
        'Milestones Daily Reminder 🎯',
        'Time to log your daily progress and check off your tasks!',
        scheduledTime,
        _notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Repeat at same UTC clock time every day = same local time daily
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('[NotificationService] ✅ Daily reminder set for $hStr:$mStr local time');
      return true;
    } catch (e, stack) {
      debugPrint('[NotificationService] ❌ Daily reminder error: $e\n$stack');
      return false;
    }
  }
}
