import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestStockPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  const RequestStockPage({super.key, this.token, this.outletId});

  @override
  State<RequestStockPage> createState() => _RequestStockPageState();
}

class _RequestStockPageState extends State<RequestStockPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _selectedDate = DateTime.now();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController materialNameController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  late InventoryController materialController;
  late InventoryController inventoryController;
  MaterialModel? _materialModel;

  late String selectedMaterialId = "";
  String selectedMaterialName = "";
  String tanggal = '';
  String qty = '';

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

  void _saveInventory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      // print(selectedMaterialId + '# ${tanggal}');

      showLoadingDialog(context: context);
      inventoryController = InventoryController();
      var response = await inventoryController.saveInventory(
          widget.token.toString(),
          widget.outletId.toString(),
          selectedMaterialId,qty);
      if (response) {
        hideLoadingDialog(context);
        Navigator.pop(context, 'refresh');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // ← this removes the default hamburger icon
        title: const Text("Request Stock",
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
                        contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
                    controller: materialNameController = TextEditingController(text: selectedMaterialName),
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
                    },
                    onSaved: (value) {
                      selectedMaterialName = value!;
                    },
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              Card(
                color: Colors.grey[800],
                child: ListTile(
                  title: const Text('Qty Sisa',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 254, 185, 3))),
                  subtitle: TextFormField(
                    controller: qtyController,
                    // keyboardType: TextInputType.number,
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
                        return 'Qty Sisa masih kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      qty = value!;
                    },
                  ),
                ),
              ),
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
                      _saveInventory();
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
