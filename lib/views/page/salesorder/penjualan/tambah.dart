import 'dart:collection';
import 'dart:developer';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/old/setorsaldo_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/salesorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/models/penjualan_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import 'package:flutter/cupertino.dart';

class FormPenjualanDetailManager {
  final List<FormPenjualanDetail> _entries = [];

  List<FormPenjualanDetail> get entries => _entries;

  void addEntry(String userid, String produkid, String harga, String qty,
      String satuan, String jumlah, String fee) {
    _entries.add(FormPenjualanDetail(
        userid: userid,
        produkid: produkid,
        harga: harga,
        qty: qty,
        satuan: satuan,
        jumlah: jumlah,
        fee: fee
    ));
  }

  void removeEntry(String id) {
    _entries.removeWhere((entry) => entry.produkid == id);
  }

  bool entryExists(String id) {
    return _entries.any((entry) => entry.produkid == id);
  }

  List<FormPenjualanDetail> getEntries(String id) {
    return _entries.where((entry) => entry.produkid == id).toList();
  }

  void updateEntry(String oldprodukid, String newuserid, String newprodukid,
      String newHarga, String newqty, String newsatuan, String newjumlah, String newfee) {
    final index = _entries.indexWhere((entry) => entry.produkid == oldprodukid);
    if (index != -1) {
      _entries[index] = FormPenjualanDetail(
          userid: newuserid,
          produkid: newprodukid,
          harga: newHarga,
          qty: newqty,
          satuan: newsatuan,
          jumlah: newjumlah,
          fee: newfee
      );
    }
  }
}

class TambahPenjualanPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const TambahPenjualanPage({super.key, this.token, this.userid});

  @override
  State<TambahPenjualanPage> createState() => _TambahPenjualanPageState();
}

class _TambahPenjualanPageState extends State<TambahPenjualanPage> {
  late SalesorderController salesorderController;
  PenjualanNosoModel? _penjualanNosoModel;
  TempPenjualanDetailModel? _tempPenjualanDetailModel;

  // late MasterController masterController;
  // CustomerModel? _customerModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true;
  bool isSwitched = false;

  String? smItem = "0";
  String? smQty = "0";
  String? smSubtotal = "0";
  String? smDpProsen = "0";
  String? smNominalDp = "0";
  String? smFee = "0";
  String? smBiayaLayanan = "0";
  String? smGrandtotal = "0";
  String? smGrandtotalNonDp = "0";

  DateTime _selectedDate = DateTime.now();
  // TextEditingController nopoController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();

  late SetorSaldoController setorSaldoController;

  final _formKey = GlobalKey<FormState>();
  String noso = '';
  String tanggal = '';
  String keterangan = '';

  String? customer_po = '';
  String? customer_tglpo;
  String? customer_poid;
  String? customer_id;
  String? customer_nama;
  String? customer_tipeppn;
  String? customer_syaratbayar;
  String? customer_tipepelanggan;

  int? _selectedMetodeBayar = 3;

