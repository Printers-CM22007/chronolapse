import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as ltz;
import 'package:flutter_timezone/flutter_timezone.dart';

enum NotificationFrequency{
  daily,
  weekly,
}

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInit = false;

  bool get isInit => _isInit;

  //INITIALIZE
  Future<void> initialise() async {
    if (_isInit) return;

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
        'daily_channel_id',
        "Daily Notifications",
        channelDescription: 'Daily Notifications Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //SHOW NOTIFICATION
  Future<void> showNotification(
      {int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }

  //SCHEDULE NOTIFICATIONS
  Future<void> scheduleNotification(
      {int id = 1,
      required String title,
      required String body,
      required int hour,
      required int minute,
      NotificationFrequency notificationFrequency = NotificationFrequency.daily}) async {
    final now = tz.TZDateTime.now(tz.local); //current date time

    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // REPEATS THE NOTIFICATION DAILY
      matchDateTimeComponents: resolveNotificationFrequency(notificationFrequency)
      //if daily is passed repeat it daily otherwise repeat weekly
    );
  }

  DateTimeComponents resolveNotificationFrequency(NotificationFrequency nf){
    switch(nf){
      case NotificationFrequency.daily : {
        return DateTimeComponents.time;
      }
      case NotificationFrequency.weekly:
        return DateTimeComponents.dayOfWeekAndTime; //not sure if this actually makes it repeat weekly, need to look into it more
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
