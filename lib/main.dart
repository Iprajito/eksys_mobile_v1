import 'dart:async';
import 'dart:io';

import 'package:eahmindonesia/nofitication/localNotification.dart';
import 'package:eahmindonesia/services/navigation_service.dart';
import 'package:eahmindonesia/views/auth/login.dart';
import 'package:eahmindonesia/views/auth/logincabang.dart';
import 'package:eahmindonesia/views/page/dasboard.dart';
import 'package:eahmindonesia/views/page/main.dart';
import 'package:eahmindonesia/views/page/main_pusat.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:eahmindonesia/views/page/splash.dart';
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Below is for activate background pop up notification
  // if (message.data["type"] == "new") {
  //   showCustomNotification(message);
  // } else {
  //   showBackgroundNotification(message);
  // }
  if (message.data["type"] == "chat") {
    LocalNotification.showNotification(message);
  } else {
    LocalNotification.showBackgroundNotification(message);
  }

  print("Handling a background message: ${message.messageId}");
}

String? selectedNotificationPayload;
String initialRoute = '/splash';
const String navigationActionId = 'id_3';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

// Below function for initialize and show custom localnotification
void showCustomNotification(RemoteMessage message) async {
  const NotificationDetails notiDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'high_importance_channel2',
      'background notif expired',
      channelDescription: 'Background notif expired channel',
      sound: RawResourceAndroidNotificationSound('alert_sound'),
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      // fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        // AndroidNotificationAction('id_1', 'Action 1'),
        // AndroidNotificationAction('id_2', 'Action 2'),
        // AndroidNotificationAction('id_3', 'Action 3'),
      ],
    ),
  );

  flutterLocalNotificationsPlugin.show(
    DateTime.now().microsecond,
    message.data["title"],
    message.data["body"],
    notiDetails,
    payload: message.data.toString(),
  );

  // flutterLocalNotificationsPlugin
  // .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

// Below function for initialize and show custom localnotification
void showBackgroundNotification(RemoteMessage message) async {
  // initialRoute = '/login';
  const NotificationDetails notiDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'high_importance_channel',
      'background notification normal',
      channelDescription: 'Background notif channel',
      // sound: RawResourceAndroidNotificationSound('alert_sound'),
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      // fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        // AndroidNotificationAction('id_1', 'Action 1'),
        // AndroidNotificationAction('id_2', 'Action 2'),
        // AndroidNotificationAction('id_3', 'Action 3'),
      ],
    ),
  );

  // await Get.offAndToNamed('/invexpired');

  flutterLocalNotificationsPlugin.show(
    DateTime.now().microsecond,
    message.data["title"],
    message.data["body"],
    notiDetails,
    payload: message.data.toString(),
  );

  // flutterLocalNotificationsPlugin
  // .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

// HANDLE BEHAVIOUR IF NOTIFICATION TAPPED WHEN APP ON FOREGROUND STATE
void notificationTapForeground(
    NotificationResponse notificationResponse) async {
  NavigationService.navigateTo('/profil');
  //TODO: Routing notif after tap notification, get from notificationResponse field routing
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
  // final payload = notificationResponse.payload;
  final payload = notificationResponse.payload;

  // Remove curly braces using replaceAll
  String resultString = payload!.replaceAll('{', '').replaceAll('}', '');
  String delimiter = ",";

  String routing = '/';

  List<String> substrings = resultString.split(delimiter);
  for (String substring in substrings) {
    String delimiter2 = ":";
    List<String> substrings2 = substring.split(delimiter2);
    if (substrings2[0] == 'routing') {
      routing = substrings2[1].replaceAll(' ', '');
    }
    print(routing);
  }
  // await Get.toNamed(routing);
  // try {
  //   final routing = jsonPayload['routing'];
  //   await Get.toNamed(routing);
  // } catch (e) {
  //   print("Error decode notificationResponse");
  // }
  // Future.delayed(Duration.zero, () {
  //   Get.offAndToNamed('/login');
  // });
}

//* HANDLE BEHAVIOUR IF NOTIFICATION TAPPED WHEN APP ON BACKGROUND STATE
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  NavigationService.navigateTo('/profil');
  // ignore: avoid_print

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    NavigationService.navigateTo('/profil');
  }

  // globals.notifroute = "inv";
  initialRoute = '/invexpired';
  print(
      'notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.id == "id_1") {
    initialRoute = '/invexpired';
  }
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
    // Get.offAndToNamed('/invexpired');
  } else {
    // await Get.offAndToNamed('/invexpired');
  }

  print("Hoeee cek cek");
  // await Get.offAndToNamed('/invexpired');
  // await Get.to(() => PemapiCarePage());
  // await Get.offAndToNamed('/login');
  // Future.delayed(Duration.zero, () {
  //   Get.offAndToNamed('/login');
  // });
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotification.initialize();
  await initializeDateFormatting('id_ID', null);
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NavigationService.navigatorKey = GlobalKey<NavigatorState>();

  final launchDetails = await LocalNotification.getLaunchDetails();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    // initialRoute = '/splash';
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          notificationTapForeground(notificationResponse);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);
  print('user granted permission ${settings.authorizationStatus}');
  runApp(MainApp(launchDetails: launchDetails));
}

class MainApp extends StatelessWidget {
  // MainApp() {
  //   // Initialize NavigationService with the router
  //   NavigationService.init(_router);
  // }
  final NotificationAppLaunchDetails? launchDetails;
  MainApp({super.key, this.launchDetails}) {
    // Initialize NavigationService with the router
    NavigationService.init(_router);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.8)),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'EAHM',
        routerConfig: _router,
      ),
    );
  }

  final GoRouter _router = GoRouter(
      initialLocation: '/splash',
      // initialLocation: '/logincabang',
      routes: [
        GoRoute(
            path: '/splash', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
            path: '/logincabang',
            builder: (context, state) => const LoginCabangPage()),
        GoRoute(
            path: '/main',
            builder: (context, state) => const MainPage(
                  currIndex: 0,
                )),
        GoRoute(
            path: '/main_pusat',
            builder: (context, state) => const MainPusatPage(currIndex: 0)),
        GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage()),
        GoRoute(
            path: '/profil', builder: (context, state) => const ProfilPage()),
      ]);
}
