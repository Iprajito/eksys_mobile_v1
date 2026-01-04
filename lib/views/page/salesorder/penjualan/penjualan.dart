import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/salesorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/models/penjualan_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/tambah.dart';
import 'package:Eksys/views/page/salesorder/penjualan/detail.dart';
import 'package:Eksys/views/page/salesorder/penjualan/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PenjualanPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const PenjualanPage({super.key, this.token, this.userid});

  @override
  State<PenjualanPage> createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  late SalesorderController salesorderController;
  PenjualanModel? _penjualanModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _dataPenjualan(widget.token, widget.userid);
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

  Future<void> toTambahPesananPage() async {
    // Use await so that we can run code after the child page is closed
    var nota = "TEst123"; // You can generate or pass the nota as needed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation,
                  secondaryAnimation) => //DrawerExample(),
              TambahPenjualanPage(token: widget.token, userid: widget.userid),
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
        _dataPenjualan(widget.token, widget.userid);
      });
    }
  }

  Future<void> toDetailPesananPage(
      String token, String userid, String idencrypt) async {
    // Use await so that we can run code after the child page is closed
    print("Navigating to detail page with idencrypt: $idencrypt");
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PenjualanDetailPage(
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
        _dataPenjualan(widget.token, widget.userid);
      });
    }
  }

  void _dataPenjualan(token, userid) async {
    salesorderController = SalesorderController();
    PenjualanModel? data = await salesorderController.getpenjualan(token, userid);
    if (mounted) {
      setState(() {
        _penjualanModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: RefreshIndicator(
          onRefresh: () async {
            _dataPenjualan(widget.token, widget.userid);
          },
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _penjualanModel == null
                    ? const ListMenuShimmer(total: 5)
                    : _penjualanModel!.data.length == 0
                        ? const Center(child: Text('Belum ada pesanan'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _penjualanModel!.data.length,
                            itemBuilder: (context, index) {
                              return orderItem(_penjualanModel!.data[index]);
                            }),
              ))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 0, 48, 47),
            onPressed: toTambahPesananPage,
            child: const Icon(Icons.add_outlined, color: Colors.white)));
  }

  Widget orderItem(Penjualan data) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.nomor_so.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        formatDate(data.tgl_so.toString()),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.pelanggan.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        data.status.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.amber[900]),
                      )
                    ],
                  ),
                  Divider(height: 16, color: Colors.grey[300]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _labelValue('Subtotal', CurrencyFormat.convertToIdr(subtotal, 0)),
                      // _labelValue('Total Item', CurrencyFormat.convertNumber(ppn, 0)),
                      // Text(
                      //   'Total ${CurrencyFormat.convertNumber(int.parse(item), 0)} Produk, ${CurrencyFormat.convertNumber(int.parse(qty), 0)} Karton',
                      //   style: const TextStyle(fontSize: 14),
                      // ),
                      _labelValue('PO Customer',
                          data.pembelian_nopo.toString(),
                          isBold: true),
                      _labelValue('Grand Total',
                          CurrencyFormat.convertToIdr(int.parse(data.grandtotal.toString()), 0),
                          isBold: true),
                    ],
                  ),
                ],
              ),
            )),
        onTap: () {
          toDetailPesananPage(widget.token.toString(), widget.userid.toString(), data.id_encrypt.toString());
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
