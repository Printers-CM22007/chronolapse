import 'dart:math';

import 'package:chronolapse/backend/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mock_notification_plugin.mocks.dart';



void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;

  List<PendingNotificationRequest> scheduledNotifications = [];
  // List<PendingNotificationRequest> pendingNotificationsStore = [];
  // List<String> activeNotificationsStore = [];
  var random = Random();
  setUp(() async{
    // Mock flutter_timezone since it is a platform plugin
    MethodChannel('flutter_timezone')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return "UTC";

    });

    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

    // Mock initialize method
    when(mockFlutterLocalNotificationsPlugin.initialize(any)).thenAnswer((_) async => true);

    // Mock pendingNotificationRequests to return stored notifications
    when(mockFlutterLocalNotificationsPlugin.pendingNotificationRequests())
        .thenAnswer((_) async {
      print("Mocked pendingNotificationRequests() called: Returning ${scheduledNotifications.length} notifications");
      return scheduledNotifications;
    });


    // Mock zonedSchedule to simulate successful scheduling
    when(mockFlutterLocalNotificationsPlugin.zonedSchedule(
      any, any, any, any, any,
      uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
    )).thenAnswer((invocation) async {
      int id = invocation.positionalArguments[0];
      String? title = invocation.positionalArguments[1];
      String? body = invocation.positionalArguments[2];

      scheduledNotifications.add(PendingNotificationRequest(id, title, body, "channel"));

      print("Scheduled notification added: ID = $id, Title = $title, Total = ${scheduledNotifications.length}");
    });

    // Inject the mock plugin into NotificationService
    print("Injecting mock plugin...");
    notificationService = NotificationService(plugin: mockFlutterLocalNotificationsPlugin);
    await notificationService.initialise();

  });

  group('Notification Service', (){
    test(
      'should have 2 notifications scheduled', () async{
      await notificationService.scheduleNotification(title: "n1", body: "test noti_1", hour: 1, minute: 50);
      await notificationService.scheduleNotification(title: "n2", body: "test noti_2", hour: 5, minute: 15);

      print("Fetching pending notifications...");

      List<PendingNotificationRequest> pendingNotifications = await notificationService.getPendingNotifications();

      print("Test result: Found ${pendingNotifications.length} pending notifications");

      expect(pendingNotifications.length, 2);
    }
    );
  });
}