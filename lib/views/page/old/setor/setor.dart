import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/old/setorsaldo_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/setorsaldo_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/old/setor/edit.dart';
import 'package:eahmindonesia/views/page/old/setor/tambah.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';

class SetorPage extends StatefulWidget {
  const SetorPage({super.key});

  @override
  State<SetorPage> createState() => _SetorPageState();
}

class MyMonth {
  String name;
  int id;
  MyMonth(this.name, this.id);
}

class MyYear {
  String year;
  MyYear(this.year);
}

class _SetorPageState extends State<SetorPage> {
  final authController = AuthController(ApiServive(), StorageService());
  late SetorSaldoController setorSaldoController;
  SetorSaldoModel? _setorSaldoModel;
  final storageService = StorageService();
  final userController = UserController(StorageService());
  final thisMonth = DateTime.now().month;
  final thisYear = DateTime.now().year;

  String userId = "",
      userName = "",
      userEmail = "",
      userOutletId = "",
      userOutletName = "",
      userToken = "";
  bool isLoading = true;

  List<MyMonth> months = [
    MyMonth('Januari', 1),
    MyMonth('Februari', 2),
    MyMonth('Maret', 3),
    MyMonth('April', 4),
    MyMonth('Mei', 5),
    MyMonth('Juni', 6),
    MyMonth('Juli', 7),
    MyMonth('Agustus', 8),
    MyMonth('September', 9),
    MyMonth('Oktober', 10),
    MyMonth('November', 11),
    MyMonth('Desember', 12),
  ];

  List<MyYear> years = [
    MyYear('2024'),
    MyYear('2025'),
    MyYear('2026'),
    MyYear('2027'),
    MyYear('2028'),
    MyYear('2029'),
    MyYear('2030'),
    MyYear('2031'),
    MyYear('2032'),
    MyYear('2033'),
    MyYear('2034'),
    MyYear('2035'),
  ];

  late int selectedThisMonth = thisMonth;
  late String selectedThisYear = thisYear.toString();
  late String selectedMonthName = months[thisMonth - 1].name.toString();

  @override
  void initState() {
    super.initState();
    _dataUser();
  }

  @override
  void dispose() {
    // Dispose resources
    _checkToken();
    super.dispose();
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      print('Valid Token');
      // _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();
    final outlet_id = await storageService.getOutletId();
    final outlet_name = await storageService.getOutletName();
    setState(() {
      isLoading = true;
    });
    setState(() {
      userId = user!.uid.toString();
      userName = user.name.toString();
      userEmail = user.email.toString();
      userOutletId = outlet_id.toString();
      userOutletName = outlet_name.toString();
      userToken = user.token.toString();
      setorSaldoController = SetorSaldoController();
      _dataSetorSaldo(userToken, userOutletId, selectedThisMonth.toString(), selectedThisYear);
      isLoading = false;
    });
  }

  Future<void> _dataSetorSaldo(token, outletId, month, year) async {
    SetorSaldoModel? data =
        await setorSaldoController.getSetorSaldo(token, outletId, month, year);
    if (mounted) {
      setState(() {
        _setorSaldoModel = data;
      });
    }
  }

