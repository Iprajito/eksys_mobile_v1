import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/pembelian.dart';
import 'package:eahmindonesia/views/page/purchaseorder/penerimaan/penerimaan.dart';
import 'package:eahmindonesia/views/page/purchaseorder/stokbarang/stokbarang.dart';
import 'package:flutter/material.dart';

class PurchaseorderPage extends StatefulWidget {
  const PurchaseorderPage({super.key});

  @override
  State<PurchaseorderPage> createState() => _PurchaseorderPageState();
}

class _PurchaseorderPageState extends State<PurchaseorderPage> {
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
              Text("Pembelian",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white70,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Pembelian'),
              Tab(text: 'Penerimaan Barang'),
              Tab(text: 'Stok Barang'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: TabBarView(
          children: [
            isLoading ? const Text('') : PembelianPage(token: userToken, userid: userId),
            isLoading ? const Text('') : PenerimaanPage(token: userToken, userid: userId),
            isLoading ? const Text('') : StokBarangPage(token: userToken, userid: userId),
            //isLoading ? const Text('') : SelesaiPurchaseorderPage(token : userToken, outletId: userOutletId),
          ],
        ),
      ),
    );
  }
}
