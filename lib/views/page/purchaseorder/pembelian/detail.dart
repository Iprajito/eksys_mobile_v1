import 'dart:io';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/pembayaran.dart';
import 'package:Eksys/views/page/purchaseorder/penerimaan/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PembelianDetailPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  
  const PembelianDetailPage({super.key, this.token, this.userid, this.idencrypt});

  @override
  State<PembelianDetailPage> createState() => _PembelianDetailPageState();
}

class _PembelianDetailPageState extends State<PembelianDetailPage> {
  late PurchaseorderController purchaseorderController;
  PembelianModel? _pembelianModel;
  PembelianDetailModel? _pembelianDetailModel;

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
  bool showAll = false;
  bool showAll2 = false;

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
        _dataPembelian(widget.token.toString(), widget.userid.toString(), widget.idencrypt.toString());
        _dataPembelianDetail(widget.token.toString(), widget.idencrypt.toString());
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

  void _dataPembelian(String token, String userid, String idencrypt) async {
    PembelianModel? data =
        await purchaseorderController.getpembelianbyid(token, userid, idencrypt);
    if (mounted) {
      setState(() {
        _pembelianModel = data;
      });
    }
  }

  void _dataPembelianDetail(String token, String idencrypt) async {
    PembelianDetailModel? data =
        await purchaseorderController.getpembeliandetailbyid(token, idencrypt);
    if (mounted) {
      setState(() {
        _pembelianDetailModel = data;
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

  Future<void> toTambahPenerimaanPage(String idencrypt) async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation,
                  secondaryAnimation) => //DrawerExample(),
              TambahPenerimaanPage(token: widget.token, userid: widget.userid, idencrypt: idencrypt),
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
    //     purchaseorderController = PurchaseorderController();
    //     _dataPenerimaan(widget.token, widget.userid);
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
          // backgroundColor: Colors.red,
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
      if (dateStr == '' || dateStr == '0000-00-00') {
        return '-';
      } else {
        DateTime date = DateTime.parse(dateStr);
        final df = DateFormat('dd MMM yyyy', 'id_ID');
        return df.format(date);
      }
    }

    String getStatusText() {
      if (_pembelianModel == null ||
          _pembelianModel!.data.isEmpty ||
          _pembelianModel!.data[0].status == null) {
        return "";
      }

      String status = _pembelianModel!.data[0].status!;

      if (status == "Dikemas") {
        return "Pembelian sedang dalam pengemasan";
      } else if (status == "Dikirim") {
        return "Pembelian sedang dalam pengiriman";
      } else if (status == "Diterima") {
        return "Pembelian telah diterima";
      } else if (status == "Batal") {
        return "Pembelian telah dibatalkan";
      } else if (status == "Belum Bayar" || status == "Tunggu Pembayaran") {
        return "Menunggu pembayaran pembelian";
      }

      return status;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Rincian Pembelian", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFf3f6f9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BootstrapContainer(
                fluid: true, 
                children: [
                  BootstrapRow(
                    // height: 30,
                    children: [
                      BootstrapCol(
                        sizes: 'col-12',
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFB902), // Color.fromARGB(255, 1, 139, 132),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                            padding: const EdgeInsets.all(16),
                            child: BootstrapContainer(
                              fluid: true, 
                              children: [
                                BootstrapRow(
                                  // height: 30,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-12',
                                      child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) 
                                      : Text(getStatusText(),
                                          style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 17)),
                                    ),
                                  ],
                                ),
                            ]
                          )
                        ),
                      ),
                      BootstrapCol(
                        sizes: 'col-12',
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
                            padding: const EdgeInsets.all(16),
                            child: BootstrapContainer(
                              fluid: true, 
                              children: [
                                BootstrapRow(
                                  height: 25,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Text("No. Pembelian",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _pembelianModel == null
                                          ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                          : Text(_pembelianModel!.data[0].nopo.toString(), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                BootstrapRow(
                                  height: 25,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Text("Metode Pembayaran",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _pembelianModel == null
                                          ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                          : Text(_pembelianModel!.data[0].metode_bayar.toString(), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                BootstrapRow(
                                  height: 25,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Text("Invoice Pembelian",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _pembelianModel == null
                                          ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                          : Text(_pembelianModel!.data[0].nomor_si.toString(), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.grey[200]),
                                // ANIMASI
                                ExpandableSection(
                                  expand: showAll,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      BootstrapRow(
                                        height: 25,
                                        children: [
                                          BootstrapCol(
                                            sizes: 'col-6',
                                            child: Text("Tgl. Pembelian",
                                                style: TextStyle(
                                                    color: Colors.grey[800],fontSize: 16)),
                                          ),
                                          BootstrapCol(
                                            sizes: 'col-6',
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: _pembelianModel == null
                                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                                : Text(formatDate(_pembelianModel!.data[0].tglpo.toString()), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      BootstrapRow(
                                        height: 25,
                                        children: [
                                          BootstrapCol(
                                            sizes: 'col-6',
                                            child: Text("Tgl. Pembayaran DP",
                                                style: TextStyle(
                                                    color: Colors.grey[800],fontSize: 16)),
                                          ),
                                          BootstrapCol(
                                            sizes: 'col-6',
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: _pembelianModel == null
                                              ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                              : Text(formatDate(_pembelianModel!.data[0].tgl_dp.toString()), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // BootstrapRow(
                                      //   height: 25,
                                      //   children: [
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Text("Tgl. Pelunasan",
                                      //           style: TextStyle(
                                      //               color: Colors.grey[800],fontSize: 16)),
                                      //     ),
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Align(
                                      //         alignment: Alignment.bottomRight,
                                      //         child: Text("No. Pembelian", style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // BootstrapRow(
                                      //   height: 25,
                                      //   children: [
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Text("Tgl. Pengiriman",
                                      //           style: TextStyle(
                                      //               color: Colors.grey[800],fontSize: 16)),
                                      //     ),
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Align(
                                      //         alignment: Alignment.bottomRight,
                                      //         child: _pembelianModel == null
                                      //         ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                      //         : Text(formatDate(_pembelianModel!.data[0].tgl_sj.toString()), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // BootstrapRow(
                                      //   height: 25,
                                      //   children: [
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Text("Tgl. Pesanan Diterima",
                                      //           style: TextStyle(
                                      //               color: Colors.grey[800],fontSize: 16)),
                                      //     ),
                                      //     BootstrapCol(
                                      //       sizes: 'col-6',
                                      //       child: Align(
                                      //         alignment: Alignment.bottomRight,
                                      //         child: Text("No. Pembelian", style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      Divider(color: Colors.grey[200])
                                    ],
                                  ),
                                ),
                                // Visibility(
                                //   visible: showAll,
                                //   child: Divider(color: Colors.grey[200])
                                // ),
                                
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
                            ]
                          )
                        ),
                      ),
                    ],
                  ),
                ]
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
                          child: _pembelianModel == null
                              ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                              : Text(
                            _pembelianModel!.data[0].supplier.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      // height: 60,
                      children: [
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-12',
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: _pembelianDetailModel?.data?.map((prod) {
                              var nopo          = prod.nopo ?? "";
                              var pelanggan     = prod.pelanggan ?? "";
                              var namaproduk    = prod.namaproduk ?? "";
                              var qty           = int.tryParse(prod.qty?.toString() ?? "0") ?? 0;
                              var satuanproduk  = prod.satuanproduk ?? "";
                              var harga         = double.tryParse(prod.harga?.toString() ?? "0") ?? 0.0;
                              var jumlah        = double.tryParse(prod.jumlah?.toString() ?? "0") ?? 0.0;
                              var image         = prod.image ?? "";
                              return orderItemDetail(nopo,pelanggan,namaproduk,qty,satuanproduk,harga,jumlah,image);
                            }).toList() ?? []
                          ),
                        ),
                        BootstrapCol(
                          fit: FlexFit.tight,
                          sizes: 'col-md-12',
                          child: Column(
                            children: [
                              Divider(color: Colors.grey[200]),
                              // ANIMASI
                              ExpandableSection(
                                expand: showAll2,
                                child: BootstrapContainer(
                                fluid: true, 
                                children: [
                                  BootstrapRow(
                                    // height: 60,
                                    children: [
                                      BootstrapCol(
                                        fit: FlexFit.tight,
                                        sizes: 'col-md-12',
                                        child: Column(
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Subtotal Pembelian'),
                                                _pembelianModel == null ? const Text('Rp 0')
                                                : Text(CurrencyFormat.convertToIdr((int.parse(_pembelianModel!.data[0].subtotal.toString())),0)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Visibility(
                                              visible: _pelangganModel?.data[0].id_syaratbayar.toString() == '1' ? false : true,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Nominal DP 30%'),
                                                  _pembelianModel == null ? const Text('Rp 0') :
                                                  Text(CurrencyFormat.convertToIdr((int.parse(_pembelianModel!.data[0].jumlahdp.toString())),0)),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible: _pelangganModel?.data[0].id_syaratbayar.toString() == '1' ? false : true,
                                              child: const SizedBox(height: 8)
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Biaya Layanan'),
                                                _pembelianModel == null ? const Text('Rp 0') :
                                                Text(CurrencyFormat.convertToIdr((int.parse(_pembelianModel!.data[0].transaksifee.toString())),0)),
                                              ],
                                            ),
                                          ]
                                        )
                                      ),
                                    ]
                                  ),
                                  Divider(color: Colors.grey[200]),
                                ]),
                              ),
                              GestureDetector(
                              onTap: () => setState(() => showAll2 = !showAll2),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _pembelianModel == null ? const Text('Total 0 Produk, 0 Karton')
                                    : Text('Total ${CurrencyFormat.convertNumber((int.parse(_pembelianModel!.data[0].item.toString())),0)} Produk, ${CurrencyFormat.convertNumber((int.parse(_pembelianModel!.data[0].qty.toString())),0)} Karton'),
                                    
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _pembelianModel == null ? const Text('Rp 0')
                                        : Text(
                                            CurrencyFormat.convertToIdr((int.parse(_pembelianModel!.data[0].subtotal.toString())),0),
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Icon(
                                          showAll2 ? Icons.expand_less : Icons.expand_more, size: 17,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ]
                          )
                        )
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
                          child: const Text(
                            'Keterangan Pembelian',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    BootstrapRow(
                      height: 40,
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child:  _pembelianModel == null
                            ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                            : Text(
                              _pembelianModel!.data[0].keterangan.toString(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
      bottomNavigationBar: getStatusButton(_pembelianModel) ?? const SizedBox(),
    );
  }

  Widget? getStatusButton(_pembelianModel) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (_pembelianModel == null || _pembelianModel.data.isEmpty) {
      return null;
    }

    String status = _pembelianModel.data[0].status ?? "";

    // Tentukan tombol berdasarkan status
    Widget? actionButton;

    switch (status) {
      case "Belum Bayar":
        actionButton = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: (screenWidth / 2) - 10,
              child: ElevatedButton(
                onPressed: () => _batalPesanan(), //_batalPesanan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[500]!),
                  ),
                ),
                child: Text(
                  'Batal Pembelian',
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              width: (screenWidth / 2) - 10,
              child: ElevatedButton(
                onPressed: () => _pembayaran(), //_savePesanan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor:
                      const Color.fromARGB(255, 254, 185, 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                      color: Colors.grey[800], fontSize: 16),
                ),
              ),
            ),
          ],
        );
        // ElevatedButton(
        //   onPressed: () {
        //     print("Bayar Sekarang");
        //   },
        //   child: const Text("Bayar Sekarang"),
        // );
        break;

      case "Tunggu Pembayaran":
        actionButton = ElevatedButton(
          onPressed: () => navigateToPembayaranPage(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8),
            backgroundColor:
                const Color.fromARGB(255, 254, 185, 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Pembayaran',
            style: TextStyle(
                color: Colors.grey[800], fontSize: 16),
          ),
        );
        break;
      
      case "Dikemas":
        actionButton = null;
        break;

      case "Dikirim":
        actionButton = ElevatedButton(
          onPressed: () => toTambahPenerimaanPage(widget.idencrypt.toString()),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8),
            backgroundColor:
                const Color.fromARGB(255, 254, 185, 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Terima Pembelian',
            style: TextStyle(
                color: Colors.grey[800], fontSize: 16),
          ),
        );
        break;

      case "Diterima":
        actionButton = null;
        break;

      default:
        actionButton = null;
    }

    // Jika tidak ada tombol (misal status dibatalkan), tidak perlu bottom nav
    if (actionButton == null) return null;

    // Kembalikan tampilan lengkap bottom navigation bar
    // return Container(
    //   padding: const EdgeInsets.all(16),
    //   color: Colors.white,
    //   child: actionButton,
    // );

    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 1.0,
              spreadRadius: 2 //, offset: Offset(0, -3)
          )
        ],
      ),
      child: Container(
        height: 65,// 65,
        // width: (screenWidth/2),
        // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          // border: Border.all(color: Colors.white),
          color: Colors.white,
          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: actionButton
      )
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

  Widget orderItemDetail(String nopo, String pelanggan, String namaproduk, int qty, String satuanproduk, double harga, double jumlah, String image) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool? visibility = nopo.isEmpty ? false : true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                      satuanproduk,
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
                    CurrencyFormat.convertToIdr(harga, 0),
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
}

class ExpandableSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  const ExpandableSection({
    super.key,
    this.expand = false,
    required this.child,
  });

  @override
  _ExpandableSectionState createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> sizeAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    sizeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    if (widget.expand) controller.forward();
  }

  @override
  void didUpdateWidget(covariant ExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.expand ? controller.forward() : controller.reverse();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: widget.child,
      ),
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