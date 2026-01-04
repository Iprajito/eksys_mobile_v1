import 'dart:async';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:pocketbase/pocketbase.dart';

class PenjualanPembayaranPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  
  const PenjualanPembayaranPage({super.key, this.token, this.userid, this.idencrypt});

  @override
  State<PenjualanPembayaranPage> createState() => _PenjualanPembayaranPageState();
}

class _PenjualanPembayaranPageState extends State<PenjualanPembayaranPage> {
  late DateTime targetDateTime;
  Duration remaining = Duration.zero;
  Timer? timer;
  bool isFinished = false;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  late PurchaseorderController purchaseorderController;
  PembelianVAModel? _pembelianVAModel;
  
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true;

  List<Map<String, dynamic>> records = [];
  final pb = PocketBase('https://pb.pemapi.com');
  
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  String formatInGroupsOf4(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[i]);
      // tambahkan spasi tiap 4 digit, kecuali kalau sudah di akhir string
      if ((i + 1) % 4 == 0 && i + 1 != input.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        remaining = targetDateTime.difference(now);
        if (remaining.isNegative || remaining.inSeconds == 0) {
          remaining = Duration.zero;
          isFinished = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours jam $minutes menit $seconds detik";
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
        _dataPembayaran(userToken, userId);
      });
    }
  }

  Future<void> fetchAllRecords(String trxId) async {
    final result = await pb.collection('trx_penjualan_va').getList(
      filter: 'trxId="${trxId}"'
    );
    // setState(() {
    //   isLoading = true;
    // });
    setState(() {
      records = result.items.map((item) {
        // Gunakan .get<String>() untuk mengambil nama file tunggal
        final String fileName = item.get<String>('file_attach', '');
        
        String fileUrl = '';

        // Jika ada nama file, buat URL-nya
        if (fileName.isNotEmpty) {
          // Gunakan pb.files.getUrl untuk membuat URL file
          final url = pb.files.getUrl(item, fileName);
          fileUrl = url.toString();
        }

        return {
          'id': item.id,
          'trxId': item.data['trxId'] ?? '',
          'nopo': item.data['nopo'] ?? '',
          'virtual_account_no': item.data['virtual_account_no'] ?? '',
          'virtual_account_name': item.data['virtual_account_name'] ?? '',
          'total_amount': item.data['total_amount'] ?? '',
          'expired_date': item.data['expired_date'] ?? '',
          'status': item.data['status'] ?? '',
        };
      }).toList();
      isLoading = false;
      // print('isLoading ${isLoading}');
    });
  }

  void subscribeToCollectionChanges() {
    pb.collection('trx_penjualan_va').subscribe('*', (e) {
      setState(() {
        final id = e.record?.id;
        if (e.action == 'create') {
          records.add({
            'id': id,
            'trxId': e.record?.data['trxId'] ?? '',
            'nopo': e.record?.data['nopo'] ?? '',
            'virtual_account_no': e.record?.data['virtual_account_no'] ?? '',
            'virtual_account_name': e.record?.data['virtual_account_name'] ?? '',
            'total_amount': e.record?.data['total_amount'] ?? '',
            'expired_date': e.record?.data['expired_date'] ?? '',
            'status': e.record?.data['status'] ?? ''
          });
        } else if (e.action == 'update') {
          final index = records.indexWhere((r) => r['id'] == id);
          if (index != -1) {
            records[index] = {
              'id': id,
              'trxId': e.record?.data['trxId'] ?? '',
              'nopo': e.record?.data['nopo'] ?? '',
              'virtual_account_no': e.record?.data['virtual_account_no'] ?? '',
              'virtual_account_name': e.record?.data['virtual_account_name'] ?? '',
              'total_amount': e.record?.data['total_amount'] ?? '',
              'expired_date': e.record?.data['expired_date'] ?? '',
              'status': e.record?.data['status'] ?? ''
            };
          }
          if (e.record?.data['status'] == 'Lunas') {
            showLunasDialog(context: context);
          }
        } else if (e.action == 'delete') {
          records.removeWhere((r) => r['id'] == id);
        }
      });
    });
  }

  void showLunasDialog({
    required BuildContext context,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_sharp, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Pembayaran"),
            ],
          ),
          content: const Text(
            "Selamat pembayaran anda telah berhasil!",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context); // Close the dialog
            //   },
            //   child: Text("Cancel"),
            // ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, 'refresh');
                Navigator.pop(context, 'refresh');
              },
              child: Text("OK", style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _dataPembayaran(token, userid) async {
    purchaseorderController = PurchaseorderController();
    PembelianVAModel? dataPelanggan = await purchaseorderController.getvabypembelianid(token, userid, widget.idencrypt.toString());
    if (mounted) {
      setState(() {
        _pembelianVAModel = dataPelanggan;
        targetDateTime = DateTime.parse(_pembelianVAModel!.data[0].expired_date.toString());
        print('isLoading ${isLoading}');
        fetchAllRecords(_pembelianVAModel!.data[0].trx_id.toString());
        subscribeToCollectionChanges();
        _startCountdown();
        // isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    timer?.cancel();
    pb.collection('trx_penjualan_va').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
        title: const Text("Pembayaran", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
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
                  child: SizedBox(
                    // height: 120,
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        // isLoading ? Text('data') : Text('${records[0]['status']}'),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianVAModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nomor PO',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text('${_pembelianVAModel?.data[0].nopo.toString()}',
                                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianVAModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Pembayaran',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormat.convertToIdr((int.parse(_pembelianVAModel!.data[0].total_amount.toString())),0),
                                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianVAModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Bayar Dalam',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      isFinished ? "Waktu Habis" : _formatDuration(remaining),
                                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    )
                  )
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    // height: 120,
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianVAModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) 
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _pembelianVAModel!.data[0].bank.toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No. Rekening',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _pembelianVAModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatInGroupsOf4(_pembelianVAModel!.data[0].virtual_account_no.toString()),
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.amber[900]!,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            copyToClipboard(_pembelianVAModel!.data[0].virtual_account_no.toString());
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                            size: 20,
                                            color: Color.fromARGB(255, 22, 142, 197),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Proses verifikasi kurang dari 10 menit setelah pembayaran berhasil',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 22, 142, 197),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Penting: Pastikan kamu mentransfer ke Virtual Account yang tertera di atas.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Hanya menerima dari ${_pembelianVAModel?.data[0].bank.toString()}.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Pastikan Merchant adalah ${_pembelianVAModel?.data[0].virtual_account_name.toString()}.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    )
                  )
              ),
              // const SizedBox(height: 8),
              // Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(8.0)),
              //     padding: const EdgeInsets.all(16),
              //     child: SizedBox(
              //       child: Column(
              //         children: [
              //           Theme(
              //             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              //             child: const ExpansionTile(
              //               tilePadding: EdgeInsets.zero,   // hilangkan padding kiri/kanan
              //               childrenPadding: EdgeInsets.zero,
              //               minTileHeight: 0,
              //               title: Text("Petunjuk Transfer mBanking"),
              //               children: [
              //                 Align(
              //                   alignment: Alignment.centerLeft,
              //                   child: Text("1. Pilih m-Transfer > BCA Virtual Account")
              //                 ),
              //                 SizedBox(height: 8),
              //                 Align(
              //                   alignment: Alignment.centerLeft,
              //                   child: Text("2. Pilih m-Transfer > BCA Virtual Account")
              //                 ),
              //                 SizedBox(height: 8),
              //                 Align(
              //                   alignment: Alignment.centerLeft,
              //                   child: Text("3. Pilih m-Transfer > BCA Virtual Account")
              //                 )
              //               ],
              //             ),
              //           )
              //         ],
              //       ),
              //     )
              // ),
              // const SizedBox(height: 8),
              // Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(8.0)),
              //     padding: const EdgeInsets.all(16),
              //     child: SizedBox(
              //       child: Column(
              //         children: [
              //           Theme(
              //             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              //             child: const ExpansionTile(
              //               tilePadding: EdgeInsets.zero,   // hilangkan padding kiri/kanan
              //               childrenPadding: EdgeInsets.zero,
              //               minTileHeight: 0,
              //               title: Text("Petunjuk Transfer iBanking"),
              //               children: const [
              //                 Align(
              //                   alignment: Alignment.centerLeft,
              //                   child: Text("Theme.of(context).copyWith(dividerColor: Colors.black12)")
              //                 )
              //               ],
              //             ),
              //           )
              //         ],
              //       ),
              //     )
              // ),
              // const SizedBox(height: 8),
              // Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(8.0)),
              //     padding: const EdgeInsets.all(16),
              //     child: SizedBox(
              //       child: Column(
              //         children: [
              //           Theme(
              //             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              //             child: const ExpansionTile(
              //               tilePadding: EdgeInsets.zero,   // hilangkan padding kiri/kanan
              //               childrenPadding: EdgeInsets.zero,
              //               minTileHeight: 0,
              //               title: Text("Petunjuk Transfer ATM"),
              //               children: const [
              //                 Align(
              //                   alignment: Alignment.centerLeft,
              //                   child: Text("Theme.of(context).copyWith(dividerColor: Colors.black12)")
              //                 )
              //               ],
              //             ),
              //           )
              //         ],
              //       ),
              //     )
              // )

            ]
          ),
        ),
      ),
      bottomNavigationBar : Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: (screenWidth) - 10,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, 'refresh');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor:
                        const Color.fromARGB(255, 254, 185, 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.grey[800], fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        )
    )
    );
  }
}