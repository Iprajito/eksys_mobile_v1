import 'package:eahmindonesia/nofitication/localNotification.dart';
import 'package:eahmindonesia/views/auth/login.dart';
import 'package:eahmindonesia/views/page/dasboard_pusat.dart';
import 'package:eahmindonesia/views/page/salesorder/salesorder.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:eahmindonesia/views/page/purchaseorder/purchaseorder.dart';
import 'package:eahmindonesia/views/page/old/report/report_pembelian.dart';
import 'package:eahmindonesia/views/page/old/report/report_penjualan.dart';
import 'package:eahmindonesia/views/page/old/report/report_requeststock.dart';
import 'package:eahmindonesia/views/page/old/setor/setor.dart';
import 'package:eahmindonesia/views/page/old/inventory/inventory.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPusatPage extends StatefulWidget {
  final int currIndex;
  const MainPusatPage({super.key, required this.currIndex});

  @override
  State<MainPusatPage> createState() => _MainPusatPageState();
}

class _MainPusatPageState extends State<MainPusatPage> {
  int currentPageIndex = 0;

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilPage()),
    );
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    LocalNotification.initialize();

    // 1️⃣ Handle notification opened from TERMINATED state (if it’s a local notification)
    final details = await LocalNotification.getLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details!.notificationResponse?.payload;
      print("payload: $payload");
      print("testting");
      
      try {
        // Convert the payload string to a Map
        final Map<String, dynamic> payloadMap =
            LocalNotification.parsePayload(payload!);

        // Original navigation logic
        if (payloadMap['type'] == 'chat') {
          print('howww chat');
          _navigateToProfile();
        }
      } catch (e) {
        print('Error parsing payload: $e');
      }
      // if (payload == 'chat') {
      //   _navigateToProfile();
      // }
    }

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotification.showNotification(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    bootstrapGridParameters(
      gutterSize: 0,
    );
    currentPageIndex = widget.currIndex;
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;
    final ThemeData theme = Theme.of(context);
    return WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (lastPressed == null ||
              now.difference(lastPressed!) > const Duration(seconds: 2)) {
            lastPressed = now;

            Fluttertoast.showToast(
              msg: "Tekan sekali lagi untuk keluar",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );

            return false; // jangan keluar dulu
          }
          return true; // keluar aplikasi
        },
        child: Scaffold(
          backgroundColor: (currentPageIndex == 0)
              ? const Color(0xFF005F5B)
              : const Color(0xFFF5F5F5),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(20, 10),
                topRight: Radius.elliptical(20, 10),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0,
                    offset: Offset(0, -3))
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        color: Colors.green,
                        // fontWeight: FontWeight.bold,
                      );
                    }
                    return TextStyle(
                      color: Colors.grey[900],
                    );
                  },
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(20, 10),
                  topRight: Radius.elliptical(20, 10),
                ),
                child: NavigationBar(
                  // backgroundColor: const Color.fromARGB(255, 0, 48, 47),
                  backgroundColor: Colors.white,
                  onDestinationSelected: (int index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  indicatorColor: Colors.transparent,
                  selectedIndex: currentPageIndex,
                  elevation: 0,
                  destinations: <Widget>[
                    NavigationDestination(
                      icon: Image.asset(
                        'assets/images/logo-mob-apps.png',
                        // width: 0,
                        height: 25,
                        // color: Colors.white, // opsional kalau mau tint warna
                      ),
                      label: 'Beranda',
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        'assets/images/icon/checklist.png',
                        // width: 0,
                        height: 25,
                        // color: Colors.white, // opsional kalau mau tint warna
                      ),
                      label: 'Pembelian',
                    ),
                    NavigationDestination(
                      // icon: Badge(
                      //   label: Text('2'),
                      //   child: Icon(Icons.warehouse),
                      // ),
                      icon: Image.asset(
                        'assets/images/icon/sell.png',
                        // width: 0,
                        height: 25,
                        // color: Colors.white, // opsional kalau mau tint warna
                      ),
                      label: 'Penjualan',
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        'assets/images/icon/megaphone.png',
                        // width: 0,
                        height: 25,
                        // color: Colors.white, // opsional kalau mau tint warna
                      ),
                      label: 'Berita',
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        'assets/images/icon/settings.png',
                        // width: 0,
                        height: 25,
                        // color: Colors.white, // opsional kalau mau tint warna
                      ),
                      label: 'Setting',
                    )
                  ],
                ),
              ),
            ),
          ),
          body: <Widget>[
            /// Home page
            const DashboardPusatPage(),

            /// Pesanan page
            const PurchaseorderPage(),

            /// Stok page
            const SalesOrderPage(),

            // Setor Page
            const ReportRequestStock(),

            // Profile
            const ProfilPage(),
          ][currentPageIndex],
        ));
  }
}
