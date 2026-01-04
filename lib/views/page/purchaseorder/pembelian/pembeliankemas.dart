import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/pembayaran.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembelianKemasPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const PembelianKemasPage({super.key, this.token, this.userid});

  @override
  State<PembelianKemasPage> createState() => _PembelianKemasPageState();
}

class _PembelianKemasPageState extends State<PembelianKemasPage> {
  late PurchaseorderController purchaseorderController;
  PembelianModel? _pembelianModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;
  bool showAll = false;
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

  void _dataPesanan(token, userid) async {
    PembelianModel? dataPembelian =
        await purchaseorderController.getpembelian(token, userid, 'Lunas');
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
                              var product = _pembelianModel!.data[index].product;
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
                                  ispu,item,qty,product!);
                            }),
              ))
            ],
          ),
        ),
    );
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
      String ispu, String item, String qty, List product) {
    double screenWidth = MediaQuery.of(context).size.width;

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    final displayedProducts = showAll ? product : product.take(1).toList();
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
                        supplier,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Dikemas',
                        style: TextStyle(fontSize: 14, color: Colors.amber[900]),
                      )
                      // Text(
                      //   formatDate(tglpo),
                      //   style: TextStyle(color: Colors.grey[600]),
                      // ),
                    ],
                  ),
                  // const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayedProducts.map((prod) {
                      return productItem(prod.image,prod.namaproduk,prod.satuan_produk,prod.qty,prod.harga);
                    }).toList(),
                  ),
                  // Tombol toggle jika produk lebih dari 1
                  const SizedBox(height: 8),
                  if (product.length > 1)
                    GestureDetector(
                      onTap: () => setState(() => showAll = !showAll),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(showAll ? "Sembunyikan" : "Lihat Semua"
                          ),
                          Icon(
                            showAll ? Icons.expand_less : Icons.expand_more, size: 17,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total ${CurrencyFormat.convertNumber(int.parse(item), 0)} Produk : ',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(grandtotal, 0),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        onTap: () {
          toDetailPesananPage(widget.token.toString(), widget.userid.toString(), idencrypt);
        });
  }
}

Widget productItem(image,namaproduk,satuan,qty,harga) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
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
              image,
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
                namaproduk,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    satuan,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    'x${qty}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  CurrencyFormat.convertToIdr(int.parse(harga), 0),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
