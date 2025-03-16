import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

import '../../main.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("Background Notification Received");
  if (message.notification != null) {
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
  print("Payload: ${message.data}");
}

class NotificationService {
  final _fbmsg = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is user for important notification',
      importance: Importance.defaultImportance
  );

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      if (navigatorKey.currentState != null) {
        if (screen == '/chat') {
          navigatorKey.currentState!.pushNamed(screen,
              arguments: {
                'chatId': message.data['chatId'],
                'senderId': message.data['senderId'],
                'receiverId': message.data['receiverId']
              });
        } else if (screen == '/profile') {
          navigatorKey.currentState!.pushNamed(screen,
            arguments: {'profileId': message.data['profileId']},
          );
        } else {
          // Handle other screens
          navigatorKey.currentState!.pushNamed(screen, arguments: message.data);
        }
      }
    }
  }

  Future initNotifications() async{
    final NotificationSettings settings = await _fbmsg.requestPermission(
      alert: true, badge: true, sound: true,
      provisional: false, /// (true) for iOS provisional authorization
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      initPushNotifications();
      initLocalNotification();
    }
    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      initPushNotifications();
      initLocalNotification();
    }
  }

  Future initLocalNotification()async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/instagram_logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotification.initialize(
      settings, onDidReceiveNotificationResponse: (response) {
      if (response.payload != null) {
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handleMessage(message);
      }
    },
    );

    final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await _fbmsg.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true
    );

    _fbmsg.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    FirebaseMessaging.onMessage.listen((message){
      final notification = message.notification;
      if (notification == null) return;

      // /// Get current screen to prevent notifications deliver if the user in the same screen (Profile)
      // final currentRoute = navigatorKey.currentState?.overlay?.context == null ? null
      //     : ModalRoute.of(navigatorKey.currentState!.overlay!.context)?.settings.name;
      //
      // if (currentRoute == '/chat' && message.data['screen'] == '/chat') return;

      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
                channelDescription: _androidChannel.description, icon: '@drawable/instagram_logo')
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = await rootBundle.loadString('assets/service-account.json');
    final credentials = auth.ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    final client = await auth.clientViaServiceAccount(credentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  static const String _projectId = "twitter-ac4d7";

  static sendPushNotification(String fcmToken, String username, String message,
      Map<String, dynamic> data) async {
    final accessToken = await getAccessToken();
    String fcmUrl = "https://fcm.googleapis.com/v1/projects/$_projectId/messages:send";

    /// Notification payload
    final Map<String, dynamic> notificationPayload =
    {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": username,
          "body": message,
        },
        "android": {
          "priority": "high",
          "notification": {
            "sound": "default",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "default",
              "content-available": 1,
            }
          }
        },
        "data": data,
      }
    };

    /// Send HTTP request to Firebase HTTP v1 API
    await http.post(Uri.parse(fcmUrl),
      headers: <String, String> {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(notificationPayload),
    );
  }
}