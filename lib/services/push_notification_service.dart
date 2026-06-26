import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:postflow/firebase_options.dart';
import 'package:postflow/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final _tapController = StreamController<String>.broadcast();
  static Stream<String> get onNotificationTap => _tapController.stream;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Firebase init failed: $e');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) handleNotificationTap({'postId': details.payload});
      },
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'Used for important PostFlow notifications.',
            importance: Importance.max,
          ));
    }

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((msg) => handleNotificationTap(msg.data));

    final initial = await _messaging.getInitialMessage();
    if (initial != null) handleNotificationTap(initial.data);

    await requestPermissions();
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important PostFlow notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: message.notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['postId'],
    );
  }

  static void handleNotificationTap(Map<String, dynamic> data) {
    final postId = data['postId'];
    if (postId is String) _tapController.add(postId);
  }

  static Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }
  }

  static Future<void> registerDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await NotificationService().registerDeviceToken(
        token: token,
        platform: Platform.isIOS ? DeviceTokenPlatform.ios : DeviceTokenPlatform.android,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token registration failed: $e');
    }
  }

  static Future<void> deleteDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await NotificationService().removeDeviceToken(token);
      await _messaging.deleteToken();
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token deletion failed: $e');
    }
  }
}
