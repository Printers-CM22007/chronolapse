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
  // List<PendingNotificationRequest> pendingNotificationsStore = [];
  // List<String> activeNotificationsStore = [];
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
      print(
          "Mocked pendingNotificationRequests() called: Returning ${scheduledNotifications.length} notifications");
      return scheduledNotifications;
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
  });
}
