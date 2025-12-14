import 'dart:collection';
import 'dart:developer';

import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/master_controller.dart';
import 'package:eahmindonesia/controllers/old/setorsaldo_controller.dart';
import 'package:eahmindonesia/controllers/purchaseorder_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/master_model.dart';
import 'package:eahmindonesia/models/pembelian_model.dart';
import 'package:eahmindonesia/models/penerimaan_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/purchaseorder/pembelian/detail.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import 'package:flutter/cupertino.dart';

class FormPembelianDetailManager {
  final List<PenerimaanPoDetail> _entries = [];

  List<PenerimaanPoDetail> get entries => _entries;

  void addEntry(String id, String nopo, String pelanggan, String produk_id, String namaproduk, String satuan_produk, String harga, String qtyorder, String qtysupply, String qtysisa, String qtyterima) {
    _entries.add(PenerimaanPoDetail(
        id: id,
        nopo: nopo,
        pelanggan: pelanggan,
        produk_id: produk_id,
        namaproduk: namaproduk,
        satuan_produk: satuan_produk,
        harga: harga,
        qtyorder: qtyorder,
        qtysupply: qtysupply,
        qtysisa: qtysisa,
        qtyterima: qtyterima 
    ));
  }

  void removeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
  }

  bool entryExists(String id) {
    return _entries.any((entry) => entry.id == id);
  }

  List<PenerimaanPoDetail> getEntries(String id) {
    return _entries.where((entry) => entry.id == id).toList();
  }

  void updateEntry(String oldId, String newQtyTerima) {
    final index = _entries.indexWhere((entry) => entry.id == oldId);
    if (index != -1) {
      int qtysupply = int.parse(_entries[index].qtysupply.toString());
      int qtysisa = int.parse(_entries[index].qtysisa.toString());
      int newQtySupply = qtysupply + int.parse(newQtyTerima);
      int newQtySisa = qtysisa - int.parse(newQtyTerima);
      if (newQtySisa >= 0) {
        _entries[index] = PenerimaanPoDetail(
            id: _entries[index].id,
            nopo: _entries[index].nopo,
            pelanggan: _entries[index].pelanggan,
            produk_id: _entries[index].produk_id,
            namaproduk: _entries[index].namaproduk,
            satuan_produk: _entries[index].satuan_produk,
            harga: _entries[index].harga,
            qtyorder: _entries[index].qtyorder,
            qtysupply: newQtySupply.toString(),
            qtysisa: newQtySisa.toString(),
            qtyterima : newQtyTerima.toString()
        );
      } else {
        int newQtyTerima = 0;
        int qtyorder = int.parse(_entries[index].qtyorder.toString());
        int qtysupply = int.parse(_entries[index].qtysupply.toString());
        int newQtySisa = qtyorder - (qtysupply + newQtyTerima);
        _entries[index] = PenerimaanPoDetail(
            id: _entries[index].id,
            nopo: _entries[index].nopo,
            pelanggan: _entries[index].pelanggan,
            produk_id: _entries[index].produk_id,
            namaproduk: _entries[index].namaproduk,
            satuan_produk: _entries[index].satuan_produk,
            harga: _entries[index].harga,
            qtyorder: _entries[index].qtyorder,
            qtysupply: _entries[index].qtysupply,
            qtysisa: newQtySisa.toString(),
            qtyterima : newQtyTerima.toString()
        );
        Fluttertoast.showToast(
          msg: "Qty Terima melebihi sisa order",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }
}

class TambahPenerimaanPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const TambahPenerimaanPage({super.key, this.token, this.userid});

  @override
  State<TambahPenerimaanPage> createState() => _TambahPenerimaanPageState();
}

class _TambahPenerimaanPageState extends State<TambahPenerimaanPage> {
  final FormPembelianDetailManager _entryManager = FormPembelianDetailManager();
  late PurchaseorderController purchaseorderController;
  PenerimaanNopuModel? _penerimaanNopuModel;
  PenerimaanPoDetailModel? _penerimaanPoDetailModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true;
  bool isSwitched = false;

  

  DateTime _selectedDate = DateTime.now();
  // TextEditingController nopoController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController nonotaController = TextEditingController();
  TextEditingController qtyTerimaController = TextEditingController();

  late SetorSaldoController setorSaldoController;

  final _formKey = GlobalKey<FormState>();
  String nopo = '';
  String tanggal = '';
  String nonota = '';

  String? pembelian_id;
  String? pembelian_nopo;
  String? pembelian_tglpo;
  String? pembelian_supplierid;
  String? pembelian_supplier;
  String? pembelian_tipeppn;
  String? pembelian_idsyaratbayar;

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
        _dataNopu(widget.token.toString(), widget.userid.toString());
        _dataPoDetail(widget.token.toString(), '0');
        isLoading = false;
      });
    }
  }

  void _dataNopu(String token, String userid) async {
    PenerimaanNopuModel? data = await purchaseorderController.getnopu(token, userid);
    if (mounted) {
      setState(() {
        _penerimaanNopuModel = data;
      });
    }
  }

  void _dataPoDetail(String token, String nopo) async {
    PenerimaanPoDetailModel? data = await purchaseorderController.getpenerimaanpodetail(token, nopo);
    if (mounted) {
      setState(() {
        _penerimaanPoDetailModel = data;
        
        for (var i = 0; i < _penerimaanPoDetailModel!.data.length; i++) {
          _entryManager.addEntry(
            _penerimaanPoDetailModel!.data[i].id.toString(),
            _penerimaanPoDetailModel!.data[i].nopo.toString(),
            _penerimaanPoDetailModel!.data[i].pelanggan.toString(),
            _penerimaanPoDetailModel!.data[i].produk_id.toString(),
            _penerimaanPoDetailModel!.data[i].namaproduk.toString(),
            _penerimaanPoDetailModel!.data[i].satuan_produk.toString(),
            _penerimaanPoDetailModel!.data[i].harga.toString(),
            _penerimaanPoDetailModel!.data[i].qtyorder.toString(),
            _penerimaanPoDetailModel!.data[i].qtysupply.toString(),
            _penerimaanPoDetailModel!.data[i].qtysisa.toString(),
            _penerimaanPoDetailModel!.data[i].qtyterima.toString()
          );
        }
      });
      print(inspect(_entryManager.entries));
    }
  }
  
  void _updateEntry(id, qtyTerima) {
    setState(() {
      _entryManager.updateEntry(id,qtyTerima.toString());
    });
    // if (qtyTerima.toString() != '0') {
    //   setState(() {
    //     _entryManager.updateEntry(id,qtyTerima.toString());
    //   });
    // } else {
    //   // print('Qty tidak boleh kosong atau 0');
    //   Fluttertoast.showToast(
    //     msg: "Qty tidak boleh kosong atau 0",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //   );
    // }
    print(inspect(_entryManager.entries));
  }

  void _savePembelian() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      if (nonota == null || nonota == '') {
        shoMyBadDialog(
            context: context,
            title: "Penerimaan",
            message: "Nomor Nota tidak boleh kosong!");
        // ignore: prefer_is_empty
      } else if (pembelian_id == null || pembelian_id == '') {
        shoMyBadDialog(
            context: context,
            title: "Penerimaan",
            message: "Nomor PO tidak boleh kosong!");
        // ignore: prefer_is_empty
      } else {
        // print("$nopo - $pembelian_id - $tanggal - $nonota - $smSubtotal - $smBiayaLayanan - $grandtotal - $jumlah_dp");
        showLoadingDialog(context: context);
        purchaseorderController = PurchaseorderController();
        
        var response = await purchaseorderController.savePenerimaan(
          widget.token.toString(),
          widget.userid.toString(),
          pembelian_nopo.toString(),
          pembelian_tglpo.toString(),
          tanggal,
          nonota,
          pembelian_supplierid.toString(),
          pembelian_tipeppn.toString(),
          pembelian_idsyaratbayar.toString(),
          _entryManager.entries
        );
        if (response) {
          hideLoadingDialog(context);
          Navigator.pop(context, 'refresh');
        }
      }
    }
  }

  Future<void> toPenerimaanPOPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  PenerimaanPoPage(token: widget.token, userid: widget.userid),
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
        pembelian_id = result["id"];
        pembelian_nopo = result["nopo"];
        pembelian_tglpo = result["tgl_po"];
        pembelian_supplierid = result["supplier_id"];
        pembelian_supplier = result["supplier"];
        pembelian_tipeppn = result["tipeppn"];
        pembelian_idsyaratbayar = result["id_syaratbayar"];
        _dataPoDetail(widget.token.toString(), pembelian_nopo.toString());
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final NavigatorState navigator = Navigator.of(context);
            final bool shouldPop = await _showBackDialog();
            if (shouldPop == false) {
              // fungsi hapus temp detail
            }
          },
        ),
        title: const Text("Tambah Penerimaan",
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
                            child: Text("Informasi Penerimaan",
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
                                    text: _penerimaanNopuModel == null
                                        ? ''
                                        : _penerimaanNopuModel!.data[0].nopu
                                            .toString()),
                                decoration: InputDecoration(
                                    labelText: 'Nomor GR',
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
                      BootstrapRow(
                        height: 60,
                        children: [
                          BootstrapCol(
                            sizes: 'col-12',
                            child: TextFormField(
                              maxLines: null,
                              controller: nonotaController,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                  labelText: 'No Nota',
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
                                nonota = value!;
                              },
                            ),
                          ),
                        ],
                      ),
                      BootstrapRow(
                        height: 60,
                        children: [
                          BootstrapCol(
                            sizes: 'col-12',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: TextFormField(
                                readOnly: true,
                                controller: TextEditingController(text: pembelian_nopo),
                                decoration: InputDecoration(
                                  labelText: 'Nomor PO',
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
                                    onPressed: () => toPenerimaanPOPage(),
                                  ),
                                ),
                                onTap: () => toPenerimaanPOPage(),
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
                                    child: _entryManager.entries == null ? const ListMenuShimmer(total: 4, circular: 4, height: 42)
                                        : _entryManager.entries.length == 0
                                            ? const Center( child: Text('Belum ada data'))
                                            : ListView.builder(
                                                physics: const ScrollPhysics(parent:ClampingScrollPhysics()),
                                                itemCount: _entryManager.entries.length,
                                                itemBuilder:(context, index) {
                                                  return orderItemDetail(index, _entryManager.entries[index]);
                                                },
                                              ),
                                  )),
                                  // Divider(height: 1, color: Colors.grey[200]),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 8),
                                  //   child:Text('Total 0 Produk, 0 Karton'),
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
                    SizedBox(
                      width: (screenWidth) - 16,
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
                          'Simpan Penerimaan',
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

  Widget orderItemDetail(int index, PenerimaanPoDetail data) {
    double screenWidth = MediaQuery.of(context).size.width;

    var no = index + 1;
    Color? color = Colors.white;
    if (no % 2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    

    return GestureDetector(
      onTap: () => _updateQtyTerima(data),
      child: Column(
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
                    width: screenWidth * 0.76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.namaproduk.toString(),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[800])),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Qty Order : ${CurrencyFormat.convertNumber(int.parse(data.qtyorder.toString()), 0)}',
                                style: TextStyle(color: Colors.grey[800])),
                            Text('Qty Supply : ${CurrencyFormat.convertNumber(int.parse(data.qtysupply.toString()), 0)}',
                                style: TextStyle(color: Colors.grey[800])),
                            Text('Qty Sisa : ${CurrencyFormat.convertNumber(int.parse(data.qtysisa.toString()), 0)}',
                                style: TextStyle(color: Colors.grey[800])),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )),
          // Divider(color: Colors.grey[200])
        ],
      ),
    );
  }

  Future<void> _updateQtyTerima(PenerimaanPoDetail data) async {
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
          child: Text('Penerimaan Produk',
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
                            Text(data.namaproduk.toString(),
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
                                "${CurrencyFormat.convertToIdr(int.parse(data.harga.toString()), 0)} / ${data.satuan_produk}",
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
                        sizes: 'col-md-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty Order",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                CurrencyFormat.convertNumber(
                                    int.parse(data.qtyorder.toString()), 0),
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
                        sizes: 'col-md-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty Supply",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                CurrencyFormat.convertNumber(
                                    int.parse(data.qtysupply.toString()), 0),
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
                        sizes: 'col-md-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty Sisa",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                CurrencyFormat.convertNumber(
                                    int.parse(data.qtysisa.toString()), 0),
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
                          child: Text("Qty Terima",
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
                            controller: qtyTerimaController,
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
                                String value = qtyTerimaController.text.trim();
                                int newQty = int.tryParse(value) ?? 0;
                                _updateEntry(data.id, newQty.toString());
                                Navigator.of(context).pop();
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
                                'Set Qty Terima',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PenerimaanPoPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const PenerimaanPoPage({super.key, this.token, this.userid});

  @override
  State<PenerimaanPoPage> createState() => _PenerimaanPoPageState();
}

