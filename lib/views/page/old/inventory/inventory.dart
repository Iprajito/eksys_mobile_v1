import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/old/inventory/pembelian.dart';
import 'package:eahmindonesia/views/page/old/inventory/request.dart';
import 'package:eahmindonesia/views/page/old/inventory/stock.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final storageService = StorageService();
  final userController = UserController(StorageService());

  String userId = "",
      userName = "",
      userEmail = "",
      userOutletId = "",
      userOutletName = "",
      userToken = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _dataUser();
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      print('Valid Token');
      // _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();
    final outlet_id = await storageService.getOutletId();
    final outlet_name = await storageService.getOutletName();
    setState(() {
      isLoading = true;
    });
    setState(() {
      userId = user!.uid.toString();
      userName = user.name.toString();
      userEmail = user.email.toString();
      userOutletId = outlet_id.toString();
      userOutletName = outlet_name.toString();
      userToken = user.token.toString();
      isLoading = false;
    });
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
              Text("Inventory",
                  style: TextStyle(
                      color: Color.fromARGB(255, 17, 19, 21),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          backgroundColor: const Color(0xFFFFB902),
          bottom: const TabBar(
            labelColor: Color.fromARGB(255, 17, 19, 21),
            indicatorColor: Color(0xFF9C7100),
            tabs: [
              Tab(text: 'Stock'),
              Tab(text: 'Request & Supply'),
              Tab(text: 'Pembelian'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: TabBarView(
          children: [
            isLoading ? const Text('') : StockPage(token : userToken, outletId: userOutletId),
            isLoading ? const Text('') : RequestInventoryPage(token : userToken, outletId: userOutletId),
            isLoading ? const Text('') : PembelianInventoryPage(token : userToken, outletId: userOutletId),
          ],
        ),
      ),
    );
  }
}
