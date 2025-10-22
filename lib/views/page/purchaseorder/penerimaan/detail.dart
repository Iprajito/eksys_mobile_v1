import 'dart:io';

import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/master_controller.dart';
import 'package:eahmindonesia/controllers/pesanan_controller.dart';
import 'package:eahmindonesia/controllers/purchaseorder_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/master_model.dart';
import 'package:eahmindonesia/models/old/pesanan_model.dart';
import 'package:eahmindonesia/models/pembelian_model.dart';
import 'package:eahmindonesia/models/penerimaan_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/pembayaran.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:eahmindonesia/main.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PenerimaanDetailPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  
  const PenerimaanDetailPage({super.key, this.token, this.userid, this.idencrypt});

  @override
  State<PenerimaanDetailPage> createState() => _PenerimaanDetailPageState();
}

class _PenerimaanDetailPageState extends State<PenerimaanDetailPage> {
  late PurchaseorderController purchaseorderController;
  PenerimaanModel? _penerimaanModel;
  PenerimaanDetailModel? _penerimaanDetailModel;

  late MasterController masterController;
  PelangganModel? _pelangganModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    _checkToken();
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
        purchaseorderController = PurchaseorderController();
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        purchaseorderController = PurchaseorderController();
        _dataPelanggan(userToken, userId);
        _dataPenerimaan(widget.token.toString(), widget.userid.toString(), widget.idencrypt.toString());
        _dataPenerimaanDetail(widget.token.toString(), widget.idencrypt.toString());
        isLoading = false;
      });
    }
  }

  void _dataPelanggan(token, userid) async {
    masterController = MasterController();
    PelangganModel? dataPelanggan = await masterController.getpelangganbyid(token, userid);
    if (mounted) {
      setState(() {
        _pelangganModel = dataPelanggan;
      });
    }
  }

  void _dataPenerimaan(String token, String userid, String idencrypt) async {
    PenerimaanModel? data = await purchaseorderController.getpenerimaanbyid(token, userid, idencrypt);
    if (mounted) {
      setState(() {
        _penerimaanModel = data;
      });
    }
  }

  void _dataPenerimaanDetail(String token, String idencrypt) async {
    PenerimaanDetailModel? data = await purchaseorderController.getpenerimaandetailbyid(token, idencrypt);
    if (mounted) {
      setState(() {
        _penerimaanDetailModel = data;
      });
    }
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> navigateToPembayaranPage() async {
    final result = await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PembelianPembayaranPage(token: widget.token, userid: widget.userid, idencrypt: widget.idencrypt),
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
    // if (result == 'refresh') {
    //   setState(() {
    //     _dataUser();
    //   });
    // }
  }

  void _pembayaran() async{
    showLoadingDialog(context: context);
    var response = await purchaseorderController.savePembelianVA(widget.token.toString(), widget.userid.toString(), widget.idencrypt.toString(),'Beli');
    if (response) {
      hideLoadingDialog(context);
      // Navigator.pop(context, 'refresh');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PembelianPembayaranPage(token: widget.token.toString(), userid: widget.userid.toString(), idencrypt: widget.idencrypt.toString()),
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
    } else {
      hideLoadingDialog(context);
      Fluttertoast.showToast(
          msg: "Gagal melakukan pembayaran",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _batalPesanan() async {
    showLoadingDialog(context: context);
    var response = await purchaseorderController.savePembelianBatal(widget.token.toString(), widget.userid.toString(), widget.idencrypt.toString());
    if (response) {
      hideLoadingDialog(context);
      Navigator.pop(context, 'refresh');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Detail Penerimaan", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFf3f6f9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.all(16),
                child: BootstrapContainer(
                  fluid: true,
                  children: [
                    BootstrapRow(
                      height: 30,
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Text("Informasi Penerimaan",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      height: 40,
                      children: [
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor GR',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _penerimaanModel!.data[0].nopu.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  formatDate(_penerimaanModel!.data[0].tgl_pu.toString()),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      height: 40,
                      children: [
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor Nota',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _penerimaanModel!.data[0].nonota.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Jth Tempo',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  formatDate(_penerimaanModel!.data[0].tgljthtempo.toString()),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      height: 40,
                      children: [
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor PO',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _penerimaanModel!.data[0].nopo.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-6',
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal PO',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _penerimaanModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  formatDate(_penerimaanModel!.data[0].tgl_po.toString()),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      height: 40,
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Supplier',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              _penerimaanModel == null
                              ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                              : Text(
                                _penerimaanModel!.data[0].supplier.toString(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.all(16),
                child: BootstrapContainer(
                  fluid: true,
                  children: [
                    BootstrapRow(
                      height: 30,
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Text("Data Penerimaan",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      // height: 60,
                      children: [
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-12',
                          child: SizedBox(
                            height: screenHeight / 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: _penerimaanDetailModel == null
                                ? const ListMenuShimmer(total: 4, circular: 4, height: 42)
                                : _penerimaanDetailModel!.data.isEmpty
                                    ? const Center(
                                        child: Text('Belum ada pesanan'))
                                    : ListView.builder(
                                        physics: ScrollPhysics(parent: ClampingScrollPhysics()),
                                        itemCount: _penerimaanDetailModel!.data.length,
                                        itemBuilder: (context, index) {
                                          var item = _penerimaanDetailModel!.data[index];
                                          var namaproduk = item.namaproduk.toString();
                                          var qty = int.parse(item.qty.toString());
                                          var satuanproduk = item.satuan_produk.toString();
                                          var harga = int.parse(item.harga.toString());
                                          var jumlah = int.parse( item.jumlah .toString());
                                          return orderItemDetail(index, namaproduk, qty, satuanproduk, harga, jumlah);
                                        },
                                      ),
                                )),
                                // Divider(height: 1, color: Colors.grey[200]),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 8),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       _penerimaanModel == null ? const Text('Total 0 Produk, 0 Karton')
                                //       : Text('Total ${CurrencyFormat.convertNumber((int.parse(_penerimaanModel!.data[0].item.toString())),0)} Produk, ${CurrencyFormat.convertNumber((int.parse(_penerimaanModel!.data[0].qty.toString())),0)} Karton'),
                                      
                                //       _penerimaanModel == null ? const Text('Rp 0')
                                //       : Text(
                                //           CurrencyFormat.convertToIdr((int.parse(_penerimaanModel!.data[0].subtotal.toString())),0),
                                //           style: TextStyle(
                                //               color: Colors.grey[800],
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.bold)),
                                //     ],
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderItem(String nopo, String tglpo, String supplier, String tipe_ppn, String syaratbayar, String keterangan) {
    
    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }
    
    return Container(
        // height: screenHeight * 0.085,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  buildBox("Nomor PO",nopo),
                  buildBox("Tanggal",formatDate(tglpo)),
                  buildBox("",""),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildBox("Supplier",supplier),
                  buildBox("Tipe Ppn",tipe_ppn),
                  buildBox("Syarat Bayar",syaratbayar),
                ]
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildBox("Keterangan",keterangan)
                ]
              ),
            ],
          ),
        )
      );
  }

  Widget orderItemDetail(int index, String namaproduk, int qty, String satuanproduk, int harga, int jumlah) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    var no = index + 1;
    Color? color = Colors.white;
    if (no%2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              color: color,
              // borderRadius: BorderRadius.circular(0),
            ),
            width: screenWidth,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaproduk, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('@ ${CurrencyFormat.convertToIdr(harga, 0)}',style: TextStyle(color: Colors.grey[800])),
                          Text('x $qty $satuanproduk',style: TextStyle(color: Colors.grey[800])),
                          Text(CurrencyFormat.convertToIdr(jumlah, 0),style: TextStyle(color: Colors.grey[800]))
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
        // Divider(color: Colors.grey[200])
      ],
    );
  }
}

Widget buildBox(String label, String value, {double? width, bool isBold = false}) {
  return Expanded(
    flex: width == null ? 1 : 0,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500),
          ),
        ],
      ),
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
        style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500),
      ),
    ],
  );
}