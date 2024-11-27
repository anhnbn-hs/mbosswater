import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseCloudMessage {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Khởi tạo Firebase Messaging
  Future<void> initialize() async {
    // Yêu cầu quyền nhận thông báo
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User denied or did not grant permission');
    }

    // Lấy token FCM
    await getToken();

    // Xử lý khi nhận thông báo foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Xử lý khi người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.notification?.title}');
      // Điều hướng hoặc xử lý logic nếu cần
    });
  }

  /// Lấy token FCM
  Future<void> getToken() async {
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    // Gửi token lên server nếu cần
  }



  /// Xử lý thông báo FCM
  Future<void> _handleMessage(RemoteMessage message) async {
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;

    if (title != null && body != null) {
      await NotificationService.showInstantNotification(title, body);
    }
  }
}
