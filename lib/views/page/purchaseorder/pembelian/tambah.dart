import 'dart:collection';
import 'dart:developer';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/old/setorsaldo_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import 'package:flutter/cupertino.dart';

class FormPembelianDetailManager {
  final List<FormPembelianDetail> _entries = [];

  List<FormPembelianDetail> get entries => _entries;

  void addEntry(String userid, String produkid, String harga, String qty,
      String satuan, String jumlah, String fee) {
    _entries.add(FormPembelianDetail(
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

  List<FormPembelianDetail> getEntries(String id) {
    return _entries.where((entry) => entry.produkid == id).toList();
  }

  void updateEntry(String oldprodukid, String newuserid, String newprodukid,
      String newHarga, String newqty, String newsatuan, String newjumlah, String newfee) {
    final index = _entries.indexWhere((entry) => entry.produkid == oldprodukid);
    if (index != -1) {
      _entries[index] = FormPembelianDetail(
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

class TambahPembelianPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const TambahPembelianPage({super.key, this.token, this.userid});

  @override
  State<TambahPembelianPage> createState() => _TambahPembelianPageState();
}

class _TambahPembelianPageState extends State<TambahPembelianPage> {
  late PurchaseorderController purchaseorderController;
  PembelianNopoModel? _pembelianNopoModel;
  TempPembelianDetailModel? _tempPembelianDetailModel;

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
  String nopo = '';
  String tanggal = '';
  String keterangan = '';

  String? supplier_id;
  String? supplier_nama;
  String? supplier_tipeppn;
  String? supplier_syaratbayar;

  int? _selectedMetodeBayar = 2;

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
        purchaseorderController = PurchaseorderController();
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        _dataPelanggan(userToken, userId);
        _dataNopo(widget.token.toString(), widget.userid.toString());
        var response = purchaseorderController.delTempPembelianDetail(widget.token.toString(), widget.userid.toString(), '');
        _dataTempPesanan(widget.token.toString(), widget.userid.toString());
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

  void _dataNopo(String token, String userid) async {
    PembelianNopoModel? data =
        await purchaseorderController.getnopo(token, userid);
    if (mounted) {
      setState(() {
        _pembelianNopoModel = data;
      });
    }
  }

  void _dataTempPesanan(String token, String userid) async {
    TempPembelianDetailModel? dataTempPesanan =
        await purchaseorderController.gettemppembeliandetail(token, userid);
    setState(() {
      _tempPembelianDetailModel = dataTempPesanan;
      smItem = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].item.toString();
      smQty = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].qty.toString();
      smSubtotal = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].subtotal.toString();
      smDpProsen = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].dp_prosen.toString();
      smNominalDp = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].nominal_dp.toString();
      // smFee = _tempPembelianDetailModel == null
      //     ? "0"
      //     : _tempPembelianDetailModel!.summary[0].fee.toString();
      smBiayaLayanan = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].biaya_layanan.toString();
      smGrandtotal = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].grandtotal.toString();
      smGrandtotalNonDp = _tempPembelianDetailModel == null
          ? "0"
          : _tempPembelianDetailModel!.summary[0].grandtotal_nondp.toString();
    });
  }

  void _savePembelian() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      if (supplier_id == null) {
        shoMyBadDialog(
            context: context,
            title: "Pembelian",
            message: "Supplier tidak boleh kosong!");
        // ignore: prefer_is_empty
      } else if (_tempPembelianDetailModel == null ||
          _tempPembelianDetailModel!.data.length == 0) {
        shoMyBadDialog(
            context: context,
            title: "Pembelian",
            message: "Data pembelian tidak boleh kosong!");
      } else {
        if (_selectedMetodeBayar == '1') {
          print('Cek Saldo');
        } else {
          if (metode_id == null) {
            shoMyBadDialog(
                context: context,
                title: "Pembelian",
                message: "Metode Pembayaran tidak boleh kosong!");
          } else {
            // String grandtotal = (isSwitched == true) ? smGrandtotalNonDp.toString() : smGrandtotal.toString();
            String grandtotal = smGrandtotal.toString();
            String jumlah_dp = (isSwitched == true) ? smNominalDp.toString() : '0';
            print(
                "$nopo - $supplier_id - $tanggal - $keterangan - $smSubtotal - $smBiayaLayanan - $grandtotal - $jumlah_dp");
            showLoadingDialog(context: context);
            purchaseorderController = PurchaseorderController();
            var response = await purchaseorderController.savePembelian(
              widget.token.toString(),
              widget.userid.toString(),
              nopo,
              supplier_id!,
              tanggal,
              keterangan,
              smSubtotal.toString(),
              smBiayaLayanan.toString(),
              grandtotal,
              jumlah_dp,
              metode_tipe.toString(),
              metode_channel.toString()
            );
            if (response.toString() != '0') {
              hideLoadingDialog(context);
              // Navigator.pop(context, 'refresh');
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) => //DrawerExample(),
                          PembelianDetailPage(token: widget.token.toString(), userid: widget.userid.toString(), idencrypt: response.toString()),
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
            }
          }
        }
      }
    }
  }

  void _delTempPembelianDetail() async {
    showLoadingDialog(context: context);
    purchaseorderController = PurchaseorderController();
    final NavigatorState navigator = Navigator.of(context);
    var response = await purchaseorderController.delTempPembelianDetail(
        widget.token.toString(), widget.userid.toString(), '');
    if (response) {
      hideLoadingDialog(context);
      navigator.pop();
    }
  }

  _delTempPembelianDetailById(id) async {
    showLoadingDialog(context: context);
    purchaseorderController = PurchaseorderController();
    var response = await purchaseorderController.delTempPembelianDetail(
        widget.token.toString(), widget.userid.toString(), id);
    if (response) {
      hideLoadingDialog(context);
      _dataTempPesanan(widget.token.toString(), widget.userid.toString());
    }
  }

  Future<void> navigateToSupplierPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  SupplierPage(token: widget.token, userid: widget.userid),
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
        supplier_id = result["id"];
        supplier_nama = result["nama"];
        supplier_tipeppn = result["tipeppn"];
        supplier_syaratbayar = result["id_syaratbayar"];
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
                      usergroup: userGroup),
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
        _dataTempPesanan(widget.token.toString(), widget.userid.toString());
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
          _delTempPembelianDetail();
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
                _delTempPembelianDetail();
              }
            },
          ),
          // actions: [
          //   // 🔹 kanan
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Colors.white),
          //     onPressed: () {},
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.menu_book, color: Colors.white),
          //     onPressed: () => navigateToProdukPage(),
          //   ),
          // ],
          title: const Text("Tambah Pembelian",
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
                              child: Text("Informasi Pembelian",
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
                              sizes: 'col-md-7',
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TextFormField(
                                  controller: TextEditingController(
                                      text: _pembelianNopoModel == null
                                          ? ''
                                          : _pembelianNopoModel!.data[0].nopo
                                              .toString()),
                                  decoration: InputDecoration(
                                      labelText: 'Nomor PO',
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
                                    nopo = value!;
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-5',
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
                        BootstrapRow(
                          height: 60,
                          children: [
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                readOnly: true,
                                controller:
                                    TextEditingController(text: supplier_nama),
                                decoration: InputDecoration(
                                  labelText: 'Supplier',
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
                                    onPressed: () => navigateToSupplierPage(),
                                  ),
                                ),
                                onTap: () => navigateToSupplierPage(),
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
                                  Text("Data Pembelian",
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
                                      child: _tempPembelianDetailModel == null
                                          ? const ListMenuShimmer(
                                              total: 4, circular: 4, height: 42)
                                          : _tempPembelianDetailModel!
                                                      .data.length ==
                                                  0
                                              ? const Center(
                                                  child: Text('Belum ada data'))
                                              : ListView.builder(
                                                  physics: const ScrollPhysics(
                                                      parent:
                                                          ClampingScrollPhysics()),
                                                  itemCount:
                                                      _tempPembelianDetailModel!
                                                          .data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var id =
                                                        _tempPembelianDetailModel!
                                                            .data[index].id
                                                            .toString();
                                                    var namaproduk =
                                                        _tempPembelianDetailModel!
                                                            .data[index]
                                                            .namaproduk
                                                            .toString();
                                                    var qty = int.parse(
                                                        _tempPembelianDetailModel!
                                                            .data[index].qty
                                                            .toString());
                                                    var satuanproduk =
                                                        _tempPembelianDetailModel!
                                                            .data[index]
                                                            .satuanproduk
                                                            .toString();
                                                    var harga = int.parse(
                                                        _tempPembelianDetailModel!
                                                            .data[index].harga
                                                            .toString());
                                                    var jumlah = int.parse(
                                                        _tempPembelianDetailModel!
                                                            .data[index].jumlah
                                                            .toString());
                                                    var image =
                                                        _tempPembelianDetailModel!
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
                                        // Visibility(
                                        //     visible: true,
                                        //     child: GestureDetector(
                                        //       onTap: () {},
                                        //       child: Container(
                                        //         // margin: EdgeInsets.symmetric(vertical: 8.0),
                                        //         padding:
                                        //             const EdgeInsets.all(8.0),
                                        //         decoration: BoxDecoration(
                                        //           color: Colors.white,
                                        //           borderRadius:
                                        //               BorderRadius.circular(
                                        //                   10.0),
                                        //         ),
                                        //         child: Row(
                                        //           children: <Widget>[
                                        //             // Icon(icon, color: Colors.amber, size: 20),
                                        //             const FaIcon(
                                        //                 FontAwesomeIcons.wallet,
                                        //                 color: Color.fromARGB(
                                        //                     255, 254, 185, 3),
                                        //                 size: 20),
                                        //             const SizedBox(width: 10),
                                        //             Expanded(
                                        //               child: Column(
                                        //                 crossAxisAlignment:
                                        //                     CrossAxisAlignment
                                        //                         .start,
                                        //                 children: [
                                        //                   const Text(
                                        //                     'Saldoku',
                                        //                     style:
                                        //                         const TextStyle(
                                        //                       fontSize: 14,
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .w600,
                                        //                       color:
                                        //                           Colors.black,
                                        //                     ),
                                        //                   ),
                                        //                   Text(
                                        //                     'Daftar Sekarang',
                                        //                     style: TextStyle(
                                        //                       fontSize: 14,
                                        //                       color: Colors
                                        //                           .black
                                        //                           .withOpacity(
                                        //                               0.6),
                                        //                     ),
                                        //                   )
                                        //                 ],
                                        //               ),
                                        //             ),
                                        //             Icon(
                                        //                 Icons.arrow_forward_ios,
                                        //                 size: 12,
                                        //                 color: Colors.grey[500])
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     )),
                                        Visibility(
                                          visible: _pelangganModel?.data[0].is_dompetku.toString() == '0' ? false : true,
                                          child: _buildPaymentOption(
                                              1,
                                              "Saldoku",
                                              "Rp11.410",
                                              FontAwesomeIcons.wallet),
                                        ),
                                        Visibility(
                                          visible: _pelangganModel?.data[0].is_dompetku.toString() == '0' ? false : true,
                                          child: Divider(height: 16,color: Colors.grey[300])
                                        ),
                                        _buildPaymentOption(
                                            2,
                                            (metode_tipe == 'Bank')
                                                ? "Transfer Bank"
                                                : "Bayar Tunai di Mitra/Agen",
                                            metode_institusi.toString(),
                                            FontAwesomeIcons.rightLeft),
                                      ],
                                    ),
                                  ))
                            ])
                      ])),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _pelangganModel?.data[0].id_syaratbayar.toString() == '1' ? false : true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      padding: const EdgeInsets.all(16),
                        child: BootstrapContainer(
                          fluid: true, 
                          children: [
                            BootstrapRow(
                              height: 30,
                              children: [
                                BootstrapCol(
                                  sizes: 'col-12',
                                  child: Text("Pembayaran Uang Muka",
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
                                        height: 15,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Nominal Uang Muka $smDpProsen%'),
                                            Text(CurrencyFormat.convertToIdr(
                                                (int.parse(smNominalDp.toString())),
                                                0)),
                                            Transform.scale(
                                              scale: 0.7,
                                              child: CupertinoSwitch(
                                                // This bool value toggles the switch.
                                                value: isSwitched,
                                                // trackColor: CupertinoColors.activeBlue,
                                                onChanged: (bool? value) {
                                                  // This is called when the user toggles the switch.
                                                  setState(() {
                                                    isSwitched = value ?? false;
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  ]
                            ),
                            const SizedBox(height: 16),
                          ]
                      )
                    ),
                  ),
                  
                  Visibility(
                    visible: _pelangganModel?.data[0].id_syaratbayar.toString() == '1' ? false : true,
                    child: const SizedBox(height: 16)
                  ),

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
                                            Visibility(
                                              visible: _pelangganModel?.data[0].id_syaratbayar.toString() == '1' ? false : true,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Nominal Uang Muka $smDpProsen%'),
                                                  Text((isSwitched == true)
                                                      ? CurrencyFormat.convertToIdr(
                                                          (int.parse(smNominalDp
                                                              .toString())),
                                                          0)
                                                      : 'Rp 0'),
                                                ],
                                              ),
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
                      ]))
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                          onPressed: () => _savePembelian(), //_savePesanan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor:
                                const Color.fromARGB(255, 254, 185, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Buat Pembelian',
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
                                _delTempPembelianDetailById(id);
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

class SupplierPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const SupplierPage({super.key, this.token, this.userid});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final _formKey = GlobalKey<FormState>();
  // final FormPembelianDetailManager _entryManager = FormPembelianDetailManager();

  late MasterController masterController;
  SupplierModel? _supplierModel;
  final userController = UserController(StorageService());

  String _selectedSupplier = "";

  @override
  void initState() {
    super.initState();
    masterController = MasterController();
    _dataSupplier();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataSupplier() async {
    final user = await userController.getUserFromStorage();
    SupplierModel? data = await masterController.getsuppliers(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _supplierModel = data;
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
        title: const Text("Supplier",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: dataSupplier(),
    );
  }

  Widget dataSupplier() {
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
                child: _supplierModel == null
                    ? const ListMenuShimmer(total: 5)
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _supplierModel!.data.length,
                        itemBuilder: (context, index) {
                          var id = _supplierModel!.data[index].id.toString();
                          var nama =
                              _supplierModel!.data[index].supplier.toString();
                          var telepon =
                              _supplierModel!.data[index].telepon.toString();
                          var alamat =
                              _supplierModel!.data[index].alamat.toString();
                          var tipeppn =
                              _supplierModel!.data[index].tipeppn.toString();
                          var id_syaratbayar = _supplierModel!
                              .data[index].id_syaratbayar
                              .toString();

                          return listSupplier(id, nama, telepon, alamat,
                              tipeppn, id_syaratbayar);
                        }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listSupplier(String id, String nama, String telepon, String alamat,
      String tipeppn, String id_syaratbayar) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSupplier = id;
          Navigator.pop(context, {
            "id": id,
            "nama": nama,
            "tipeppn": tipeppn,
            "id_syaratbayar": id_syaratbayar,
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
                    Text(nama,
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
  // final FormPembelianDetailManager _entryManager = FormPembelianDetailManager();

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
                          }, //_saveProduks
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
  final String? usergroup;
  const ProdukPage({super.key, this.token, this.userid, this.usergroup});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final FormPembelianDetailManager _entryManager = FormPembelianDetailManager();
  late MasterController masterController;
  late PurchaseorderController purchaseorderController;
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
              harga.toString(), qty.toString(), satuan, subtotal.toString(), fee.toString());
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
      purchaseorderController = PurchaseorderController();
      for (var entry in _entryManager.entries) {
        await purchaseorderController.saveTempPembelianDetail(
            widget.token.toString(), entry);
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

    var usergroup = widget.usergroup;
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
            // mainAxisAlignment: MainAxisAlignment.start,
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
                                        int.parse(harga.toString()), qty, int.parse(fee.toString())),
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
