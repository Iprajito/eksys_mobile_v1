import 'dart:collection';
import 'dart:developer';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/old/setorsaldo_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/models/penerimaan_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import 'package:flutter/cupertino.dart';

class FormPembelianDetailManager {
  final Function setToZero;
  FormPembelianDetailManager(this.setToZero);
  
  final List<PenerimaanPoDetail> _entries = [];
  List<PenerimaanPoDetail> get entries => _entries;

  void addEntry(String id, String nopo, String pelanggan, String produk_id, String namaproduk, String satuan_produk, String harga, String qtyorder, String qtykirim, String qtysupply, String qtysisa, String qtyterima, String image) {
    _entries.add(PenerimaanPoDetail(
        id: id,
        nopo: nopo,
        pelanggan: pelanggan,
        produk_id: produk_id,
        namaproduk: namaproduk,
        satuan_produk: satuan_produk,
        harga: harga,
        qtyorder: qtyorder,
        qtykirim: qtykirim,
        // qtysupply: qtysupply,
        qtysupply: qtykirim,
        qtysisa: qtysisa,
        // qtyterima: qtyterima, 
        qtyterima: qtykirim, 
        image: image 
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
      int qtyTerima = int.parse(newQtyTerima.toString());
      int qtysisa = int.parse(_entries[index].qtysisa.toString());
      if (qtyTerima <= qtysisa) {
        _entries[index] = PenerimaanPoDetail(
            id: _entries[index].id,
            nopo: _entries[index].nopo,
            pelanggan: _entries[index].pelanggan,
            produk_id: _entries[index].produk_id,
            namaproduk: _entries[index].namaproduk,
            satuan_produk: _entries[index].satuan_produk,
            harga: _entries[index].harga,
            qtyorder: _entries[index].qtyorder,
            qtykirim: _entries[index].qtykirim,
            qtysupply: qtyTerima.toString(),
            qtysisa: qtysisa.toString(),
            qtyterima : qtyTerima.toString(),
            image: _entries[index].image,
        );
      } else {
        int newQtyTerima = 0;
        _entries[index] = PenerimaanPoDetail(
            id: _entries[index].id,
            nopo: _entries[index].nopo,
            pelanggan: _entries[index].pelanggan,
            produk_id: _entries[index].produk_id,
            namaproduk: _entries[index].namaproduk,
            satuan_produk: _entries[index].satuan_produk,
            harga: _entries[index].harga,
            qtyorder: _entries[index].qtyorder,
            qtykirim: _entries[index].qtykirim,
            qtysupply: _entries[index].qtysupply,
            qtysisa: _entries[index].qtysisa,
            qtyterima : newQtyTerima.toString(),
            image: _entries[index].image,
        );
        Fluttertoast.showToast(
          msg: "Qty Terima melebihi sisa order",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      setToZero();
    }
  }
}

class TambahPenerimaanPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  const TambahPenerimaanPage({super.key, this.token, this.userid, this.idencrypt});

  @override
  State<TambahPenerimaanPage> createState() => _TambahPenerimaanPageState();
}

class _TambahPenerimaanPageState extends State<TambahPenerimaanPage> {
  late final FormPembelianDetailManager _entryManager;
  late PurchaseorderController purchaseorderController;
  PenerimaanNopuModel? _penerimaanNopuModel;

  PembelianModel? _pembelianModel;
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

  final DateTime _selectedDate = DateTime.now();
  // TextEditingController nopoController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController nonotaController = TextEditingController();
  TextEditingController qtyTerimaController = TextEditingController(text: "");

  void setQtyToZero() {
    qtyTerimaController.text = "";
  }

  late SetorSaldoController setorSaldoController;

  final _formKey = GlobalKey<FormState>();
  // String nopo = '';
  String tanggal = '';
  // String nonota = '';

  // String? pembelian_id;
  // String? pembelian_nopo;
  // String? pembelian_tglpo;
  // String? pembelian_supplierid;
  // String? pembelian_supplier;
  // String? pembelian_tipeppn;
  // String? pembelian_idsyaratbayar;

  @override
  void initState() {
    super.initState();
    _entryManager = FormPembelianDetailManager(setQtyToZero);
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
        _dataPembelian(widget.token.toString(), widget.userid.toString(), widget.idencrypt.toString());
        _dataPoDetail(widget.token.toString(), widget.idencrypt.toString());
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

  void _dataPembelian(String token, String userid, String idencrypt) async {
    PembelianModel? data =
        await purchaseorderController.getpengirimanbyid(token, userid, idencrypt);
    if (mounted) {
      setState(() {
        _pembelianModel = data;
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
            _penerimaanPoDetailModel!.data[i].qtykirim.toString(),
            _penerimaanPoDetailModel!.data[i].qtysupply.toString(),
            _penerimaanPoDetailModel!.data[i].qtysisa.toString(),
            _penerimaanPoDetailModel!.data[i].qtyterima.toString(),
            _penerimaanPoDetailModel!.data[i].image.toString()
          );
        }
      });
      // print(inspect(_entryManager.entries));
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

  bool allQtyZero() {
    return _entryManager.entries.every((e) {
      final text = e.qtyterima.toString();
      return text.isEmpty || text == "0";
    });
  }
  
  void _savePembelian() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var nopo = _pembelianModel!.data[0].nopo.toString();
      var tglpo = _pembelianModel!.data[0].tglpo.toString();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      var nonota = _pembelianModel!.data[0].nomor_sj.toString();
      var supplierid = _pembelianModel!.data[0].supplierid.toString();
      var tipeppn = _pembelianModel!.data[0].tipeppn.toString();
      var idsyaratbayar = _pembelianModel!.data[0].id_syaratbayar.toString();
      // print(inspect(_entryManager.entries[0]));
      // print(allQtyZero());
      if (allQtyZero()) {
        shoMyBadDialog(
            context: context,
            title: "Penerimaan",
            message: "Semua Qty Terima masih 0.\nMasukkan minimal satu Qty Terima > 0.");
        // ignore: prefer_is_empty
      } else {
        // print("$supplierid");
        showLoadingDialog(context: context);
        purchaseorderController = PurchaseorderController();
        
        var response = await purchaseorderController.savePenerimaan(
          widget.token.toString(),
          widget.userid.toString(),
          nopo.toString(),
          tglpo.toString(),
          tanggal,
          nonota,
          supplierid.toString(),
          tipeppn.toString(),
          idsyaratbayar.toString(),
          _entryManager.entries
        );

        if (response) {
          hideLoadingDialog(context);
          Navigator.pop(context, 'refresh');
        }
      }
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
    
    String formatDate(String dateStr) {
      if (dateStr == '' || dateStr == '0000-00-00') {
        return '-';
      } else {
        DateTime date = DateTime.parse(dateStr);
        final df = DateFormat('dd MMM yyyy', 'id_ID');
        return df.format(date);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
          // onPressed: () async {
          //   final NavigatorState navigator = Navigator.of(context);
          //   final bool shouldPop = await _showBackDialog();
          //   if (shouldPop == false) {
          //     // fungsi hapus temp detail
          //   }
          // },
        ),
        title: const Text("Penerimaan Barang", style:TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                BootstrapContainer(
                  fluid: true, 
                  children: [
                    BootstrapRow(
                      // height: 30,
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
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
                                      child: const Text('Informasi Penerimaan Barang',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
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
                                      child: Text("No. Penerimaan",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _penerimaanNopuModel == null
                                          ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                          : Text(_penerimaanNopuModel!.data[0].nopu.toString(), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                BootstrapRow(
                                  height: 25,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Text("Tgl. Penerimaan",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(formatDate(_selectedDate.toString()), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                BootstrapRow(
                                  height: 25,
                                  children: [
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Text("No. Nota",
                                          style: TextStyle(
                                              color: Colors.grey[800],fontSize: 16)),
                                    ),
                                    BootstrapCol(
                                      sizes: 'col-6',
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _pembelianModel == null
                                          ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                          : Text(_pembelianModel!.data[0].nomor_sj.toString(), style: TextStyle(color: Colors.grey[800],fontSize: 16)),
                                      ),
                                    ),
                                  ],
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
                            child: const Text('Data Penerimaan Barang',
                              style: TextStyle(
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
                              children: _entryManager.entries.map((prod) {
                                var id            = prod.id ?? "";
                                var nopo          = prod.nopo ?? "";
                                var pelanggan     = prod.pelanggan ?? "";
                                var namaproduk    = prod.namaproduk ?? "";
                                var qtyorder      = int.tryParse(prod.qtyorder?.toString() ?? "0") ?? 0;
                                var qtykirim      = int.tryParse(prod.qtykirim?.toString() ?? "0") ?? 0;
                                var qtysupply     = int.tryParse(prod.qtysupply?.toString() ?? "0") ?? 0;
                                var qtysisa       = int.tryParse(prod.qtysisa?.toString() ?? "0") ?? 0;
                                var satuanproduk  = prod.satuan_produk ?? "";
                                var harga         = double.tryParse(prod.harga?.toString() ?? "0") ?? 0.0;
                                var image         = prod.image ?? "";
                                return orderItemDetail(id, nopo,pelanggan,namaproduk,qtyorder,qtykirim,qtysupply,qtysisa,satuanproduk,harga,image);
                              }).toList() ?? []
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

  Widget orderItemDetail(String id, String nopo, String pelanggan, String namaproduk, int qtyorder, int qtykirim, int qtysupply, int qtysisa, String satuanproduk, double harga, String image) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
                      'x${qtyorder}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormat.convertToIdr(harga, 0),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Qty Terima',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 50,
                            height: 25,
                            child: TextField(
                              readOnly: true,
                              keyboardType: TextInputType.none,
                              showCursor: false,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                  // hintText: qtysupply.toString(),
                                  hintText: qtykirim.toString(),
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
                              // onTap: () => _updateQtyTerima(id, namaproduk, qtyorder, qtysupply, qtysisa, satuanproduk, harga),
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQtyTerima(String id, String namaproduk, int qtyorder, int qtysupply, int qtysisa, String satuanproduk, double harga) async {
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
                  // BootstrapRow(
                  //   height: 40,
                  //   children: [
                  //     BootstrapCol(
                  //       fit: FlexFit.tight,
                  //       sizes: 'col-md-12',
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Nama Produk",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800], fontSize: 14)),
                  //           Text(namaproduk.toString(),
                  //               style: TextStyle(
                  //                   color: Colors.grey[800],
                  //                   fontWeight: FontWeight.w700,
                  //                   fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // BootstrapRow(
                  //   height: 40,
                  //   children: [
                  //     BootstrapCol(
                  //       fit: FlexFit.tight,
                  //       sizes: 'col-md-12',
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Harga / Satuan",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800], fontSize: 14)),
                  //           Text(
                  //               "${CurrencyFormat.convertToIdr(double.parse(harga.toString()), 0)} / $satuanproduk",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800],
                  //                   fontWeight: FontWeight.w700,
                  //                   fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // BootstrapRow(
                  //   height: 40,
                  //   children: [
                  //     BootstrapCol(
                  //       fit: FlexFit.tight,
                  //       sizes: 'col-md-6',
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Qty Order",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800], fontSize: 14)),
                  //           Text(
                  //               CurrencyFormat.convertNumber(
                  //                   int.parse(qtyorder.toString()), 0),
                  //               style: TextStyle(
                  //                   color: Colors.grey[800],
                  //                   fontWeight: FontWeight.w700,
                  //                   fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // BootstrapRow(
                  //   height: 40,
                  //   children: [
                  //     BootstrapCol(
                  //       fit: FlexFit.tight,
                  //       sizes: 'col-md-6',
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Qty Supply",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800], fontSize: 14)),
                  //           Text(
                  //               CurrencyFormat.convertNumber(
                  //                   int.parse(qtysupply.toString()), 0),
                  //               style: TextStyle(
                  //                   color: Colors.grey[800],
                  //                   fontWeight: FontWeight.w700,
                  //                   fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // BootstrapRow(
                  //   height: 40,
                  //   children: [
                  //     BootstrapCol(
                  //       fit: FlexFit.tight,
                  //       sizes: 'col-md-6',
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Qty Sisa",
                  //               style: TextStyle(
                  //                   color: Colors.grey[800], fontSize: 14)),
                  //           Text(
                  //               CurrencyFormat.convertNumber(
                  //                   int.parse(qtysisa.toString()), 0),
                  //               style: TextStyle(
                  //                   color: Colors.grey[800],
                  //                   fontWeight: FontWeight.w700,
                  //                   fontSize: 14)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                                  color: Colors.grey[800], fontSize: 16)),
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
                                _updateEntry(id, newQty.toString());
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
