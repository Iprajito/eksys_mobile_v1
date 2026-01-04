import 'dart:io';

import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/pesanan_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/old/pesanan_model.dart';
import 'package:Eksys/views/page/salesorder/penjualan/tambah.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscribePage extends StatefulWidget {
  final String? id;
  final String? token;

  const SubscribePage({super.key, this.id, this.token});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  String? _metodebayar = '1';
  int? _selectedMetodeBayar = 2;
  String? _selectedSubscribe = "1 Bulan";

  String? metode_id;
  String? metode_channel;
  String? metode_institusi;
  String? metode_tipe = "Bank";

  late MasterController masterController;
  SubscribeModel? _subscribeModel;

  @override
  void initState() {
    super.initState();
    _dataSubscribe(widget.token.toString(), widget.id.toString());
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataSubscribe(token, userid) async {
    masterController = MasterController();
    SubscribeModel? dataSubscribe = await masterController.getSubscribe(token, userid);
    if (mounted) {
      setState(() {
        _subscribeModel = dataSubscribe;
      });
    }
  }

  void _handleRadioValueChange(String? value) {
    setState(() {
      _metodebayar = value;
      // print(_metodebayar);
    });
  }

  void _savePesanan() async {
    masterController = MasterController();
    showLoadingDialog(context: context);
    masterController = MasterController();
    var response = await masterController.getSubscribe(
        (widget.token).toString(), widget.id.toString());
    if (response != null) {
      hideLoadingDialog(context);
      Navigator.pop(context, 'refresh');
    }

    // final NavigatorState navigator = Navigator.of(context);
    // final bool shouldPop = await _konfirmasiPrint();
    // if (shouldPop == false) {
    //   // plus print nota
    //   // navigator.pop();
    // } else {
    //   Navigator.pop(context, 'refresh');
    // }
  }

  void _delPesanan() async {
    masterController = MasterController();
    showLoadingDialog(context: context);
    masterController = MasterController();
    var response = await masterController.getSubscribe(
        (widget.token).toString(), widget.id.toString());
    if (response != null) {
      hideLoadingDialog(context);
      Navigator.pop(context, 'refresh');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  Future<void> navigateToMetodeBayarPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  MetodeBayarPage(
                      token: widget.token,
                      userid: widget.id,
                      metodeId: metode_id),
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
    if (result != null) {
      setState(() {
        // misal tampilkan nama supplier yang dipilih
        metode_id = result["metode_id"];
        metode_channel = result["metode_channel"];
        metode_institusi = result["metode_institusi"];
        metode_tipe = result["metode_tipe"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final dataSubscribe = _subscribeModel?.data.toList() ?? [];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            // Icon(Icons.shopping_cart),
            SizedBox(width: 5),
            Text("Langganan",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: 
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                child: Text("Durasi Langganan",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dataSubscribe.map((prod) {
                              // return productItem(prod.image,prod.namaproduk,prod.satuan_produk,prod.qty,prod.harga);
                              return _buildSubscribeOption(prod.subscribe.toString(), int.parse(prod.harga.toString()), int.parse(prod.id.toString()), null);
                            }).toList(),
                          ),
                          // BootstrapRow(
                          //     // height: 60,
                          //     children: [
                          //       BootstrapCol(
                          //           fit: FlexFit.tight,
                          //           sizes: 'col-md-12',
                          //           child: Column(
                          //             children: [
                          //               Row(
                          //                 children: [
                          //                   Expanded(
                          //                     child: _buildSubscribeOption(
                          //                         "1 Bulan", 1, null),
                          //                   ),
                          //                   const SizedBox(width: 10),
                          //                   Expanded(
                          //                     child: _buildSubscribeOption(
                          //                         "3 Bulan", 2, null),
                          //                   ),
                          //                 ],
                          //               ),
                          //               const SizedBox(height: 10),
                          //               Row(
                          //                 children: [
                          //                   Expanded(
                          //                     child: _buildSubscribeOption(
                          //                         "6 Bulan", 3, null),
                          //                   ),
                          //                   const SizedBox(width: 10),
                          //                   Expanded(
                          //                     child: _buildSubscribeOption(
                          //                         "12 Bulan", 4, null),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ))
                          //     ])
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.all(16),
                      child:paymentMethod()
                    ),
                  ],
                ),
            ),
          ),
    );
  }

  Widget orderItemDetail(String name, int qty, int price, int subtotal) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '@ ${CurrencyFormat.convertToIdr((price), 0)}',
                  style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                ),
                Text(
                  'x$qty',
                  style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                ),
                Text(
                  CurrencyFormat.convertToIdr(subtotal, 0),
                  style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                ),
              ],
            ),
          ],
        ));
  }

  Widget paymentMethod() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(0.0),
      child: BootstrapContainer(
        fluid: true,
        children: [
          BootstrapRow(
            height: 30,
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Metode Pembayaran",
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    GestureDetector(
                      onTap: () => navigateToMetodeBayarPage(),
                      child: Row(
                        children: [
                          Text('Lihat Semua',
                              style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(width: 5),
                          Icon(Icons.arrow_forward_ios,
                              size: 12, color: Colors.grey[500])
                        ],
                      ),
                    )
                  ],
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
                    child: SizedBox(
                      // height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPaymentOption(
                              2,
                              (metode_tipe == 'Bank')
                                  ? "Transfer Bank"
                                  : "Bayar Tunai di Mitra/Agen",
                              metode_institusi.toString(),
                              FontAwesomeIcons.rightLeft),
                          Divider(height: 16, color: Colors.grey[300]),
                          _buildPaymentOption(3, "COD", "Cash on Delivery",
                              FontAwesomeIcons.wallet)
                        ],
                      ),
                    ))
              ])
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      int value, String label, String subLabel, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (subLabel == 'null') {
          navigateToMetodeBayarPage();
        } else {
          setState(() {
            _selectedMetodeBayar = value;
          });
        }
      },
      child: Container(
        // margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          // border: Border.all(
          //   color: Colors.grey.shade400,
          // ),
        ),
        child: Row(
          children: <Widget>[
            // Icon(icon, color: Colors.amber, size: 20),
            FaIcon(icon,
                color: const Color.fromARGB(255, 254, 185, 3), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Visibility(
                      visible: (subLabel == 'null') ? false : true,
                      child: Text(
                        subLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ))
                ],
              ),
            ),
            _selectedMetodeBayar == value
                ? Icon(Icons.check_circle, color: Colors.amber, size: 20)
                : Icon(Icons.circle, color: Colors.grey[300], size: 20)
            // Transform.scale(
            //   scale: 0.8,
            //   child: Radio<int>(
            //     value: value,
            //     groupValue: _selectedMetodeBayar,
            //     onChanged: (int? newValue) {
            //       setState(() {
            //         _selectedMetodeBayar = newValue;
            //       });
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeOption(String label, int price, int option, double? screenWidth) {
    final buttonWidth = screenWidth == null ? double.infinity : (screenWidth / 2) - 10;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: buttonWidth,
        height: 50,
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: _selectedSubscribe == label
                  ? const Color(0xFFFFB902)
                  : const Color(0xFFfcf5e1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              side: const BorderSide(
                width: 1.0,
                color: Color(0xFFFFB902),
              )),
          onPressed: () {
            setState(() {
              _selectedSubscribe = label;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                CurrencyFormat.convertToIdr(price, 0),
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
