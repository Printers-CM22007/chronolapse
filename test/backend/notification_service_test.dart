import 'dart:math';

import 'package:chronolapse/backend/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mock_notification_plugin.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;

  List<PendingNotificationRequest> scheduledNotifications = [];
  List<ActiveNotification> activeNotifications = [];
  var random = Random();
  setUp(() async {
    // Mock flutter_timezone since it is a platform plugin
    const MethodChannel('flutter_timezone')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return "UTC";
    });

    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

    // Mock initialize method
    when(mockFlutterLocalNotificationsPlugin.initialize(any))
        .thenAnswer((_) async => true);

    // Mock pendingNotificationRequests to return stored notifications
    when(mockFlutterLocalNotificationsPlugin.pendingNotificationRequests())
        .thenAnswer((_) async {
      return scheduledNotifications;
    });

    when(mockFlutterLocalNotificationsPlugin.getActiveNotifications())
        .thenAnswer((_) async {
      return activeNotifications;
    });

    // Mock zonedSchedule to simulate successful scheduling
    when(mockFlutterLocalNotificationsPlugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidScheduleMode: anyNamed('androidScheduleMode'),
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
    )).thenAnswer((invocation) async {
      int id = invocation.positionalArguments[0];
      String? title = invocation.positionalArguments[1];
      String? body = invocation.positionalArguments[2];

      scheduledNotifications
          .add(PendingNotificationRequest(id, title, body, "channel"));

      print(
          "Scheduled notification added: ID = $id, Title = $title, Total = ${scheduledNotifications.length}");
    });

    // Mock the show method to simulate successful notification showing
    when(mockFlutterLocalNotificationsPlugin.show(
      any,
      any,
      any,
      any,
      payload: anyNamed('payload'),
    )).thenAnswer((invocation) async {
      int id = invocation.positionalArguments[0];
      String? title = invocation.positionalArguments[1];
      String? body = invocation.positionalArguments[2];
      NotificationDetails details = invocation.positionalArguments[3];

      activeNotifications
          .add(ActiveNotification(id: id, title: title, body: body));
    });

    when(mockFlutterLocalNotificationsPlugin.cancel(any))
        .thenAnswer((invocation) async {
      int notificationId = invocation.positionalArguments[0];
      // Remove the notification with this ID from the scheduled notifications list
      scheduledNotifications
          .removeWhere((notification) => notification.id == notificationId);
    });

    when(mockFlutterLocalNotificationsPlugin.cancelAll())
        .thenAnswer((invocation) async {
      print("Cancelling all notifications");
      scheduledNotifications.clear();
    });

    // Inject the mock plugin into NotificationService
    print("Injecting mock plugin...");
    await NotificationService.initialise(
        notificationPlugin: mockFlutterLocalNotificationsPlugin);
  });

  group('Notification Service', () {
    setUp(() {
      scheduledNotifications.clear();
      activeNotifications.clear();
    });
    test('Should have 0 notifications scheduled', () async {
      List<PendingNotificationRequest> pendingNotifications =
          await NotificationService.getPendingNotifications();

      expect(pendingNotifications.length, 0);
    });
    test('should have 2 notifications scheduled', () async {
      await NotificationService.scheduleNotification(
          title: "n1",
          body: "test noti_1",
          notificationFrequency: NotificationFrequency.daily);
      await NotificationService.scheduleNotification(
          title: "n2",
          body: "test noti_2",
          notificationFrequency: NotificationFrequency.weekly);

      List<PendingNotificationRequest> pendingNotifications =
          await NotificationService.getPendingNotifications();

      expect(pendingNotifications.length, 2);
    });
    test(
        'When 2 notifications are pending, cancelling one of them should set pendingNotifications to 1',
        () async {
      await NotificationService.scheduleNotification(
          id: 0,
          title: "n1",
          body: "test noti_1",
          notificationFrequency: NotificationFrequency.daily);
      await NotificationService.scheduleNotification(
          id: 1,
          title: "n2",
          body: "test noti_2",
          notificationFrequency: NotificationFrequency.weekly);

      await NotificationService.cancelNotification(0);

      List<PendingNotificationRequest> pendingNotifications =
          await NotificationService.getPendingNotifications();

      expect(pendingNotifications.length, 1);
    });
    test('Cancelling notifications should set pendingNotifications to 0',
        () async {
      await NotificationService.scheduleNotification(
          title: "n1",
          body: "test noti_1",
          notificationFrequency: NotificationFrequency.daily);
      await NotificationService.scheduleNotification(
          title: "n2",
          body: "test noti_2",
          notificationFrequency: NotificationFrequency.weekly);

      NotificationService.cancelAllNotifications();

      List<PendingNotificationRequest> pendingNotifications =
          await NotificationService.getPendingNotifications();

      expect(pendingNotifications.length, 0);
    });
    test('showNotification() method should immediately show a notification',
        () async {
      await NotificationService.showNotification(
        title: "n1",
        body: "test noti_1",
      );
      List<ActiveNotification> activeNotifs =
          await NotificationService.getActiveNotifications();

      expect(activeNotifs.length, 1);
    });
  });
}
