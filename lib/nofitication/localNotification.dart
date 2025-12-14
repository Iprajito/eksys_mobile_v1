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
    _notiPlugin.initialize(initialSettings, onDidReceiveNotificationResponse:
        (NotificationResponse response) async {
      final String? payload = response.payload;
      print(
          "This is from localNotification.dart file and static void initialize()");
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

  static void initializeForeground() {
    const InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    _notiPlugin.initialize(initialSettings, onDidReceiveNotificationResponse:
        (NotificationResponse response) async {
      final String? payload = response.payload;
      print(
          "This is from localNotification.dart file and static void initializeForeground()");
      print(payload);
      print('onDidReceiveNotificationResponse Function');

      if (payload != null && payload.isNotEmpty) {
        _handlePayload(payload);
      }
    });
  }

  static void _handlePayload(String payload) {
    // Parse the payload string to extract data
    try {
      // Convert the payload string to a Map
      final Map<String, dynamic> payloadMap = parsePayload(payload);
      
      // Extract userToken
      final String? userToken = payloadMap['userToken'];
      
      if (userToken != null) {
        print('Extracted userToken: $userToken');
        // You can use the userToken here as needed
      }
      
      // Original navigation logic
      if (payloadMap['type'] == 'chat') {
        print('howww chat');
        NavigationService.navigatePush('/profil');
      }
    } catch (e) {
      print('Error parsing payload: $e');
    }
  }
  
  // Helper method to parse the payload string into a Map
  static Map<String, dynamic> parsePayload(String payload) {
    // Remove curly braces if present
    String cleanPayload = payload.trim();
    if (cleanPayload.startsWith('{') && cleanPayload.endsWith('}')) {
      cleanPayload = cleanPayload.substring(1, cleanPayload.length - 1);
    }
    
    // Split by commas and process each key-value pair
    final Map<String, dynamic> result = {};
    
    final List<String> pairs = cleanPayload.split(',');
    for (String pair in pairs) {
      final List<String> keyValue = pair.split(':');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();
        
        // Remove any quotes around the key
        if (key.startsWith('"') && key.endsWith('"')) {
          key = key.substring(1, key.length - 1);
        }
        
        // Remove any quotes around the value
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        
        result[key] = value;
      }
    }
    
    return result;
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
      // Using context-free navigation that preserves back stack
      NavigationService.navigatePush('/profil');

      // Get.to(() => DisasterReport());
    });
  }

  static Future initBackground({bool scheduled = false}) async {
    const InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );
    await _notiPlugin.initialize(initialSettings,
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
      payload: message.data.toString(),
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

  static void showForegroundNotification(RemoteMessage message) {
    print("Show Foreground Notification from localNotification.dart");
    const NotificationDetails notiDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          'high_importance_channel', 'foreground_notification',
          channelDescription:
              'For handle show notification when app is in foreground',
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
      payload: message.data['type'],
    );
  }

  static void showBackgroundNotification(RemoteMessage message) {
    globals.notifroute = "inv";
    const NotificationDetails notiDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_background_channel',
        'background_notification',
        channelDescription:
            'For handle show notification when app is in background',
        // sound: RawResourceAndroidNotificationSound('alert_sound'),
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
      // payload: message.data.toString(),
      payload: message.data['type'],
    );
  }
}
