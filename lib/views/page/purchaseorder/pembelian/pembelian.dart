import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/controllers/purchaseorder_controller.dart';
import 'package:eahmindonesia/models/pembelian_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/detail.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/pembayaran.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/tambah.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembelianPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const PembelianPage({super.key, this.token, this.userid});

  @override
  State<PembelianPage> createState() => _PembelianPageState();
}

class _PembelianPageState extends State<PembelianPage> {
  late PurchaseorderController purchaseorderController;
  PembelianModel? _pembelianModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    purchaseorderController = PurchaseorderController();
    _checkToken();
    _dataPesanan(widget.token, widget.userid);
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
              TambahPembelianPage(token: widget.token, userid: widget.userid),
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
        _dataPesanan(widget.token, widget.userid);
      });
    }
  }

  Future<void> toDetailPesananPage(
      String token, String userid, String idencrypt) async {
    // Use await so that we can run code after the child page is closed
    // print("Navigating to detail page with idencrypt: $idencrypt");
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PembelianDetailPage(
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
        _dataPesanan(widget.token, widget.userid);
      });
    }
  }

  Future<void> navigateToPembayaranPage(String token, String userid, String idencrypt) async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PembelianPembayaranPage(token: token, userid: userid, idencrypt: idencrypt),
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
        _dataPesanan(widget.token, widget.userid);
      });
    }
  }

  void _dataPesanan(token, userid) async {
    PembelianModel? dataPembelian =
        await purchaseorderController.getpembelian(token, userid);
    if (mounted) {
      setState(() {
        _pembelianModel = dataPembelian;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: RefreshIndicator(
          onRefresh: () async {
            _dataPesanan(widget.token, widget.userid);
          },
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _pembelianModel == null
                    ? const ListMenuShimmer(total: 5)
                    : _pembelianModel!.data.length == 0
                        ? const Center(child: Text('Belum ada pesanan'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _pembelianModel!.data.length,
                            itemBuilder: (context, index) {
                              var id = _pembelianModel!.data[index].id.toString();
                              var idencrypt = _pembelianModel!
                                  .data[index].idencrypt
                                  .toString();
                              var nopo =
                                  _pembelianModel!.data[index].nopo.toString();
                              var tglpo =
                                  _pembelianModel!.data[index].tglpo.toString();
                              var supplier = _pembelianModel!.data[index].supplier
                                  .toString();
                              var subtotal = _pembelianModel!.data[index].subtotal
                                  .toString();
                              var status =
                                  _pembelianModel!.data[index].status.toString();
                              var grandtotal = _pembelianModel!
                                  .data[index].grandtotal
                                  .toString();
                              var keterangan = _pembelianModel!
                                  .data[index].keterangan
                                  .toString();
                              var ispu = _pembelianModel!.data[index].ispu.toString();
                              var item = _pembelianModel!.data[index].item.toString();
                              var qty = _pembelianModel!.data[index].qty.toString();
                              return orderItem(
                                  id,
                                  idencrypt,
                                  nopo,
                                  tglpo,
                                  supplier,
                                  int.parse(subtotal),
                                  status,
                                  int.parse(grandtotal),
                                  keterangan,
                                  ispu,item,qty);
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

  Widget orderItem(
      String id,
      String idencrypt,
      String nopo,
      String tglpo,
      String supplier,
      int subtotal,
      String status,
      int grandtotal,
      String keterangan,
      String ispu, String item, String qty) {
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
                        nopo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        formatDate(tglpo),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        supplier,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        status,
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
                      Text(
                        'Total ${CurrencyFormat.convertNumber(int.parse(item), 0)} Produk, ${CurrencyFormat.convertNumber(int.parse(qty), 0)} Karton',
                        style: const TextStyle(fontSize: 14),
                      ),
                      _labelValue('Grand Total',
                          CurrencyFormat.convertToIdr(grandtotal, 0),
                          isBold: true),
                    ],
                  ),
                ],
              ),
            )),
        onTap: () {
          if (status == 'Tunggu Pembayaran') {
            navigateToPembayaranPage(widget.token.toString(), widget.userid.toString(), idencrypt);
          } else {
            toDetailPesananPage(widget.token.toString(), widget.userid.toString(), idencrypt);
          }
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
