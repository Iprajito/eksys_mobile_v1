import 'package:eahmindonesia/services/navigation_service.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eahmindonesia/controllers/splash_notif.dart';
import 'package:eahmindonesia/models/text_globals.dart' as globals;

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _notiPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    _notiPlugin.initialize(initialSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final String? payload = response.payload;
      print("This is from localNotification.dart file and static void initialize()");
      print(payload);
      print('onDidReceiveNotificationResponse Function');

      if (payload != null && payload.isNotEmpty) {
        // Handle notification tap when app is already running or background
        _handlePayload(payload);
      }
      // print(details.payload);
      // print(details.payload != null);
      // await Get.to(() => InvExpired(id_pelanggan: globals.idPelanggan));
      // Get.to(() => HomePage());
    });

    //For Background Notif
    // _notiPlugin.initialize(initialSettings,
    //     onDidReceiveBackgroundNotificationResponse: (NotificationResponse details) {
    //   print('onDidReceiveNotificationResponseBackground Function');
    //   print(details.payload);
    //   print(details.payload != null);
    //   Get.to(() => InvCategoryPage(id_pelanggan: globals.idPelanggan));
    // });
  }

  static void _handlePayload(String payload) {
    // You can use a global navigator key to handle navigation here
    if (payload == 'chat') {
      print('howww chat');
      NavigationService.navigateTo('/profil');
    }
  }

  static Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return await _notiPlugin.getNotificationAppLaunchDetails();
  }

  static void backgroundInitialize() {
    const InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    _notiPlugin.initialize(initialSettings,
        onDidReceiveBackgroundNotificationResponse:
            (NotificationResponse details) async {
      final String? payload = details.payload;
      debugPrint(payload);
      print('onDidReceiveNotificationResponseBackground Function');
      debugPrint('onDidReceiveNotificationResponseBackground Function');
      // print(details.payload);
      // print(details.payload != null);

      // await Get.to(() => SplashNotif());
      // Using context-free navigation
      NavigationService.navigateTo('/profil');

      // Get.to(() => DisasterReport());
    });
  }

  static Future initBackground({bool scheduled = false}) async {
    const InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    await _notiPlugin.initialize(initialSettings, onDidReceiveBackgroundNotificationResponse: (NotificationResponse details) async {
      final String? payload = details.payload;
      debugPrint(payload);
      print('onDidReceiveNotificationResponseBackground Function');
      debugPrint('onDidReceiveNotificationResponseBackground Function');
      // print(details.payload);
      // print(details.payload != null);

      // await Get.to(() => SplashNotif());
      // Using context-free navigation
      NavigationService.navigateTo('/profil');

      // Get.to(() => DisasterReport());
    });
  }

  static void showNotification(RemoteMessage message) {
    print("Hoe coba");
    const NotificationDetails notiDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          'high_importance_channel', 'disaster_notification',
          // sound: RawResourceAndroidNotificationSound('alert_sound'),
          playSound: true,
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true),
    );
    _notiPlugin.show(
      DateTime.now().microsecond,
      message.data["title"],
      message.data["body"],
      notiDetails,
      // payload: message.data.toString(),
      payload: message.data['type'],
    );

    // if(message.notification!.title == "data"){
    //   // _notiPlugin.show(
    //   //   DateTime.now().microsecond,
    //   //   message.notification!.title,
    //   //   message.notification!.body,
    //   //   notiDetails,
    //   //   payload: message.toString(),
    //   // );
    //   _notiPlugin.show(
    //     DateTime.now().microsecond,
    //     message.data["title"],
    //     message.data["body"],
    //     notiDetails,
    //     payload: message.data.toString(),
    //   );
    // } else if(message.notification!.title != "data"){
    //   // _notiPlugin.show(
    //   //   DateTime.now().microsecond,
    //   //   message.data["title"],
    //   //   message.data["body"],
    //   //   notiDetails,
    //   //   payload: message.data.toString(),
    //   // );
    //   _notiPlugin.show(
    //     DateTime.now().microsecond,
    //     message.notification!.title,
    //     message.notification!.body,
    //     notiDetails,
    //     payload: message.toString(),
    //   );
    // }
  }

  static void showBackgroundNotification(RemoteMessage message) {
    globals.notifroute = "inv";
    const NotificationDetails notiDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'background notification nih',
        channelDescription: 'notifku ini',
        sound: RawResourceAndroidNotificationSound('alert_sound'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        actions: <AndroidNotificationAction>[
          // AndroidNotificationAction('id_1', 'Action 1'),
          // AndroidNotificationAction('id_2', 'Action 2'),
          // AndroidNotificationAction('id_3', 'Action 3'),
        ],
      ),
    );

    _notiPlugin.show(
      DateTime.now().microsecond,
      message.data["title"],
      message.data["body"],
      notiDetails,
      payload: message.data.toString(),
    );
  }
}