class _PenerimaanPoPageState extends State<PenerimaanPoPage> {
  final _formKey = GlobalKey<FormState>();
  // final FormPembelianDetailManager _entryManager = FormPembelianDetailManager();

  late PurchaseorderController purchaseorderController;
  PembelianPOModel? _penerimaanPoModel;
  final userController = UserController(StorageService());

  String _selectedNopo = "";

  @override
  void initState() {
    super.initState();
    purchaseorderController = PurchaseorderController();
    _dataSupplier();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataSupplier() async {
    final user = await userController.getUserFromStorage();
    PembelianPOModel? data = await purchaseorderController.getpenerimaanpo(
        user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _penerimaanPoModel = data;
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
        title: const Text("Penerimaan PO",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: dataPenerimaanPO(),
    );
  }

  Widget dataPenerimaanPO() {
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
                child: _penerimaanPoModel == null
                    ? const ListMenuShimmer(total: 5)
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _penerimaanPoModel!.data.length,
                        itemBuilder: (context, index) {
                          return listSupplier(_penerimaanPoModel!.data[index]);
                        }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listSupplier(PembelianPO data) {
    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNopo = data.id.toString();
          Navigator.pop(context, {
            "id": data.id,
            "nopo": data.nopo,
            "tgl_po": data.tgl_po,
            "supplier_id": data.supplier_id,
            "supplier": data.supplier,
            "tipeppn" : data.tipeppn,
            "id_syaratbayar" : data.id_syaratbayar
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color:
              _selectedNopo == data.id ? const Color(0xFFfcf5e1) : Colors.white,
          border: Border.all(
              color: _selectedNopo == data.id
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
                Text(
                  data.nopo.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatDate(data.tgl_po.toString()),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.supplier.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Total ${CurrencyFormat.convertNumber(int.parse(data.item.toString()), 0)} Produk, ${CurrencyFormat.convertNumber(int.parse(data.qty.toString()), 0)} Karton',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
