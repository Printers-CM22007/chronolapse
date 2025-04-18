import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as ltz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../util/uninitialised_exception.dart';

/// Frequency at which notifications are sent
enum NotificationFrequency { daily, weekly }

extension NotificationFrequencyExt on NotificationFrequency {
  /// Get a unique string representation of the variant
  String stringRepresentation() {
    switch (this) {
      case NotificationFrequency.daily:
        return "Daily";
      case NotificationFrequency.weekly:
        return "Weekly";
    }
  }

  /// Get the enum variant from the string representation. Inverse to
  /// `stringRepresentation`
  static NotificationFrequency? getOptionFromString(String option) {
    if (option.isEmpty) {
      return null;
    }
    for (final possible in NotificationFrequency.values) {
      if (possible.stringRepresentation() == option) {
        return possible;
      }
    }
    throw Exception("`$option` isn't a valid NotificationFrequencyOption");
  }
}

/// Manages scheduling notifications
class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService._(this._notificationsPlugin);

  static NotificationService _getInstance() {
    if (_instance == null) {
      throw UninitialisedException(
          "Notification.initialise() has not been called (must be awaited)");
    }
    return _instance!;
  }

  static Future<void> initialise(
      {FlutterLocalNotificationsPlugin? notificationPlugin}) async {
    if (_instance != null) {
      return;
    }

    final instance = NotificationService._(
        notificationPlugin ?? FlutterLocalNotificationsPlugin());

    //initialize timezone handling
    ltz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    //Prepare android init settings
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    //apply init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    //initialize the plugin
    await instance._notificationsPlugin.initialize(initSettings);

    _instance = instance;
  }

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id', "Daily Notifications",
          channelDescription: 'Daily Notifications Channel',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon'),
    );
  }

  /// Shows a notification immediately
  static Future<void> showNotification(
      {int? id, String? title, String? body}) async {
    var random = Random();
    int randomId = random.nextInt(100000);
    return _getInstance()._notificationsPlugin.show(
          id ?? randomId,
          title,
          body,
          _notificationDetails(),
        );
  }

  /// Schedules a notification to be show regularly
  static Future<void> scheduleNotification(
      {int? id,
      required String title,
      required String body,
      required NotificationFrequency notificationFrequency}) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = now.add(const Duration(seconds: 5));

    var random = Random();
    int randomId = random.nextInt(100000);
    await _getInstance()._notificationsPlugin.zonedSchedule(
        id ?? randomId, //if no Id passed in use random id
        title,
        body,
        scheduledDate,
        _notificationDetails(),
        /*
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
         */
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

        // REPEATS THE NOTIFICATION DAILY
        matchDateTimeComponents:
            _resolveNotificationFrequency(notificationFrequency)
        //if daily is passed repeat it daily otherwise repeat weekly
        );
  }

  static DateTimeComponents _resolveNotificationFrequency(
      NotificationFrequency nf) {
    switch (nf) {
      case NotificationFrequency.daily:
        {
          return DateTimeComponents.time;
        }
      case NotificationFrequency.weekly:
        return DateTimeComponents
            .dayOfWeekAndTime; //not sure if this actually makes it repeat weekly, need to look into it more
    }
  }

  /// Lists all the currently pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _getInstance()
        ._notificationsPlugin
        .pendingNotificationRequests();
  }

  /// Lists the currently active notifications
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _getInstance()._notificationsPlugin.getActiveNotifications();
  }

  /// Cancels a notification
  static Future<void> cancelNotification(int id) async {
    await _getInstance()._notificationsPlugin.cancel(id);
  }

  /// Cancels all notifications
  static Future<void> cancelAllNotifications() async {
    await _getInstance()._notificationsPlugin.cancelAll();
  }
}