  Future<void> toTambahSetorSaldoPage() async {
    // Use await so that we can run code after the child page is closed
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => TambahSetorSaldoPage(
    //           token : userToken,
    //           outletId: userOutletId,
    //           newnota: _setorSaldoModel!.heads[0].newnota.toString())),
    // );

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => //DrawerExample(),
        TambahSetorSaldoPage(
              token : userToken,
              outletId: userOutletId,
              newnota: _setorSaldoModel!.heads[0].newnota.toString()),
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
        setorSaldoController = SetorSaldoController();
        _dataSetorSaldo(userToken, userOutletId, selectedThisMonth.toString(), selectedThisYear);
      });
    }
  }

  void _delSetorSaldo(String token, String id) async {
    showLoadingDialog(context: context);
    setorSaldoController = SetorSaldoController();
    var response = await setorSaldoController.delSetorSaldo(token, id);
    if (response) {
      hideLoadingDialog(context);
      setState(() {
        setorSaldoController = SetorSaldoController();
        _dataSetorSaldo(userToken, userOutletId, selectedThisMonth.toString(), selectedThisYear);
      });
    }
  }

  Future<void> toEditSetorSaldoPage(
      String id, String nota, String tgl, int nilai) async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditSetorSaldoPage(
              token : userToken,
              outletId: userOutletId,
              id: id,
              nota: nota,
              tgl: tgl,
              nilai: nilai)),
    );

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        setorSaldoController = SetorSaldoController();
        _dataSetorSaldo(userToken, userOutletId, selectedThisMonth.toString(), selectedThisYear);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Row(
            children: [
              // Icon(Icons.wallet),
              SizedBox(width: 5),
              Text("Setor Saldo",
                  style: TextStyle(
                      color: Color.fromARGB(255, 17, 19, 21),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 254, 185, 3),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (screenWidth / 2) - 12,
                    child: TextField(
                      keyboardType: TextInputType.none,
                      showCursor: false,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        suffixIcon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        hintText: selectedMonthName,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: _showBulan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: (screenWidth / 2) - 12,
                    child: TextField(
                      showCursor: false,
                      keyboardType: TextInputType.none,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        suffixIcon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        hintText: selectedThisYear,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: _showTahun,
                    ),
                  )
                ],
              ),
            ),
            const Divider(color: Colors.black12),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: _setorSaldoModel == null
                  ? const CircularLoading()
                  : _setorSaldoModel!.posts.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _setorSaldoModel!.posts.length,
                          itemBuilder: (context, index) {
                            var id =
                                _setorSaldoModel!.posts[index].id.toString();
                            var nota =
                                _setorSaldoModel!.posts[index].nota.toString();
                            var tgl =
                                _setorSaldoModel!.posts[index].tgl.toString();
                            var nilai =
                                _setorSaldoModel!.posts[index].nilai.toString();
                            return listData(id, nota, tgl, int.parse(nilai));
                          }),
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 254, 185, 3),
            onPressed: toTambahSetorSaldoPage,
            child: const Icon(Icons.add_outlined, color: Colors.black87)));
  }

  Widget listData(String id, String nota, String tgl, int nilai) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        _showAction(id, nota, tgl, nilai);
      },
      child: Container(
          height: screenHeight * 0.085,
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
                  Text(nota,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(
                    tgl,
                    style: TextStyle(color: Colors.grey[800], fontSize: 14.0),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormat.convertToIdr(nilai, 0),
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Future<void> _showBulan() async {
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
          child: Text('Bulan',
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        contentPadding:
            const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
        content: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          width: double.minPositive,
          height: screenHeight / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: months.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      width: screenWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: months[index].id == selectedThisMonth
                              ? const Color(0xFFFFD464)
                              : null,
                          border: const BorderDirectional(
                              bottom: BorderSide(color: Colors.black12))),
                      child: Text(months[index].name,
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16)),
                    ),
                    onTap: () {
                      setState(() {
                        selectedThisMonth = months[index].id;
                        selectedMonthName = months[index].name;

                        setorSaldoController = SetorSaldoController();
                        _dataSetorSaldo(userToken, userOutletId,selectedThisMonth.toString(), selectedThisYear);
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTahun() async {
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
          child: Text('Tahun',
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        titlePadding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        contentPadding:
            const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
        content: SizedBox(
          width: double.minPositive,
          height: screenHeight / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      width: screenWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: years[index].year == selectedThisYear
                              ? const Color(0xFFFFD464)
                              : null,
                          border: const BorderDirectional(
                              bottom: BorderSide(color: Colors.black12))),
                      child: Text(years[index].year,
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16)),
                    ),
                    onTap: () {
                      setState(() {
                        selectedThisYear = years[index].year;
                        setorSaldoController = SetorSaldoController();
                        _dataSetorSaldo(userToken, userOutletId,selectedThisMonth.toString(), selectedThisYear);
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAction(
      String id, String nota, String tgl, int nilai) async {
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
                  color: Colors.grey[800], fontWeight: FontWeight.bold)),
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
                      Text('Edit',
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16))
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  toEditSetorSaldoPage(id, nota, tgl, nilai);
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
                  _showConfirmDialog(id, nota);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String id, String nota) async {
    // Show a dialog to confirm exit
    bool shouldPop = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF5F5F5),
            title: const Text('Apakah anda yakin?'),
            content: Text('Hapus setor saldo : $nota?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Tidak', style: TextStyle(color: Colors.grey[800])),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  _delSetorSaldo(userToken,id);
                },
                child: const Text('Ya', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
    return shouldPop;
  }
}
