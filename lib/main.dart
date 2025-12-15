import 'dart:async';

import 'package:eahmindonesia/nofitication/localNotification.dart';
import 'package:eahmindonesia/services/navigation_service.dart';
import 'package:eahmindonesia/views/auth/login.dart';
import 'package:eahmindonesia/views/auth/logincabang.dart';
import 'package:eahmindonesia/views/page/dasboard.dart';
import 'package:eahmindonesia/views/page/main.dart';
import 'package:eahmindonesia/views/page/main_pusat.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/detail.dart';
import 'package:eahmindonesia/views/page/splash.dart';
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
        GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/logincabang',builder: (context, state) => const LoginCabangPage()),
        GoRoute(path: '/main',builder: (context, state) => const MainPage(currIndex: 0,)),
        GoRoute(path: '/main_pusat',builder: (context, state) => const MainPusatPage(currIndex: 0)),
        GoRoute(path: '/dashboard',builder: (context, state) => const DashboardPage()),
        GoRoute(path: '/profil', builder: (context, state) => const ProfilPage()),
        GoRoute(
            path: '/pembelian_detail',
            builder: (context, state) {
              final params = state.uri.queryParameters;
              final token = params['token'] ?? '';
              final userid = params['userid'] ?? '';
              final idencrypt = params['idencrypt'] ?? '';
              return PembelianDetailPage(
                  token: token, userid: userid, idencrypt: idencrypt);
            }),
      ]);
}
