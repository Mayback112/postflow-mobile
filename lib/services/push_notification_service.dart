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
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    debugPrint("Handling a background message: ${message.messageId}");
  }
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Initialize Firebase (must be called before any other Firebase service)
    // Note: This requires google-services.json on Android and GoogleService-Info.plist on iOS
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: $e');
      }
      return;
    }

    // 2. Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Initialize Local Notifications for foreground handling
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          handleNotificationTap({'postId': details.payload});
        }
      },
    );

    // 4. Create Android Notification Channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 6. Handle notification click when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data);
    });

    // 7. Handle notification click when app is terminated
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data);
    }

    // 8. Request permissions
    await requestPermissions();
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['postId'], // Pass postId as payload
      );
    }
  }

  static void handleNotificationTap(Map<String, dynamic> data) {
    final postId = data['postId'];
    if (postId != null && postId is String) {
      // In a real app, you'd use a navigation service or key here
      // For now, we'll use a static global key or similar if available,
      // but let's assume we'll integrate with the router.
      debugPrint('Navigate to post: $postId');
      // The actual navigation should happen in the UI layer (e.g. AppState)
      _notificationTapController.add(postId);
    }
  }

  static final _notificationTapController = StreamController<String>.broadcast();
  static Stream<String> get onNotificationTap => _notificationTapController.stream;

  static Future<void> requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }
  }

  static Future<void> registerDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return;

      if (kDebugMode) {
        debugPrint('FCM Token: $token');
      }

      final notificationService = NotificationService();
      await notificationService.registerDeviceToken(
        token: token,
        platform: Platform.isIOS ? DeviceTokenPlatform.ios : DeviceTokenPlatform.android,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error registering device token: $e');
      }
    }
  }

  static Future<void> deleteDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        final notificationService = NotificationService();
        await notificationService.removeDeviceToken(token);
      }
      await _messaging.deleteToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting device token: $e');
      }
    }
  }
}
