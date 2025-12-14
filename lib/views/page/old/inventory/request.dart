import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
// import 'package:eahmindonesia/views/page/inventory/detail.dart';
import 'package:eahmindonesia/views/page/old/inventory/tambahrequest.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestInventoryPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  const RequestInventoryPage({super.key, this.token, this.outletId});

  @override
  State<RequestInventoryPage> createState() => _RequestInventoryPageState();
}

class _RequestInventoryPageState extends State<RequestInventoryPage> {
  late InventoryController inventoryController;
  RequestInventoryModel? _requestInventoryModel;

  DateTime _selectedDate = DateTime.now();
  TextEditingController idController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String tanggal = '';
  String qty_supply = '';

  void _updateForm(String token, String id, String status) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      print(id + '# ${tanggal} #' + status + '#' + qty_supply);

      showLoadingDialog(context: context);
      inventoryController = InventoryController();
      var response =
          await inventoryController.updateInventory(token, id, tanggal, status, qty_supply);
      if (response) {
        hideLoadingDialog(context);
        _dataRequestInventory(widget.token, widget.outletId);
        Navigator.pop(context, 'refresh');
      }
    }
  }

  void _delInventory(String token, String id) async {
    showLoadingDialog(context: context);
    inventoryController = InventoryController();
    var response = await inventoryController.delInventory(token, id);
    if (response) {
      hideLoadingDialog(context);
      setState(() {
        inventoryController = InventoryController();
        _dataRequestInventory(widget.token, widget.outletId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dataRequestInventory(widget.token, widget.outletId);
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _dataRequestInventory(token, outletId) async {
    inventoryController = InventoryController();
    RequestInventoryModel? data = await inventoryController.getRequestInventory(token, outletId);
    setState(() {
      _requestInventoryModel = data;
    });
  }

  Future<void> toRequestStockPage() async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => //DrawerExample(),
        RequestStockPage(token: widget.token.toString(),outletId: widget.outletId.toString()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      )
    );

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        _dataRequestInventory(widget.token, widget.outletId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
            color: Colors.grey[800],
            onRefresh: () => _dataRequestInventory(widget.token.toString(), widget.outletId.toString()),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _requestInventoryModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _requestInventoryModel!.posts.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _requestInventoryModel!.posts.length,
                          itemBuilder: (context, index) {
                            var id = _requestInventoryModel!.posts[index].id.toString();
                            var material = _requestInventoryModel!.posts[index].material
                                .toString();
                            var satuan =
                                _requestInventoryModel!.posts[index].satuan.toString();
                            var keterangan = _requestInventoryModel!
                                .posts[index].keterangan
                                .toString();
                            var tgl = _requestInventoryModel!.posts[index].tglRequest.toString();
                            var qtysisa = _requestInventoryModel!.posts[index].qtySisa.toString();
                            return listData(
                                id, material, satuan, keterangan, tgl, qtysisa);
                          }),
            ),
          ))
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'request_stock',
            backgroundColor: const Color.fromARGB(255, 254, 185, 3),
            onPressed: toRequestStockPage,
            child: const Icon(Icons.add_outlined, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget listData(String id, String material, String satuan, String keterangan, String tgl, String qty_sisa) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        _showAction(id, 'Request', 'Supply', material, satuan, keterangan);
      },
      child: Container(
          // height: screenHeight * 0.085,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(material,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(
                    '$keterangan / $satuan',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  )
                ],
              ),
              const Divider(color: Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request : $tgl',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  ),
                  Text(
                    'Sisa : $qty_sisa',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Future<void> _showAction(String id, String status, String newStatus,
      String material, String satuan, String keterangan) async {
    // Show a dialog to confirm exit
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 254, 185, 3),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Text('Action',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        contentPadding:
            const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
        content: SizedBox(
          width: double.minPositive,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Container(
                  width: screenWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: BorderDirectional(
                          bottom: BorderSide(color: Colors.black12))),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.grey[800]),
                      const SizedBox(width: 10),
                      Text('Update Status',
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16))
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _showUpdateAction(
                      id, status, newStatus, material, satuan, keterangan);
                },
              ),
              GestureDetector(
                child: Container(
                  width: screenWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: BorderDirectional(
                          bottom: BorderSide(color: Colors.black12))),
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.grey[800]),
                      const SizedBox(width: 10),
                      Text('Hapus',
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16))
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _showConfirmDialog(id);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateAction(String id, String status, String newStatus,
      String material, String satuan, String keterangan) async {
    // Show a dialog to confirm exit
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 254, 185, 3),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Text('Update : $status → $newStatus',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        contentPadding:
            const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
        content: SizedBox(
          // width: double.minPositive,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(material,
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(
                        '$keterangan / $satuan',
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 16.0),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: const Text('Tanggal',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 254, 185, 3))),
                          subtitle: TextFormField(
                              controller: tanggalController =
                                  TextEditingController(text: ''),
                              style: const TextStyle(color: Colors.white),
                              cursorColor: const Color.fromARGB(255, 254, 185, 3),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[800]!),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              focusNode: AlwaysDisabledFocusNode(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal masih kosong';
                                }
                                return null;
                              },
                              onTap: () {
                                _selectDate(context);
                              }),
                        ),
                      ),
                      // const SizedBox(height: 5),
                      Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: const Text('Qty Supply',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 254, 185, 3))),
                          subtitle: TextFormField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: const Color.fromARGB(255, 254, 185, 3),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[800]!),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Qty masih kosong';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              qty_supply = value!;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Card(
                    shadowColor: Colors.transparent,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor:
                              const Color.fromARGB(255, 254, 185, 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          _updateForm(widget.token.toString(), id, newStatus);
                        },
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.grey[800]),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String id) async {
    // Show a dialog to confirm exit
    bool shouldPop = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF5F5F5),
            title: const Text('Apakah anda yakin?'),
            content: const Text('Hapus request stock?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Tidak', style: TextStyle(color: Colors.grey[800])),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  _delInventory(widget.token.toString(), id);
                },
                child: const Text('Ya', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
    return shouldPop;
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
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
