import 'package:eahmindonesia/nofitication/localNotification.dart';
import 'package:eahmindonesia/views/page/dasboard.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:eahmindonesia/views/page/old/setor/setor.dart';
import 'package:eahmindonesia/views/page/old/inventory/inventory.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final int currIndex;
  const MainPage({super.key, required this.currIndex});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currIndex;

    LocalNotification.initialize();

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotification.showNotification(message);
    });

    // When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!mounted) return; // ✅ Ensure context still valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 17, 19, 21),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5.0,
                spreadRadius: 0,
                offset: Offset(0, -3))
          ],
        ),
        child: NavigationBar(
          backgroundColor: const Color.fromARGB(255, 254, 185, 3),
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: const Color.fromARGB(255, 255, 197, 2),
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home_sharp),
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              // icon: Badge(child: Icon(Icons.shopping_cart_sharp)),
              icon: Icon(Icons.shopping_cart_sharp),
              label: 'Pesanan',
            ),
            NavigationDestination(
              // icon: Badge(
              //   label: Text('2'),
              //   child: Icon(Icons.warehouse),
              // ),
              icon: Icon(Icons.warehouse_sharp),
              label: 'Inventory',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_sharp),
              label: 'Setor Saldo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_sharp),
              label: 'Profil',
            )
          ],
        ),
      ),
      body: <Widget>[
        /// Home page
        const DashboardPage(),

        /// Pesanan page

        /// Stok page
        const InventoryPage(),

        // Setor Page
        const SetorPage(),

        // Profile
        const ProfilPage(),
      ][currentPageIndex],
    );
  }
}
