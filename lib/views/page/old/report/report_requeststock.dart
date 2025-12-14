import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class ReportRequestStock extends StatefulWidget {
  const ReportRequestStock({super.key});

  @override
  State<ReportRequestStock> createState() => _ReportRequestStockState();
}

class _ReportRequestStockState extends State<ReportRequestStock> {
  final authController = AuthController(ApiServive(), StorageService());
  final storageService = StorageService();
  final userController = UserController(StorageService());

  String userId = "", userToken = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      print('Valid Token');
      _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();

    if (mounted) {
      setState(() {
        isLoading = true;
      });

      setState(() {
        userId = user!.uid.toString();
        userToken = user.token.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF4D00), // orange Shopee
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row atas notif + jam dll
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "irwan.prajito",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "QRIS untuk Terima Uang",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          // List menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: const [
                _MenuItem(icon: Icons.person, title: "Profil Saya"),
                _MenuItem(icon: Icons.receipt, title: "Tagihan Saya", subtitle: "Gratis biaya admin"),
                _MenuItem(icon: Icons.card_giftcard, title: "Hadiah Harian", subtitle: "Klaim 50RB koin"),
                _MenuItem(icon: Icons.group, title: "Undang Teman", subtitle: "Bonus saldo s/d 1JT!"),
                _MenuItem(icon: Icons.confirmation_num, title: "Voucher Saya"),
                _MenuItem(icon: Icons.verified_user, title: "Verifikasi"),
                _MenuItem(icon: Icons.speed, title: "Shopee Meter", subtitle: "Ada misi berhadiah!"),
                _MenuItem(icon: Icons.credit_card, title: "Metode Pembayaran"),
                _MenuItem(icon: Icons.settings, title: "Pengaturan"),
                _MenuItem(icon: Icons.help_outline, title: "Pusat Bantuan"),
              ],
            ),
          ),

          // Bottom Nav
          Container(
            color: Colors.white,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 4,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Keuangan"),
                BottomNavigationBarItem(icon: Icon(Icons.qr_code, size: 32), label: "QRIS"),
                BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "ShopeeFood"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Saya"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _MenuItem({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: Colors.orange)) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}