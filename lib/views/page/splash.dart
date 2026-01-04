import 'dart:developer';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/nofitication/get_fcm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final apiService = ApiServive();
  final storageService = StorageService();
  final userController = UserController(StorageService());

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 4, milliseconds: 5), () {
        _checkLoginStatus();
      },
    );
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final user = await userController.getUserFromStorage();
    // final outlet_id = await storageService.getOutletId();
    String? fcmKey = await getFcmToken();
    print('fcmKey: $fcmKey');
    // print(inspect(user));
    await AuthController(apiService, storageService).saveTokenApps(user?.token ?? '', user?.uid ?? '', fcmKey ?? '1');
    if (user != null) {
      GoRouter.of(context).go('/main_pusat');
    } else {
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00302F), // hijau tua (base)
              Color(0xFF005F5B), // hijau emerald
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tagline muncul di tengah, lalu hilang
            Text(
            "Ekonomi Tumbuh \nHasanah Menyatu",
            style: GoogleFonts.playfairDisplay(   // pake font elegan
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 1.2,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
                .animate()
                // fade in + naik dari bawah (slideY positif -> ke 0)
                .fadeIn(duration: 0.5.seconds, delay: 0.6.seconds)
                .slideY(begin: 0.8, end: 0, curve: Curves.easeOut)
                // stay 2 detik
                .then(delay: 1.seconds)
                // fade out + turun ke bawah lagi (slideY 0 -> +0.3)
                .fadeOut(duration: 0.5.seconds)
                .slideY(begin: 0, end: 0.8, curve: Curves.easeIn),

            // Logo: awal di bawah, lalu moveY ke tengah
            Positioned(
              bottom: 30,
              child: Image.asset(
                // "assets/images/logo-horizontal.png",
                "assets/images/logo-mob-apps.png",
                width: 200,
              )
                  .animate()
                  .moveY(
                    begin: 0, // tetap di bawah dulu
                    end: -(screenHeight / 2 - 90), // geser naik ke tengah
                    delay: 2.5.seconds, // mulai geser setelah tagline hilang
                    duration: 0.8.seconds,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
