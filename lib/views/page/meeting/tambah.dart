import 'dart:collection';
import 'dart:developer';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/meeting_controller.dart';
import 'package:Eksys/controllers/old/setorsaldo_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/meeting_model.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:flutter/cupertino.dart';

class FormMeetingDetailManager {
  final List<FormMeetingDetail> _entries = [];

  List<FormMeetingDetail> get entries => _entries;

  void addEntry(String userid, String meeting_id, String wilayah_id, String anggota_id) {
    _entries.add(FormMeetingDetail(
      userid: userid,
      meeting_id: meeting_id,
      wilayah_id: wilayah_id,
      anggota_id: anggota_id
    ));
  }

  void removeEntry(String id) {
    _entries.removeWhere((entry) => entry.wilayah_id == id || entry.anggota_id == id);
  }

  bool entryExists(String id) {
    return _entries.any((entry) => entry.wilayah_id == id || entry.anggota_id == id);
  }

  List<FormMeetingDetail> getEntries(String id) {
    return _entries.where((entry) => entry.wilayah_id == id || entry.anggota_id == id).toList();
  }
}

class TambahMeetingPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const TambahMeetingPage({super.key, this.token, this.userid});

  @override
  State<TambahMeetingPage> createState() => _TambahMeetingPageState();
}

class _TambahMeetingPageState extends State<TambahMeetingPage> {
  late MeetingController meetingController;
  TempMeetingDispacthModel? _tempMeetingModel;

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
  TimeOfDay? _selectedTime;
  TextEditingController tanggalController = TextEditingController();
  TextEditingController jamController = TextEditingController();
  TextEditingController topikController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  TextEditingController nominalController = TextEditingController();

  late SetorSaldoController setorSaldoController;

