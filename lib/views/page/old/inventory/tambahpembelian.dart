import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/main.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:eahmindonesia/widgets/camera.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembelianStockPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  const PembelianStockPage({super.key, this.token, this.outletId});

  @override
  State<PembelianStockPage> createState() => _PembelianStockPageState();
}

class _PembelianStockPageState extends State<PembelianStockPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _selectedDate = DateTime.now();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController materialNameController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  late InventoryController materialController;
  late InventoryController inventoryController;
  MaterialModel? _materialModel;

  late String selectedMaterialId = "";
  late String selectedMaterialName = "";
  String tanggal = '';
  String harga = '';
  String qty = '';
  String total = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dataMaterial(widget.token, widget.outletId, '');
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _dataMaterial(token, outletId, material) async {
    materialController = InventoryController();
    MaterialModel? data =
        await materialController.getMaterial(token, outletId, material);
    if (mounted) {
      setState(() {
        _materialModel = data;
      });
    }
  }

  void _savePembelian() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      showLoadingDialog(context: context);
      inventoryController = InventoryController();
      var response = await inventoryController.savePembelian(
          widget.token.toString(),
          widget.outletId.toString(),
          tanggal,selectedMaterialId,harga,qty,total);
      if (response) {
        hideLoadingDialog(context);
        Navigator.pop(context, 'refresh');
      }
    }
  }

  double? subtotal = 0;

  void _calculateSum() {
    final String harga = hargaController.text;
    final String qty = qtyController.text;

    // Convert to double and handle possible format exceptions
    final double? num1 = double.tryParse(harga);
    final double? num2 = double.tryParse(qty);

    if (num1 != null && num2 != null) {
      setState(() {
        subtotal = num1 * num2;
      });
    } else {
      setState(() {
        subtotal = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // ← this removes the default hamburger icon
        title: const Text("Pembelian Stock",
            style: TextStyle(
                color: Color.fromARGB(255, 17, 19, 21),
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // scaffoldKey.currentState?.openDrawer(); // <- Open drawer manually
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: Drawer(
          backgroundColor: const Color.fromARGB(255, 254, 185, 3),
          child: listMaterial()),
      drawerEnableOpenDragGesture: false, // optional: swipe from right
      drawerEdgeDragWidth: 100.0,
      onDrawerChanged: (isOpened) {
        _dataMaterial(widget.token, widget.outletId, '');
      },
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        keyboardType: TextInputType.none,
                        controller: tanggalController = TextEditingController(
                            text: DateFormat.yMMMd('en_US')
                                .format(_selectedDate)
                                .toString()),
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
                // const SizedBox(height: 10),
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    title: const Text('Material',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 254, 185, 3))),
                    subtitle: TextFormField(
                      controller: materialNameController =
                          TextEditingController(text: selectedMaterialName),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 254, 185, 3),
                      decoration: InputDecoration(
                        // hintText: selectedMaterialName,
                        hintStyle: const TextStyle(color: Colors.white),
                        contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      focusNode: AlwaysDisabledFocusNode(),
                      onTap: () {
                        scaffoldKey.currentState?.openDrawer();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Material masih kosong';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        selectedMaterialName = value!;
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: (screenWidth / 2) - 8,
                        child: Card(
                          color: Colors.grey[800],
                          child: ListTile(
                            title: const Text('Harga',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 254, 185, 3))),
                            subtitle: TextFormField(
                              controller: hargaController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              cursorColor:
                                  const Color.fromARGB(255, 254, 185, 3),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[800]!),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harga masih kosong';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _calculateSum();
                              },
                              onSaved: (value) {
                                harga = value!;
                              },
                            ),
                          ),
                        )),
                    SizedBox(
                        width: (screenWidth / 2) - 8,
                        child: Card(
                          color: Colors.grey[800],
                          child: ListTile(
                            title: const Text('Qty',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 254, 185, 3))),
                            subtitle: TextFormField(
                              controller: qtyController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              cursorColor:
                                  const Color.fromARGB(255, 254, 185, 3),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[800]!),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                _calculateSum();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Qty masih kosong';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                qty = value!;
                              },
                            ),
                          ),
                        ))
                  ],
                ),
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    title: const Text('Total',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 254, 185, 3))),
                    subtitle: TextFormField(
                      controller: totalController =
                          TextEditingController(text: subtotal.toString()),
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
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Total masih kosong';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        total = value!;
                      },
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => TakePictureScreen(token: widget.token.toString(), camera: cameras.first),
                //       ),
                //     );
                //   },
                //   child: Icon(Icons.camera_alt)
                // ),
                Card(
                  shadowColor: Colors.transparent,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        _savePembelian();
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listMaterial() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // ← this removes the default hamburger icon
        title: const Text("Data Material",
            style: TextStyle(
                color: Color.fromARGB(255, 17, 19, 21),
                fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                  _dataMaterial(widget.token, widget.outletId, value);
                },
              ),
            ),
            Expanded(
                child: _materialModel == null
                    ? const CircularLoading()
                    : ListView.builder(
                        itemCount: _materialModel!.posts.length,
                        itemBuilder: (context, index) {
                          var id = _materialModel!.posts[index].id.toString();
                          var material =
                              _materialModel!.posts[index].material.toString();
                          var keterangan = _materialModel!
                              .posts[index].keterangan
                              .toString();
                          var satuan =
                              _materialModel!.posts[index].satuan.toString();
                          return GestureDetector(
                            child: Container(
                              // width: screenWidth,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: id == selectedMaterialId
                                      ? const Color(0xFFFFD464)
                                      : null,
                                  border: const BorderDirectional(
                                      bottom: BorderSide(
                                          color: Color.fromARGB(
                                              31, 173, 171, 171)))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(material,
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16)),
                                  Text('@ $keterangan / $satuan',
                                      style: TextStyle(color: Colors.grey[800]))
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedMaterialId = id;
                                selectedMaterialName = material;
                              });
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          );
                        },
                      ))
          ],
        ),
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
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
