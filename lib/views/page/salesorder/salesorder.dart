import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/pembelian.dart';
import 'package:Eksys/views/page/purchaseorder/penerimaan/penerimaan.dart';
import 'package:Eksys/views/page/purchaseorder/stokbarang/stokbarang.dart';
import 'package:Eksys/views/page/salesorder/penjualan/penjualan.dart';
import 'package:flutter/material.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key});

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _dataUser();
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
      // print('Valid Token');
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
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Row(
            children: [
              // Icon(Icons.shopping_cart),
              SizedBox(width: 5),
              Text("Penjualan",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
          // bottom: const TabBar(
          //   labelColor: Colors.white,
          //   indicatorColor: Colors.white70,
          //   unselectedLabelColor: Colors.white70,
          //   tabs: [
          //     Tab(text: 'Penjualan'),
          //     Tab(text: 'Pengiriman'),
          //     Tab(text: 'Invoice'),
          //   ],
          // ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading ? const Text('') : PenjualanPage(token: userToken, userid: userId)
        // TabBarView(
        //   children: [
        //     isLoading ? const Text('') : PenjualanPage(token: userToken, userid: userId),
        //     const Text('Pengiriman'),
        //     const Text('Invoice')
        //     // isLoading ? const Text('') : PenerimaanPage(token: userToken, userid: userId),
        //     // isLoading ? const Text('') : StokBarangPage(token: userToken, userid: userId),
        //   ],
        // ),
      ),
    );
  }
}