  final _formKey = GlobalKey<FormState>();
  String tanggal = '';
  String jam = '';
  String topik = '';
  String lokasi = '';
  String nominal = '';

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    meetingController = MeetingController();
    _checkToken();
    var response = meetingController.deltempmeetingdispatch(widget.token.toString(), widget.userid.toString(), '');
    _dataTempMeeting(widget.token.toString(), widget.userid.toString());
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
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        isLoading = false;
      });
    }
  }

  void _dataTempMeeting(String token, String userid) async {
    meetingController = MeetingController();
    TempMeetingDispacthModel? dataTempMeeting = await meetingController.gettempmeetingdispatch(token, userid);
    setState(() {
      _tempMeetingModel = dataTempMeeting;
    });
  }

  void _saveMeeting() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // tanggal & jam
      String tanggal = (_selectedDate != null)
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : "";

      String jam = (_selectedTime != null)
          ? formatTimeOfDay(_selectedTime!)
          : "";

      // Validasi
      if (tanggal.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Tambah Meeting",
          message: "Tanggal tidak boleh kosong!",
        );
      } else if (jam.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Tambah Meeting",
          message: "Jam tidak boleh kosong!",
        );
      } else if (topik == null || topik!.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Tambah Meeting",
          message: "Topik tidak boleh kosong!",
        );
      } else if (lokasi == null || lokasi!.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Tambah Meeting",
          message: "Lokasi tidak boleh kosong!",
        );
      } else if (_tempMeetingModel == null || _tempMeetingModel!.data.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Tambah Meeting",
          message: "Data partisipan tidak boleh kosong!",
        );
      } else {
        // Ready to save
        String? is_iuran = (isSwitched == true) ? '1' : '0';
        // print("$tanggal - $jam - $topik - $lokasi - $is_iuran - $nominal");
        showLoadingDialog(context: context);

        meetingController = MeetingController();
        var response = await meetingController.saveMeeting(
          widget.token.toString(),
          widget.userid.toString(),
          tanggal,
          jam,
          topik,
          lokasi,
          is_iuran,
          nominal
        );

        if (response) {
          hideLoadingDialog(context);
          Navigator.pop(context, 'refresh');
        }
      }
    }
  }

  void _delTempMeetingDetail() async {
    showLoadingDialog(context: context);
    meetingController = MeetingController();
    final NavigatorState navigator = Navigator.of(context);
    await meetingController.deltempmeetingdispatch(
        widget.token.toString(), widget.userid.toString(), '');
    hideLoadingDialog(context);
    navigator.pop();
  }

  _delTempMeetingDetailById(id) async {
    showLoadingDialog(context: context);
    meetingController = MeetingController();
    var response = await meetingController.deltempmeetingdispatch(
        widget.token.toString(), widget.userid.toString(), id);
    if (response) {
      hideLoadingDialog(context);
      _dataTempMeeting(widget.token.toString(), widget.userid.toString());
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
        meetingController = MeetingController();
        _dataTempMeeting(widget.token.toString(), widget.userid.toString());
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
            content: const Text('Batal Tambah Meeting ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Tidak', style: TextStyle(color: Colors.grey[800])),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batalkan',
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
          _delTempMeetingDetail();
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
                _delTempMeetingDetail();
              }
            },
          ),
          title: const Text("Tambah Meeting",
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
                              child: Text("Informasi Meeting",
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
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-6',
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  controller: jamController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Jam',
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
                                      icon: const Icon(Icons.timer),
                                      onPressed: () => _selectTime(context),
                                    ),
                                  ),
                                  onTap: () => _selectTime(context),
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
                                // maxLines: 3,
                                controller: topikController,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                    labelText: 'Topik Meeting',
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
                                  topik = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        BootstrapRow(
                          height: 100,
                          children: [
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                maxLines: 3,
                                controller: lokasiController,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                    labelText: 'Lokasi Meeting',
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
                                  lokasi = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        BootstrapRow(
                          height: 30,
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
                                      const Text('Iuran Anggota'),
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
                        Visibility(
                          visible: (isSwitched == true) ? true : false,
                          child: BootstrapRow(
                            // height: 100,
                            children: [
                              BootstrapCol(
                                sizes: 'col-12',
                                child: TextFormField(
                                  controller: nominalController,
                                  cursorColor: Colors.grey,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // hanya angka
                                    CurrencyInputFormatter(), // format ribuan
                                  ],
                                  decoration: InputDecoration(
                                      labelText: 'Nominal Iuran',
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
                                    nominal = value!.replaceAll('.', '');
                                  },
                                ),
                              ),
                            ],
                          ),
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
                                  Text("Data Partisipan",
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () => navigateToProdukPage(),
                                    child: Row(
                                      children: [
                                        Text('Tambah Partisipan',
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
                                      child: _tempMeetingModel == null
                                          ? const ListMenuShimmer(
                                              total: 4, circular: 4, height: 42)
                                          : _tempMeetingModel!
                                                      .data.length ==
                                                  0
                                              ? const Center(
                                                  child: Text('Belum ada data'))
                                              : ListView.builder(
                                                  physics: const ScrollPhysics(
                                                      parent:
                                                          ClampingScrollPhysics()),
                                                  itemCount:
                                                      _tempMeetingModel!
                                                          .data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var id =
                                                        _tempMeetingModel!
                                                            .data[index].id
                                                            .toString();
                                                    var anggota =
                                                        _tempMeetingModel!
                                                            .data[index]
                                                            .anggota
                                                            .toString();
                                                            var nama_wilayah = _tempMeetingModel!.data[index].nama_wilayah.toString();
                                                            var totanggota = _tempMeetingModel!.data[index].totanggota.toString();
                                                    return orderItemDetail(index,id,anggota,nama_wilayah, int.parse(totanggota));
                                                  },
                                                ),
                                    )),
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
                          onPressed: () => _saveMeeting(), //_savePesanan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor:
                                const Color.fromARGB(255, 254, 185, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Buat Meeting',
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

  _selectTime(BuildContext context) async {
  TimeOfDay? newSelectedTime = await showTimePicker(
    context: context,
    initialTime: _selectedTime ?? TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.input, // 👈 langsung keyboard
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFFB902), // warna utama (header & tombol)
            onPrimary: Colors.white,   // teks di atas primary
            onSurface: Colors.black,   // teks default
          ),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteColor: Color(0xFFFFE082), // background input jam & menit
            hourMinuteTextColor: Colors.black,
            dialHandColor: Color(0xFFFFB902),   // jarum jam
            dialBackgroundColor: Color(0xFFFFF3E0),
          ),
        ),
        child: child!,
      );
    },
  );

  if (newSelectedTime != null) {
    setState(() {
      _selectedTime = newSelectedTime;
      jamController
        ..text = _selectedTime!.format(context)
        ..selection = TextSelection.fromPosition(
          TextPosition(
            offset: jamController.text.length,
            affinity: TextAffinity.upstream,
          ),
        );
    });
  }
}

  Widget orderItemDetail(int index, String id, String anggota, String nama_wilayah, int totanggota) {
    double screenWidth = MediaQuery.of(context).size.width;

    var no = index + 1;
    Color? color = Colors.white;
    if (no % 2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    return GestureDetector(
      onTap: () => _delTempProduk(id, anggota, nama_wilayah, int.parse(totanggota.toString())),
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
                    child: (anggota != '') ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(anggota,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                        Text(nama_wilayah,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800])),
                      ],
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nama_wilayah,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                        Text('${CurrencyFormat.convertNumber(totanggota, 0)} Anggota',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800])),
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
  
  Future<void> _delTempProduk(
      String id, String anggota, String nama_wilayah, int totanggota) async {
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
          child: Text('Hapus Partisipan',
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
                  (anggota != '') ?
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(anggota,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Text(nama_wilayah,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ) :
                  BootstrapRow(
                    height: 40,
                    children: [
                      BootstrapCol(
                        fit: FlexFit.tight,
                        sizes: 'col-md-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama_wilayah,
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            Text(
                                "${CurrencyFormat.convertNumber(int.parse(totanggota.toString()), 0)} Anggota",
                                style: TextStyle(
                                    color: Colors.grey[800],
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
                                _delTempMeetingDetailById(id);
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
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final FormMeetingDetailManager _entryManager = FormMeetingDetailManager();
  late MasterController masterController;
  late MeetingController meetingController;
  AnggotaModel? _anggotaModel;
  WilayahModel? _wilayahModel;
  final userController = UserController(StorageService());
  final Map<String, bool> checked = {};
  final Map<String, bool> checked2 = {};

  int totqty = 0;

  void _addEntry(wilayah_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(wilayah_id) == false) {
        _entryManager.addEntry(widget.userid.toString(), '', wilayah_id, anggota_id);
      }
    });
    // print(inspect(_entryManager.entries));
  }

  void _removeEntry(wilayah_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(wilayah_id) == true) {
        _entryManager.removeEntry(wilayah_id);
      }
    });
  }

  void _addEntryAnggota(wilayah_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(anggota_id) == false) {
        _entryManager.addEntry(widget.userid.toString(), '', wilayah_id, anggota_id);
      }
    });
    // print(inspect(_entryManager.entries));
  }

  void _removeEntryAnggota(wilayah_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(anggota_id) == true) {
        _entryManager.removeEntry(anggota_id);
      }
    });
  }

  void _saveProduks() async {
    // print(inspect(_entryManager.entries));
    if (_entryManager.entries.length > 0) {
      showLoadingDialog(context: context);
      meetingController = MeetingController();
      for (var entry in _entryManager.entries) {
        await meetingController.saveTempMeetingDispatch(
            widget.token.toString(), entry);
      }
      hideLoadingDialog(context);
    }
    Navigator.pop(context, 'refresh');
  }

  @override
  void initState() {
    super.initState();
    _dataProduk();
    _dataWilayah();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  void _dataProduk() async {
    masterController = MasterController();
    final user = await userController.getUserFromStorage();
    AnggotaModel? data = await masterController.getanggota(user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _anggotaModel = data;
      });
    }
  }

  void _dataWilayah() async {
    masterController = MasterController();
    final user = await userController.getUserFromStorage();
    WilayahModel? data = await masterController.getwilayah(user!.token.toString(), user.uid.toString());
    if (mounted) {
      setState(() {
        _wilayahModel = data;
      });
    }
  }
  
  void _toggleWilayah(Wilayah node, bool? value) {
    setState(() {
      checked[node.id ?? ""] = value ?? false;
      // checked parent and check all children
      // for (var c in node.child) {
      //   _toggleWilayah(c, value);
      // }
    });
    if (value == true) {
      _addEntry(node.id, '');
    } else {
      _removeEntry(node.id, '');
    }
  }

  void _toggleAnggota(Anggota node, bool? value) {
    setState(() {
      checked2[node.id ?? ""] = value ?? false;
    });
    if (value == true) {
      _addEntryAnggota('',node.id);
    } else {
      _removeEntryAnggota('',node.id);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text("Partisipan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            backgroundColor: const Color.fromARGB(255, 0, 48, 47),
            bottom: const TabBar(
              labelColor: Colors.white,
              indicatorColor: Colors.white70,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Wilayah'),
                Tab(text: 'Anggota'),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: TabBarView(
            children: [
              dataWilayah(),
              dataProduk(),
            ],
          ),
          // dataProduk(),
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
                              'Tambahkan',
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ))),
    );
  }

  Widget _buildNode(Wilayah node, {int level = 0}) {
      final double indent = 10.0 * level; // jarak menjorok tiap level

      if (node.child.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(left: indent),
          child: ExpansionTile(
            leading: Checkbox(
              activeColor: Colors.amber,
              checkColor: Colors.white,
              value: checked[node.id ?? ""] ?? false,
              onChanged: (value) => _toggleWilayah(node, value),
            ),
            tilePadding: const EdgeInsets.only(right: 8, top: 0, bottom: 0),
            minTileHeight: 1,
            // value: checked[node.id ?? ""] ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            // contentPadding: const EdgeInsets.only(left: 0, top: 0, bottom: 0),
            // activeColor: Colors.amber,
            // checkColor: Colors.white,
            title: Text(node.nama ?? ""),
            // onChanged: (value) => setState(() {
            //   checked[node.id ?? ""] = value ?? false;
            // }),
          ),
        );
      }

      return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ExpansionTile(
          leading: Checkbox(
            activeColor: Colors.amber,
            checkColor: Colors.white,
            value: checked[node.id ?? ""] ?? false,
            onChanged: (value) => _toggleWilayah(node, value),
          ),
          tilePadding: const EdgeInsets.only(right: 8, top: 0, bottom: 0),
          minTileHeight: 1,
          title: Text(node.nama ?? ""),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: node.child.length,
              itemBuilder: (context, index) {
                return _buildNode(node.child[index], level: level + 1);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _listwilayah(Wilayah node) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      // padding: const EdgeInsets.only(left: 16, right: 0, top: 5, bottom: 5),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        minTileHeight: 0,
        leading: Checkbox(
          activeColor: Colors.amber,
          checkColor: Colors.white,
          value: checked[node.id ?? ""] ?? false,
          onChanged: (value) => _toggleWilayah(node, value),
        ),
        title: Text(node.nama.toString()),
        // subtitle: Text(node.id.toString()),
      )
    );
  }

  Widget dataWilayah() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: _formKey1,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
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
            Padding(
              padding: const EdgeInsets.only(
                    top: 0, left: 10, right: 10, bottom: 0),
              child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: _wilayahModel == null ? const ListMenuShimmer(total: 5) : _wilayahModel!.data.length == 0
                    ? const Center(child: Text('Belum ada pesanan'))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _wilayahModel!.data.length,
                      itemBuilder: (context, index) {
                      // return _buildNode(_wilayahModel!.data[index]);
                      return _listwilayah(_wilayahModel!.data[index]);
                    },
                  ),
                ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }
  
  Widget dataProduk() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: _formKey2,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
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
                child: _anggotaModel == null
                    ? const ListMenuShimmer(total: 5)
                    : _anggotaModel!.data.length == 0
                        ? const Center(child: Text('Belum ada daftar menu'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _anggotaModel!.data.length,
                            itemBuilder: (context, index) {
                              return listProduk(_anggotaModel!.data[index]);
                            }),
              ),
            ),
            // const SizedBox(height: 20),
            // Text('Entries: ${_entryManager.entries.length}'),
          ],
        ));
  }

  Widget listProduk(Anggota node) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      // padding: const EdgeInsets.only(left: 16, right: 0, top: 5, bottom: 5),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        minTileHeight: 0,
        leading: Checkbox(
          activeColor: Colors.amber,
          checkColor: Colors.white,
          value: checked2[node.id ?? ""] ?? false,
          onChanged: (value) => _toggleAnggota(node, value),
        ),
        title: Text(node.nama.toString()),
        subtitle: Text(node.wilayah.toString()),
      )
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
