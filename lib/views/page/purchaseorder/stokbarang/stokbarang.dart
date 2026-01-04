import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/models/penerimaan_model.dart';
import 'package:Eksys/models/stokbarang_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/penerimaan/detail.dart';
import 'package:Eksys/views/page/purchaseorder/penerimaan/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StokBarangPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const StokBarangPage({super.key, this.token, this.userid});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  late PurchaseorderController purchaseorderController;
  StokBarangModel? _stokbarangModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    purchaseorderController = PurchaseorderController();
    _checkToken();
    _dataStokBarang(widget.token, widget.userid);
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
    // print(user?.user_group.toString());
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

  Future<void> toDetailStokBarangPage(
      String token, String userid, String idencrypt) async {
    // Use await so that we can run code after the child page is closed
    print("Navigating to detail page with idencrypt: $idencrypt");
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PenerimaanDetailPage(
                      token: token, userid: userid, idencrypt: idencrypt),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Slide from right
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        purchaseorderController = PurchaseorderController();
        _dataStokBarang(widget.token, widget.userid);
      });
    }
  }

  void _dataStokBarang(token, userid) async {
    StokBarangModel? data = await purchaseorderController.getmutasistok(token, userid);
    if (mounted) {
      setState(() {
        _stokbarangModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: RefreshIndicator(
          onRefresh: () async {
            _dataStokBarang(widget.token, widget.userid);
          },
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _stokbarangModel == null
                    ? const ListMenuShimmer(total: 5)
                    : _stokbarangModel!.data.length == 0
                        ? const Center(child: Text('Belum ada pesanan'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _stokbarangModel!.data.length,
                            itemBuilder: (context, index) {
                              return orderItem(_stokbarangModel!.data[index]);
                            }),
              ))
            ],
          ),
        ),
      );
  }

  Widget orderItem(StokBarang data) {
    double screenWidth = MediaQuery.of(context).size.width;

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return GestureDetector(
        child: Container(
            // height: screenHeight * 0.085,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar produk dengan border
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data.image.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Detail produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.namaproduk.toString(),
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 4),
                        Text(
                          'Stok : ${data.stok.toString()}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            )
        ),
        onTap: () {
          // toDetailStokBarangPage(widget.token.toString(), widget.userid.toString(), data.id_encrypt.toString());
        });
  }
}

Widget _labelValue(String label, String value, {bool isBold = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500),
      ),
    ],
  );
}