  String? metode_id;
  String? metode_channel;
  String? metode_institusi;
  String? metode_tipe = "Bank";

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
        salesorderController = SalesorderController();
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        _dataNoso(widget.token.toString(), widget.userid.toString());
        // var response = purchaseorderController.delTempPembelianDetail(widget.token.toString(), widget.userid.toString(), '');
        _dataTempPenjualan(widget.token.toString(), widget.userid.toString());
        isLoading = false;
      });
    }
  }

  void _dataTempPenjualan(String token, String userid) async {
    TempPenjualanDetailModel? data =
        await salesorderController.gettemppenjualandetail(token, userid);
    setState(() {
      _tempPenjualanDetailModel = data;
      smItem = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].item.toString();
      smQty = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].qty.toString();
      smSubtotal = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].subtotal.toString();
      smDpProsen = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].dp_prosen.toString();
      smNominalDp = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].nominal_dp.toString();
      smFee = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].fee.toString();
      smBiayaLayanan = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].biaya_layanan.toString();
      smGrandtotal = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].grandtotal.toString();
      smGrandtotalNonDp = _tempPenjualanDetailModel == null
          ? "0"
          : _tempPenjualanDetailModel!.summary[0].grandtotal_nondp.toString();
    });
  }

  void _dataNoso(String token, String userid) async {
    PenjualanNosoModel? data =
        await salesorderController.getnoso(token, userid);
    if (mounted) {
      setState(() {
        _penjualanNosoModel = data;
      });
    }
  }

  void _savePenjualan() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      if (customer_id == null) {
        shoMyBadDialog(
            context: context,
            title: "Pembelian",
            message: "Customer tidak boleh kosong!");
        // ignore: prefer_is_empty
      } else if (_tempPenjualanDetailModel == null ||
          _tempPenjualanDetailModel!.data.length == 0) {
        shoMyBadDialog(
            context: context,
            title: "Pembelian",
            message: "Data Penjualan tidak boleh kosong!");
      } else {
        if (customer_po != '') {
          String grandtotal = (isSwitched == true) ? smGrandtotalNonDp.toString() : smGrandtotal.toString();
          print("$noso - $customer_id - $tanggal - $customer_po - $customer_tglpo - $keterangan - $smSubtotal - $grandtotal");
          showLoadingDialog(context: context);
          salesorderController = SalesorderController();
          var response = await salesorderController.savePenjualan(
                widget.token.toString(),
                widget.userid.toString(),
                noso,
                customer_id!,
                tanggal,
                customer_po.toString(),
                customer_tglpo.toString(),
                keterangan.toString(),
                smSubtotal.toString(),
                grandtotal.toString(),'','','0'
              );
              if (response.toString() != '0') {
                hideLoadingDialog(context);
                Navigator.pop(context, 'refresh');
              } else {
                hideLoadingDialog(context);
                Fluttertoast.showToast(
                    msg: "Gagal melakukan penjualan",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    // backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
        } else {
          String grandtotal = (isSwitched == true) ? smGrandtotalNonDp.toString() : smGrandtotal.toString();
          if (_selectedMetodeBayar == 2) {
            print("$noso - $customer_id - $tanggal - $keterangan - $smSubtotal - $smBiayaLayanan - $grandtotal - $metode_tipe - $metode_channel");
            showLoadingDialog(context: context);
            salesorderController = SalesorderController();
            var response = await salesorderController.savePenjualan(
                widget.token.toString(),
                widget.userid.toString(),
                noso,
                customer_id!,
                tanggal,
                customer_po.toString(),
                customer_tglpo.toString(),
                keterangan.toString(),
                smSubtotal.toString(),
                grandtotal.toString(),metode_tipe.toString(),metode_channel.toString(),smBiayaLayanan.toString()
              );
              if (response.toString() != '0') {
                hideLoadingDialog(context);
                Navigator.pop(context, 'refresh');
              } else {
                hideLoadingDialog(context);
                Fluttertoast.showToast(
                    msg: "Gagal melakukan penjualan",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    // backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
          } else {
            print("$noso - $customer_id - $tanggal - $keterangan - $smSubtotal - $smBiayaLayanan - $grandtotal - COD");
            showLoadingDialog(context: context);
            salesorderController = SalesorderController();
            var response = await salesorderController.savePenjualan(
                  widget.token.toString(),
                  widget.userid.toString(),
                  noso,
                  customer_id!,
                  tanggal,
                  customer_po.toString(),
                  customer_tglpo.toString(),
                  keterangan.toString(),
                  smSubtotal.toString(),
                  grandtotal.toString(),'COD','',smBiayaLayanan.toString()
                );
                if (response.toString() != '0') {
                  hideLoadingDialog(context);
                  Navigator.pop(context, 'refresh');
                } else {
                  hideLoadingDialog(context);
                  Fluttertoast.showToast(
                      msg: "Gagal melakukan penjualan",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      // backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
          }
        }
      }
    }
  }

  void _delTempPenjualanDetail() async {
    showLoadingDialog(context: context);
    salesorderController = SalesorderController();
    final NavigatorState navigator = Navigator.of(context);
    var response = await salesorderController.delTempPenjualanDetail(
        widget.token.toString(), widget.userid.toString(), '');
    if (response) {
      hideLoadingDialog(context);
      navigator.pop();
    }
  }

  void _delTempPenjualanDetail2() async {
    showLoadingDialog(context: context);
    salesorderController = SalesorderController();
    final NavigatorState navigator = Navigator.of(context);
    var response = await salesorderController.delTempPenjualanDetail(
        widget.token.toString(), widget.userid.toString(), '');
    if (response) {
      hideLoadingDialog(context);
      _dataTempPenjualan(widget.token.toString(), widget.userid.toString());
    }
  }

  void _delTempPembelianDetailById(id) async {
    showLoadingDialog(context: context);
    salesorderController = SalesorderController();
    var response = await salesorderController.delTempPenjualanDetail(
        widget.token.toString(), widget.userid.toString(), id);
    if (response) {
      hideLoadingDialog(context);
      _dataTempPenjualan(widget.token.toString(), widget.userid.toString());
    }
  }

  void _saveToTempPenjualan(String idpo) async {
    showLoadingDialog(context: context);
    var response = await salesorderController.delTempPenjualanDetail(widget.token.toString(), widget.userid.toString(), '');
    var response2 = await salesorderController.saveTempCustomerPODetail(widget.token.toString(), widget.userid.toString(), idpo);
    if (response && response2) {
      hideLoadingDialog(context);
      _dataTempPenjualan(widget.token.toString(), widget.userid.toString());
    }
  }

  Future<void> navigateToCustomerPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  CustomerPage(token: widget.token, userid: widget.userid),
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
        customer_po = result["nopo"];
        customer_tglpo = result["tglpo"];
        customer_poid = result["poid"];
        customer_id = result["id"];
        customer_nama = result["nama"];
        customer_tipeppn = result["tipeppn"];
        customer_syaratbayar = result["id_syaratbayar"];
        customer_tipepelanggan = result["tipe_pelanggan"];
        _delTempPenjualanDetail2();
      });
    }
  }

  Future<void> navigateToCustomerPOPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  CustomerPOPage(token: widget.token, userid: widget.userid),
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
        customer_po = result["nopo"];
        customer_tglpo = result["tglpo"];
        customer_poid = result["poid"];
        customer_id = result["id"];
        customer_nama = result["nama"];
        customer_tipeppn = result["tipeppn"];
        customer_syaratbayar = result["id_syaratbayar"];
        customer_tipepelanggan = result["tipe_pelanggan"];
        _saveToTempPenjualan(customer_poid.toString());
      });
    }
  }

  Future<void> navigateToMetodeBayarPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  MetodeBayarPage(
                      token: widget.token,
                      userid: widget.userid,
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

  Future<void> navigateToProdukPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  ProdukPage(
                      token: widget.token,
                      userid: widget.userid,
                      tipe_pelanggan: customer_tipepelanggan),
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
        salesorderController = SalesorderController();
        _dataTempPenjualan(widget.token.toString(), widget.userid.toString());
      });
    }
  }

  Future<bool> _showBackDialog() async {
    // Show a dialog to confirm exit
    bool shouldPop = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF5F5F5),
            title: const Text('Apakah anda yakin?'),
            content: const Text('Batalkan Pembelian ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Tidak', style: TextStyle(color: Colors.grey[800])),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batalkan Pembelian',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    bootstrapGridParameters(gutterSize: 0);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool shouldPop = await _showBackDialog();
        if (shouldPop == false) {
          // fungsi hapus temp detail
          _delTempPenjualanDetail();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final NavigatorState navigator = Navigator.of(context);
              final bool shouldPop = await _showBackDialog();
              if (shouldPop == false) {
                // fungsi hapus temp detail
                _delTempPenjualanDetail();
              }
            },
          ),
          title: const Text("Tambah Penjualan",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
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
                              child: Text("Informasi Penjualan",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                        BootstrapRow(
                          height: 60,
                          children: [
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-6',
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TextFormField(
                                  controller: TextEditingController(
                                      text: _penjualanNosoModel == null
                                          ? ''
                                          : _penjualanNosoModel!.data[0].noso
                                              .toString()),
                                  decoration: InputDecoration(
                                      labelText: 'Nomor SO',
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  enabled: false,
                                  onSaved: (value) {
                                    noso = value!;
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-6',
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  controller: tanggalController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Tanggal',
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(context),
                                    ),
                                  ),
                                  onTap: () => _selectDate(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // BootstrapRow(
                        //   height: 60,
                        //   children: [
                        //     BootstrapCol(
                        //       sizes: 'col-12',
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(right: 0),
                        //         child: TextFormField(
                        //           readOnly: true,
                        //           controller:
                        //               TextEditingController(text: customer_po),
                        //           decoration: InputDecoration(
                        //             labelText: 'PO Customer',
                        //             labelStyle:
                        //                 const TextStyle(color: Colors.grey),
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(10),
                        //               borderSide:
                        //                   const BorderSide(color: Colors.grey),
                        //             ),
                        //             focusedBorder: OutlineInputBorder(
                        //               borderSide:
                        //                   const BorderSide(color: Colors.grey),
                        //               borderRadius: BorderRadius.circular(10.0),
                        //             ),
                        //             suffixIcon: IconButton(
                        //               icon: const Icon(Icons.arrow_drop_down),
                        //               onPressed: () => navigateToCustomerPOPage(),
                        //             ),
                        //           ),
                        //           onTap: () => navigateToCustomerPOPage(),
                        //         ),
                        //       ),
                        //     ),
                        //   ]
                        // ),
                        BootstrapRow(
                          height: 60,
                          children: [
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                readOnly: true,
                                controller:
                                    TextEditingController(text: customer_nama),
                                decoration: InputDecoration(
                                  labelText: 'Customer',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: () => navigateToCustomerPage(),
                                  ),
                                ),
                                onTap: () => navigateToCustomerPage(),
                              ),
                            ),
                          ],
                        ),
                        BootstrapRow(
                          height: 60,
                          children: [
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                maxLines: null,
                                controller: keteranganController,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                    labelText: 'Keterangan',
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                onSaved: (value) {
                                  keterangan = value!;
                                },
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Data Penjualan",
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () => navigateToProdukPage(),
                                    child: Row(
                                      children: [
                                        Text('Tambah Produk',
                                            style: TextStyle(
                                                color: Colors.grey[500])),
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
                                height: screenHeight / 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: _tempPenjualanDetailModel == null
                                          ? const ListMenuShimmer(
                                              total: 4, circular: 4, height: 42)
                                          : _tempPenjualanDetailModel!
                                                      .data.length ==
                                                  0
                                              ? const Center(
                                                  child: Text('Belum ada data'))
                                              : ListView.builder(
                                                  physics: const ScrollPhysics(
                                                      parent:
                                                          ClampingScrollPhysics()),
                                                  itemCount:
                                                      _tempPenjualanDetailModel!
                                                          .data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var id =
                                                        _tempPenjualanDetailModel!
                                                            .data[index].id
                                                            .toString();
                                                    var namaproduk =
                                                        _tempPenjualanDetailModel!
                                                            .data[index]
                                                            .namaproduk
                                                            .toString();
                                                    var qty = int.parse(
                                                        _tempPenjualanDetailModel!
                                                            .data[index].qty
                                                            .toString());
                                                    var satuanproduk =
                                                        _tempPenjualanDetailModel!
                                                            .data[index]
                                                            .satuanproduk
                                                            .toString();
                                                    var harga = int.parse(
                                                        _tempPenjualanDetailModel!
                                                            .data[index].harga
                                                            .toString());
                                                    var jumlah = int.parse(
                                                        _tempPenjualanDetailModel!
                                                            .data[index].jumlah
                                                            .toString());
                                                    var image =
                                                        _tempPenjualanDetailModel!
                                                            .data[index]
                                                            .image
                                                            .toString();
                                                    return orderItemDetail(
                                                        index,
                                                        id,
                                                        namaproduk,
                                                        qty,
                                                        satuanproduk,
                                                        harga,
                                                        jumlah,image);
                                                  },
                                                ),
                                    )),
                                    Divider(height: 1, color: Colors.grey[200]),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Total $smItem Produk, $smQty Karton'),
                                          Text(
                                              CurrencyFormat.convertToIdr(
                                                  (int.parse(
                                                      smSubtotal.toString())),
                                                  0),
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Visibility(
                    visible: false, // (customer_po == '') ? true : false,
                    child: SizedBox(height: 16),
                  ),
                  Visibility(
                    visible: false,// (customer_po == '') ? true : false,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.all(16),
                        child: BootstrapContainer(fluid: true, children: [
                          BootstrapRow(
                            height: 30,
                            children: [
                              BootstrapCol(
                                sizes: 'col-12',
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              style: TextStyle(
                                                  color: Colors.grey[500])),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildPaymentOption(2, (metode_tipe == 'Bank') ? "Transfer Bank" : "Bayar Tunai di Mitra/Agen",metode_institusi.toString(), FontAwesomeIcons.rightLeft),
                                          Divider(height: 16,color: Colors.grey[300]),
                                          _buildPaymentOption(3,"COD","Cash on Delivery", FontAwesomeIcons.wallet)
                                        ],
                                      ),
                                    ))
                              ])
                        ])),
                  ),
                  Visibility(
                    visible: (customer_po == '') ? true : false,
                    child: const SizedBox(height: 16),
                  ),
                  Visibility(
                    visible: (customer_po == '') ? true : false,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.all(16),
                        child: BootstrapContainer(fluid: true, children: [
                          BootstrapRow(
                            height: 30,
                            children: [
                              BootstrapCol(
                                sizes: 'col-12',
                                child: Text("Rincian Pembayaran",
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
                                        height: 100,
                                        child: Column(
                                            mainAxisAlignment:MainAxisAlignment.start,
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Subtotal Pembelian'),
                                                  Text(CurrencyFormat.convertToIdr((int.parse(smSubtotal.toString())),0)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Biaya Layanan'),
                                                  Text(
                                                      CurrencyFormat.convertToIdr(
                                                          (int.parse(
                                                              smBiayaLayanan
                                                                  .toString())),
                                                          0)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Divider(
                                                  height: 1,
                                                  color: Colors.grey[200]),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                        'Total Pembayaran'),
                                                    Text(
                                                        (isSwitched == true)
                                                            ? CurrencyFormat.convertToIdr(
                                                                (int.parse(
                                                                    smGrandtotalNonDp
                                                                        .toString())),
                                                                0)
                                                            : CurrencyFormat
                                                                .convertToIdr(
                                                                    (int.parse(
                                                                        smGrandtotal
                                                                            .toString())),
                                                                    0),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.grey[800],
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold)),
                                                  ],
                                                ),
                                              )
                                            ])))
                              ])
                        ])),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
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
              height: 65,
              // width: (screenWidth/2),
              // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                // border: Border.all(color: Colors.white),
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: (screenWidth * 0.25)),
                      SizedBox(
                        width: (screenWidth * 0.35) - 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total'),
                            Text(
                                (isSwitched == true)
                                    ? CurrencyFormat.convertToIdr(
                                        (int.parse(
                                            smGrandtotalNonDp.toString())),
                                        0)
                                    : CurrencyFormat.convertToIdr(
                                        (int.parse(smGrandtotal.toString())),
                                        0),
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (screenWidth * 0.4) - 10,
                        child: ElevatedButton(
                          onPressed: () => _savePenjualan(), //_savePesanan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor:
                                const Color.fromARGB(255, 254, 185, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Buat Penjualan',
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
        // floatingActionButton: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     FloatingActionButton(
        //       heroTag: "smallFab",
        //       mini: true, // <- ini bikin kecil
        //       backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        //       onPressed: () => print("FAB kecil"),
        //       child: const Icon(Icons.search, color: Colors.white),
        //     ),
        //     FloatingActionButton(
        //       heroTag: "bigFab",
        //       backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        //       onPressed: () => navigateToProdukPage(),
        //       child: const Icon(Icons.menu_book, color: Colors.white),
        //     ),
        //   ],
        // )
      ),
    );
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (BuildContext context, Widget? widget) => Theme(
              data: ThemeData(
                colorScheme:
                    const ColorScheme.light(primary: Color(0xFFFFB902)),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  dividerColor: const Color(0xFFFFB902),
                  headerBackgroundColor: const Color(0xFFFFB902),
                  headerForegroundColor: Colors.grey[800],
                ),
              ),
              child: widget!,
            ));
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      tanggalController
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: tanggalController.text.length,
            affinity: TextAffinity.upstream));
      // print(DateFormat('yyyy-MM-dd').format(_selectedDate));
    }
  }

  Widget orderItemDetail(int index, String id, String namaproduk, int qty,
      String satuanproduk, int harga, int jumlah, String image) {
    double screenWidth = MediaQuery.of(context).size.width;

    var no = index + 1;
    Color? color = Colors.white;
    if (no % 2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    return GestureDetector(
      onTap: () => _delTempProduk(
          id, namaproduk, satuanproduk, int.parse(harga.toString()), qty),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
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
                  Text(
                    satuanproduk,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormat.convertToIdr(harga, 0),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        'x${qty}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      CurrencyFormat.convertToIdr(jumlah, 0),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ]
        )
      )
      // Column(
      //   children: [
      //     Container(
      //         decoration: BoxDecoration(
      //           color: color,
      //           // borderRadius: BorderRadius.circular(0),
      //         ),
      //         width: screenWidth,
      //         padding: const EdgeInsets.all(16),
      //         child: Row(
      //           children: [
      //             SizedBox(
      //               width: screenWidth * 0.76,
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.start,
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(namaproduk,
      //                       style: TextStyle(
      //                           fontSize: 14, color: Colors.grey[800])),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text('@ ${CurrencyFormat.convertToIdr(harga, 0)}',
      //                           style: TextStyle(color: Colors.grey[800])),
      //                       Text('x $qty $satuanproduk',
      //                           style: TextStyle(color: Colors.grey[800])),
      //                       Text(CurrencyFormat.convertToIdr(jumlah, 0),
      //                           style: TextStyle(color: Colors.grey[800]))
      //                     ],
      //                   )
      //                 ],
      //               ),
      //             )
      //           ],
      //         )),
      //     // Divider(color: Colors.grey[200])
      //   ],
      // ),
    );
  }

  Future<void> _delTempProduk(
      String id, String nama, String satuan, int harga, int qty) async {
    // Show a dialog to confirm exit
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 254, 185, 3),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Text('Hapus Produk',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: double.minPositive,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BootstrapContainer(
                fluid: true,
                children: [
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nama Produk",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(nama,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Harga / Satuan",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                "${CurrencyFormat.convertToIdr(int.parse(harga.toString()), 0)} / $satuan",
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                CurrencyFormat.convertNumber(
                                    int.parse(qty.toString()), 0),
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: (screenWidth / 2),
                            child: ElevatedButton(
                              onPressed: () {
                                // _delTempPembelianDetailById(id);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }, //_savePesanan,
                              style: ElevatedButton.styleFrom(
                                // padding: const EdgeInsets.all(8),
                                backgroundColor:
                                    const Color.fromARGB(255, 254, 185, 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Hapus',
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget custom untuk payment method
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
}

class CustomerPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const CustomerPage({super.key, this.token, this.userid});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _formKey = GlobalKey<FormState>();

  late SalesorderController salesorderController;
  CustomerModel? _customerModel;
  final userController = UserController(StorageService());

  String _selectedSupplier = "";

  @override
  void initState() {
    super.initState();
    _dataCustomer();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataCustomer() async {
    salesorderController = SalesorderController();
    final user = await userController.getUserFromStorage();
    CustomerModel? data = await salesorderController.getcustomer(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _customerModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Customer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: dataCustomer(),
    );
  }

  Widget dataCustomer() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // _dataProduk('', value);
                    },
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            // Item List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 10, right: 10, bottom: 10),
                child: _customerModel == null
                    ? const ListMenuShimmer(total: 5)
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _customerModel!.data.length,
                        itemBuilder: (context, index) {
                          var id = _customerModel!.data[index].id.toString();
                          var nama =
                              _customerModel!.data[index].nama.toString();
                          var telepon =
                              _customerModel!.data[index].telepon.toString();
                          var alamat =
                              _customerModel!.data[index].alamat.toString();
                          var tipeppn =
                              _customerModel!.data[index].tipeppn.toString();
                          var id_syaratbayar = _customerModel!
                              .data[index].id_syaratbayar
                              .toString();
                          var tipe_pelanggan = _customerModel!
                              .data[index].tipe_pelanggan
                              .toString();

                          return listCustomer(id, nama, telepon, alamat,
                              tipeppn, id_syaratbayar, tipe_pelanggan);
                        }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listCustomer(String id, String nama, String telepon, String alamat,
      String tipeppn, String id_syaratbayar, String tipe_pelanggan) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSupplier = id;
          Navigator.pop(context, {
            "nopo": '',
            "tglpo": '',
            "poid": '',
            "id": id,
            "nama": nama,
            "tipeppn": tipeppn,
            "id_syaratbayar": id_syaratbayar,
            "tipe_pelanggan": tipe_pelanggan,
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color:
              _selectedSupplier == id ? const Color(0xFFfcf5e1) : Colors.white,
          border: Border.all(
              color: _selectedSupplier == id
                  ? const Color(0xFFFFB902)
                  : Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[$tipe_pelanggan] $nama',
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(alamat,
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerPOPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const CustomerPOPage({super.key, this.token, this.userid});

  @override
  State<CustomerPOPage> createState() => _CustomerPOPageState();
}

class _CustomerPOPageState extends State<CustomerPOPage> {
  final _formKey = GlobalKey<FormState>();

  late SalesorderController salesorderController;
  CustomerPOModel? _customerPOModel;
  final userController = UserController(StorageService());

  String _selectedSupplier = "";

  @override
  void initState() {
    super.initState();
    _dataCustomerPO();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataCustomerPO() async {
    salesorderController = SalesorderController();
    final user = await userController.getUserFromStorage();
    CustomerPOModel? data = await salesorderController.getcustomerpo(user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _customerPOModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("PO Customer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: dataCustomerPO(),
    );
  }

  Widget dataCustomerPO() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // _dataProduk('', value);
                    },
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            // Item List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 10, right: 10, bottom: 10),
                child: _customerPOModel == null
                    ? const ListMenuShimmer(total: 5)
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _customerPOModel!.data.length,
                        itemBuilder: (context, index) {
                          var pelanggan_id = _customerPOModel!.data[index].pelanggan_id.toString();
                          var nama = _customerPOModel!.data[index].pelanggan.toString();
                          var telepon = _customerPOModel!.data[index].telepon.toString();
                          var alamat = _customerPOModel!.data[index].alamat.toString();
                          var tipeppn = _customerPOModel!.data[index].tipeppn.toString();
                          var id_syaratbayar = _customerPOModel!.data[index].id_syaratbayar.toString();
                          var tipe_pelanggan = _customerPOModel!.data[index].tipe_pelanggan.toString();
                          var nopo = _customerPOModel!.data[index].nopo.toString();
                          var tgl_po = _customerPOModel!.data[index].tgl_po.toString();
                          var id = _customerPOModel!.data[index].id.toString();

                          return listCustomerPO(pelanggan_id, nama, telepon, alamat,tipeppn, id_syaratbayar, tipe_pelanggan, nopo, tgl_po, id);
                        }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listCustomerPO(String pelanggan_id, String nama, String telepon, String alamat,
      String tipeppn, String id_syaratbayar, String tipe_pelanggan, String nopo, String tgl_po, String id) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSupplier = pelanggan_id;
          Navigator.pop(context, {
            "nopo": nopo,
            "tglpo": tgl_po,
            "poid": id,
            "id": pelanggan_id,
            "nama": nama,
            "tipeppn": tipeppn,
            "id_syaratbayar": id_syaratbayar,
            "tipe_pelanggan": tipe_pelanggan,
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color:
              _selectedSupplier == pelanggan_id ? const Color(0xFFfcf5e1) : Colors.white,
          border: Border.all(
              color: _selectedSupplier == pelanggan_id
                  ? const Color(0xFFFFB902)
                  : Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nopo,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
                Text(tgl_po,
                style:
                    TextStyle(color: Colors.grey[800], fontSize: 16)),
              ],
            ),
            Text('[$tipe_pelanggan] $nama', style:TextStyle(color: Colors.grey[800], fontSize: 16))
          ],
        ),
      ),
    );
  }
}

class MetodeBayarPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? metodeId;
  const MetodeBayarPage({super.key, this.token, this.userid, this.metodeId});

  @override
  State<MetodeBayarPage> createState() => _MetodeBayarPageState();
}

class _MetodeBayarPageState extends State<MetodeBayarPage> {
  final _formKey = GlobalKey<FormState>();
  // final FormPenjualanDetailManager _entryManager = FormPenjualanDetailManager();

  late MasterController masterController;
  MetodeBayarBankModel? _metodeBayarBankModel;
  MetodeBayarAgenModel? _metodeBayarAgenModel;
  final userController = UserController(StorageService());

  String? _selectedMetodeId;
  String? _selectedMetodeChannel;
  String? _selectedMetodeInstitusi;
  String? _selectedMetodeTipe = "Bank";

  @override
  void initState() {
    super.initState();
    _selectedMetodeId = (widget.metodeId == 'null' || widget.metodeId == '')
        ? '1'
        : widget.metodeId;
    print(widget.metodeId);
    masterController = MasterController();
    _dataMetodeBayarBank();
    _dataMetodeBayarAgen();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataMetodeBayarBank() async {
    final user = await userController.getUserFromStorage();
    MetodeBayarBankModel? data = await masterController.getmetodebayarbank(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _metodeBayarBankModel = data;
      });
    }
  }

  void _dataMetodeBayarAgen() async {
    final user = await userController.getUserFromStorage();
    MetodeBayarAgenModel? data = await masterController.getmetodebayaragen(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _metodeBayarAgenModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Metode Pembayaran",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: dataMetodeBayar(),
        bottomNavigationBar: Container(
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
              height: 65,
              // width: (screenWidth/2),
              // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                // border: Border.all(color: Colors.white),
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (screenWidth) - 16,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context, {
                                "metode_id": _selectedMetodeId,
                                "metode_channel": _selectedMetodeChannel,
                                "metode_institusi": _selectedMetodeInstitusi,
                                "metode_tipe": _selectedMetodeTipe,
                              });
                            });
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
                            'Konfirmasi',
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  Widget dataMetodeBayar() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Item List
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.all(16),
                    child: BootstrapContainer(fluid: true, children: [
                      BootstrapRow(
                        height: 30,
                        children: [
                          BootstrapCol(
                            sizes: 'col-12',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Transfer Bank",
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
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
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    _metodeBayarBankModel?.data.length ?? 0,
                                itemBuilder: (context, index) {
                                  final item =
                                      _metodeBayarBankModel!.data[index];

                                  final id =
                                      item.id?.toString() ?? "0"; // default "0"
                                  final channel =
                                      item.channel ?? "Unknown"; // default teks
                                  final image = item.image ?? "";
                                  final institusi = item.institusi ?? "";
                                  final tipe = item.tipe ?? "";

                                  return _buildMetodeOption(
                                      id, channel, image, institusi, tipe);
                                },
                              ),
                            )
                          ])
                    ])),
                const SizedBox(height: 16),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.all(16),
                    child: BootstrapContainer(fluid: true, children: [
                      BootstrapRow(
                        height: 30,
                        children: [
                          BootstrapCol(
                            sizes: 'col-12',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Bayar Tunai di Mitra/Agen",
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
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
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _metodeBayarAgenModel?.data.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final item =
                                        _metodeBayarAgenModel!.data[index];

                                    final id = item.id?.toString() ??
                                        "0"; // default "0"
                                    final channel = item.channel ??
                                        "Unknown"; // default teks
                                    final image = item.image ?? "";
                                    final institusi = item.institusi ?? "";
                                    final tipe = item.tipe ?? "";

                                    return _buildMetodeOption(
                                        id, channel, image, institusi, tipe);
                                  },
                                ))
                          ])
                    ])),
              ],
            ),
          ),
        ));
  }

  Widget _buildMetodeOption(
      String id, String label, String image, String institusi, String tipe) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetodeId = id;
          _selectedMetodeChannel = label;
          _selectedMetodeInstitusi = institusi;
          _selectedMetodeTipe = tipe;
        });
      },
      child: Column(
        children: [
          Container(
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
                Image.network(
                  height: 30,
                  width: 30,
                  image,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 30, color: Colors.grey);
                  },
                ),
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
                      Text(
                        institusi,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _selectedMetodeId == id
                    ? Icon(Icons.check_circle, color: Colors.amber, size: 20)
                    : Icon(Icons.circle, color: Colors.grey[300], size: 20)
              ],
            ),
          ),
          Divider(height: 16, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

class ProdukPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? tipe_pelanggan;
  const ProdukPage({super.key, this.token, this.userid, this.tipe_pelanggan});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final FormPenjualanDetailManager _entryManager = FormPenjualanDetailManager();
  late MasterController masterController;
  late SalesorderController salesorderController;
  ProdukModel? _produkModel;
  final userController = UserController(StorageService());

  int totqty = 0;

  void _addEntry(menuId, harga, satuan, fee) {
    setState(() {
      if (_entryManager.entryExists(menuId) == false) {
        var subtotal = harga;
        _entryManager.addEntry(
            widget.userid.toString(), menuId, harga, "1", satuan, subtotal, fee.toString());
      } else {
        var newQty = int.parse(_entryManager.getEntries(menuId)[0].qty) + 1;
        var newSubtotal = newQty * int.parse(harga);
        _entryManager.updateEntry(menuId, widget.userid.toString(), menuId,
            harga, newQty.toString(), satuan, newSubtotal.toString(), fee.toString());
      }
      totqty = totqty + 1;
    });
    print(inspect(_entryManager.entries));
  }

  void _updateEntry(menuId, harga, qty, satuan, fee) {
    setState(() {
      if (qty != 0) {
        if (_entryManager.entryExists(menuId) == false) {
          int subtotal = qty * harga;
          _entryManager.addEntry(widget.userid.toString(), menuId,
              harga.toString(), qty.toString(), satuan, subtotal.toString(), fee);
        } else {
          var newQty = qty;
          var newSubtotal = newQty * harga;
          _entryManager.updateEntry(
              menuId,
              widget.userid.toString(),
              menuId,
              harga.toString(),
              newQty.toString(),
              satuan,
              newSubtotal.toString(), fee);
        }
      } else {
        _entryManager.removeEntry(menuId);
      }
      totqty = totqty + int.parse(qty.toString());
    });
    // print(inspect(_entryManager.entries));
  }

  void _removeEntry(menuId, harga, satuan, fee) {
    setState(() {
      if (_entryManager.entryExists(menuId) == true) {
        var newQty = int.parse(_entryManager.getEntries(menuId)[0].qty) - 1;
        if (newQty != 0) {
          var newSubtotal = newQty * int.parse(harga);
          _entryManager.updateEntry(menuId, widget.userid.toString(), menuId,
              harga, newQty.toString(), satuan, newSubtotal.toString(), fee);
        } else {
          _entryManager.removeEntry(menuId);
        }
      }
      totqty = totqty - 1;
    });
  }

  void _saveProduks() async {
    if (_entryManager.entries.length > 0) {
      showLoadingDialog(context: context);
      salesorderController = SalesorderController();
      for (var entry in _entryManager.entries) {
        await salesorderController.saveTempPenjualanDetail(widget.token.toString(), entry);
      }
      hideLoadingDialog(context);
    }
    Navigator.pop(context, 'refresh');
  }

  @override
  void initState() {
    super.initState();
    masterController = MasterController();
    _dataProduk();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataProduk() async {
    final user = await userController.getUserFromStorage();
    ProdukModel? data = await masterController.getproduks(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _produkModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Produk",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: dataProduk(),
        bottomNavigationBar: Container(
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
              height: 65,
              // width: (screenWidth/2),
              // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                // border: Border.all(color: Colors.white),
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (screenWidth) - 16,
                        child: ElevatedButton(
                          onPressed: _saveProduks, //_savePesanan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor:
                                const Color.fromARGB(255, 254, 185, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Tambahkan Produk',
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  Widget dataProduk() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // _dataProduk('', value);
                    },
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            // Item List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 10, right: 10, bottom: 10),
                child: _produkModel == null
                    ? const ListMenuShimmer(total: 5)
                    : _produkModel!.data.length == 0
                        ? const Center(child: Text('Belum ada daftar menu'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _produkModel!.data.length,
                            itemBuilder: (context, index) {
                              var id = _produkModel!.data[index].id.toString();
                              var nama = _produkModel!.data[index].namaproduk
                                  .toString();
                              var satuan =
                                  _produkModel!.data[index].satuan.toString();
                              var hargabeli = _produkModel!
                                  .data[index].hargabeli
                                  .toString();
                              var hrgdistributor = _produkModel!
                                  .data[index].hrg_distributor
                                  .toString();
                              var hrgagen =
                                  _produkModel!.data[index].hrg_agen.toString();
                              var hrgreseller = _produkModel!
                                  .data[index].hrg_reseller
                                  .toString();
                              var hrgnonmember = _produkModel!
                                  .data[index].hrg_nonmember
                                  .toString();
                              var qty = _entryManager.getEntries(id).isEmpty
                                  ? "0"
                                  : _entryManager.getEntries(id)[0].qty;
                              var fee = _produkModel!
                                  .data[index].transaksi_fee
                                  .toString();
                              var image = _produkModel!
                                  .data[index].image
                                  .toString();
                              return listProduk(
                                  id,
                                  nama,
                                  satuan,
                                  hargabeli,
                                  hrgdistributor,
                                  hrgagen,
                                  hrgreseller,
                                  hrgnonmember,
                                  int.parse(qty),
                                  int.parse(fee),
                                  image
                                );
                            }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listProduk(
      String id,
      String nama,
      String satuan,
      String hargabeli,
      String hrgdistributor,
      String hrgagen,
      String hrgreseller,
      String hrgnonmember,
      int qty, int fee, String image) {
    double screenWidth = MediaQuery.of(context).size.width;

    var usergroup = widget.tipe_pelanggan;
    String? harga = "0";
    if (usergroup == 'Administrator') {
      harga = hargabeli;
    } else if (usergroup == 'Distributor') {
      harga = hrgdistributor;
    } else if (usergroup == 'Agen') {
      harga = hrgagen;
    } else if (usergroup == 'Reseller') {
      harga = hrgreseller;
    } else {
      harga = hrgnonmember;
    }
    // String dropdownValue = satuan.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(satuan,style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormat.convertToIdr(int.parse(harga), 0),
                          style: TextStyle(
                              color: Colors.amber[900], fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                onPressed: () => _removeEntry(id, harga, satuan, fee),
                                icon: const Icon(Icons.remove, color: Colors.white),
                                padding: const EdgeInsets.all(0),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: TextField(
                                    keyboardType: TextInputType.none,
                                    showCursor: false,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                    decoration: InputDecoration(
                                        hintText: qty.toString(),
                                        isDense: true, // biar padding lebih rapat
                                        contentPadding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 8),
                                        border: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey), // garis tipis abu-abu
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey), // saat fokus jadi biru
                                        )),
                                    onTap: () => _showAction(id, nama, satuan,
                                        int.parse(harga.toString()), qty, fee),
                                  )),
                            ),
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                onPressed: () => _addEntry(id, harga, satuan, fee),
                                icon: const Icon(Icons.add, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAction(
      String id, String nama, String satuan, int harga, int qty, int fee) async {
    // Show a dialog to confirm exit
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final TextEditingController qtyController =
        TextEditingController(text: qty.toString());
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 254, 185, 3),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Text('Produk',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: double.minPositive,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BootstrapContainer(
                fluid: true,
                children: [
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nama Produk",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(nama,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Harga / Satuan",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                "${CurrencyFormat.convertToIdr(int.parse(harga.toString()), 0)} / $satuan",
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Text("Qty",
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 14)),
                        ),
                      ),
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: TextFormField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true, // biar lebih rapat
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey), // garis tipis abu-abu
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey), // saat fokus jadi biru
                              ),
                            ),
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
                        sizes: 'col-md-12',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: (screenWidth / 2),
                            child: ElevatedButton(
                              onPressed: () {
                                String value = qtyController.text.trim();
                                int newQty = int.tryParse(value) ?? 0;
                                _updateEntry(id, harga, newQty, satuan, fee);
                                Navigator.pop(context);
                              }, //_savePesanan,
                              style: ElevatedButton.styleFrom(
                                // padding: const EdgeInsets.all(8),
                                backgroundColor:
                                    const Color.fromARGB(255, 254, 185, 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Set Qty Produk',
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
