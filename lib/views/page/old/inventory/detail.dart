import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryDetailPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  final String? id;
  const InventoryDetailPage({super.key,this.token, this.outletId, this.id});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  late InventoryController inventoryController;
  InventoryModel? _inventoryModel;

  DateTime _selectedDate = DateTime.now();
  TextEditingController idController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String tanggal = '';

  void _saveInventory() async {
    showLoadingDialog(context: context);
    inventoryController = InventoryController();
    var response = await inventoryController.saveInventory(widget.token.toString(), widget.outletId.toString(), widget.id.toString(), '');
    if (response) {
      hideLoadingDialog(context);
      setState(() {
        inventoryController = InventoryController();
        _dataInventory(widget.token, widget.outletId, widget.id);
      });
    }
  }

  void _updateForm(String token, String id, String status) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      print(id + '# ${tanggal} #' + status);

      showLoadingDialog(context: context);
      inventoryController = InventoryController();
      var response =
          await inventoryController.updateInventory(token, id, tanggal, status, '');
      if (response) {
        hideLoadingDialog(context);
        _dataInventory(widget.token, widget.outletId, widget.id);
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
        _dataInventory(widget.token, widget.outletId, widget.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dataInventory(widget.token, widget.outletId, widget.id);
  }

  Future<void> _dataInventory(token, outletId, id) async {
    inventoryController = InventoryController();
    InventoryModel? data = await inventoryController.getInventory(token, outletId, id);
    setState(() {
      _inventoryModel = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("Inventory Detail",
              style: TextStyle(
                  color: Color.fromARGB(255, 17, 19, 21),
                  fontWeight: FontWeight.w700)),
          backgroundColor: const Color.fromARGB(255, 254, 185, 3),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Expanded(
                child: RefreshIndicator(
              color: Colors.grey[800],
              onRefresh: () => _dataInventory(widget.token, widget.outletId, widget.id),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _inventoryModel == null
                    ? const CircularLoading()
                    : _inventoryModel!.posts.length == 0
                        ? const Center(child: Text('Belum ada data'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _inventoryModel!.posts.length,
                            itemBuilder: (context, index) {
                              var id =
                                  _inventoryModel!.posts[index].id.toString();
                              var materialId = _inventoryModel!
                                  .posts[index].materialId
                                  .toString();
                              var material = _inventoryModel!
                                  .posts[index].material
                                  .toString();
                              var satuan = _inventoryModel!.posts[index].satuan
                                  .toString();
                              var keterangan = _inventoryModel!
                                  .posts[index].keterangan
                                  .toString();
                              var tglRequest = _inventoryModel!
                                  .posts[index].tglRequest
                                  .toString();
                              var qtysisa = _inventoryModel!
                                  .posts[index].qtySisa
                                  .toString();
                              var tglSupply = _inventoryModel!
                                  .posts[index].tglSupply
                                  .toString();
                              var qtySupply = _inventoryModel!
                                  .posts[index].qtySupply
                                  .toString();
                              var tglHabis = _inventoryModel!
                                  .posts[index].tglHabis
                                  .toString();
                              var status = _inventoryModel!.posts[index].status
                                  .toString();
                              return listData(
                                  id,
                                  materialId,
                                  material,
                                  satuan,
                                  keterangan,
                                  tglRequest,
                                  qtysisa,
                                  tglSupply,
                                  qtySupply,
                                  tglHabis,
                                  status);
                            }),
              ),
            ))
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: _saveInventory,
        //   label: const Text('Request Stock',
        //       style: TextStyle(color: Colors.black87)),
        //   icon: const Icon(Icons.add_outlined, color: Colors.black87),
        //   backgroundColor: const Color.fromARGB(255, 254, 185, 3),
        // )
      );
  }

  Widget listData(
      String id,
      String materialId,
      String material,
      String satuan,
      String keterangan,
      String tglRequest,
      String qtySisa,
      String tglSupply,
      String qtySupply,
      String tglHabis,
      String status) {
    var bgcolor = const Color(0xFFFFFFFF);
    var isVisSupply = true;
    var isVisHabis = true;
    if (status == 'Requested') {
      bgcolor = const Color(0xFF6dc6fe);
      isVisSupply = false;
      isVisHabis = false;
    } else if (status == 'Supply') {
      bgcolor = const Color(0xFFFFD464);
      isVisHabis = false;
    } else if (status == 'Habis') {
      bgcolor = const Color(0xFFff7b7b);
    }

    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (status == 'Requested') {
          _showAction(id, 'Request', 'Supply', material, satuan, keterangan);
        } else if (status == 'Supply') {
          _showUpdateAction(
              id, 'Supply', 'Habis', material, satuan, keterangan);
        }
      },
      child: Container(
          // height: screenHeight * 0.12,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bgcolor,
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
                    'Request : $tglRequest',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  ),
                  Visibility(
                    visible: isVisSupply,
                    child: Text(
                      'Sisa : $qtySisa',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: isVisSupply,
                    child: Text(
                      'Supply : $tglSupply',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                    ),
                  ),
                  Visibility(
                    visible: isVisSupply,
                    child: Text(
                      'Qty : $qtySupply',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: isVisHabis,
                    child: Text(
                      'Habis : $tglHabis',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                    ),
                  ),
                ],
              )
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
                  child: Card(
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
