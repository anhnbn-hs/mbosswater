import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static const String CHANNEL_ID = "MBOSS_Channel_1";
  static const String CHANNEL_NAME = "Guarantee Notifications";

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    print("Notification clicked: ${notificationResponse.payload}");
    if (notificationResponse.payload == 'instant_notification') {
      print("NAVIGATE ON CLICK NOTIFICATION");
    }
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    required String detail,
  }) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        CHANNEL_ID,
        CHANNEL_NAME,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          detail,
          contentTitle: title,
        ),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'instant_notification',
    );
  }

// static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     id,
//     title,
//     body,
//     tz.TZDateTime.from(scheduledTime, tz.local),
//     const NotificationDetails(
//       iOS: DarwinNotificationDetails(),
//       android: AndroidNotificationDetails(
//         'reminder_channel',
//         'Reminder Channel',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//     ),
//     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.dateAndTime,
//   );
// }
}
