import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as ltz;
import 'package:flutter_timezone/flutter_timezone.dart';

enum NotificationFrequency { daily, weekly }

extension NotificationFrequencyExt on NotificationFrequency {
  String stringRepresentation() {
    switch (this) {
      case NotificationFrequency.daily:
        return "Daily";
      case NotificationFrequency.weekly:
        return "Weekly";
    }
  }

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

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  late FlutterLocalNotificationsPlugin notificationsPlugin;

  factory NotificationService({FlutterLocalNotificationsPlugin? plugin}) {
    _notificationService.notificationsPlugin =
        plugin ?? FlutterLocalNotificationsPlugin();
    return _notificationService;
  }

  NotificationService._internal();

  //INITIALIZE
  Future<void> initialise() async {
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
    await notificationsPlugin.initialize(initSettings);
  }

  //NOTIFICATION DETAILS
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id', "Daily Notifications",
          channelDescription: 'Daily Notifications Channel',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon'),
    );
  }

  //SHOW NOTIFICATION
  Future<void> showNotification({int? id, String? title, String? body}) async {
    var random = Random();
    int randomId = random.nextInt(100000);
    return notificationsPlugin.show(
      id ?? randomId,
      title,
      body,
      notificationDetails(),
    );
  }

  //SCHEDULE NOTIFICATIONS
  Future<void> scheduleNotification(
      {int? id,
      required String title,
      required String body,
      required NotificationFrequency notificationFrequency}) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = now.add(const Duration(seconds: 5));

    var random = Random();
    int randomId = random.nextInt(100000);
    await notificationsPlugin.zonedSchedule(
        id ?? randomId, //if no Id passed in use random id
        title,
        body,
        scheduledDate,
        notificationDetails(),
        /*
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
         */
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

        // REPEATS THE NOTIFICATION DAILY
        matchDateTimeComponents:
            resolveNotificationFrequency(notificationFrequency)
        //if daily is passed repeat it daily otherwise repeat weekly
        );
  }

  DateTimeComponents resolveNotificationFrequency(NotificationFrequency nf) {
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

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    print("Inside getPendingNotifications()"); // Debugging print
    return await notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
