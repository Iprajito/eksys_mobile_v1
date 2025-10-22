import 'package:eahmindonesia/controllers/dashboard_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/dashboard_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/old/inventory/tambahrequest.dart';
import 'package:eahmindonesia/views/page/main.dart';
import 'package:eahmindonesia/views/page/old/setor/tambah.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:eahmindonesia/controllers/auth_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _locationMessage = '';

  final storageService = StorageService();
  final userController = UserController(StorageService());

  late DashboardController dashboardController;
  DashboardModel? _dashboardModel;

  DateTime datenow = DateTime.now();

  String userId = "",
      userName = "",
      userEmail = "",
      userOutletId = "",
      userOutletName = "",
      userToken = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _dataUser();
  }

  @override
  void dispose() {
    // Dispose resources
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
    setState(() {
      isLoading = true;
    });

    final user = await userController.getUserFromStorage();
    final outlet_id = await storageService.getOutletId();
    final outlet_name = await storageService.getOutletName();
    setState(() {
      userId = user!.uid.toString();
      userName = user.name.toString();
      userEmail = user.email.toString();
      userOutletId = outlet_id.toString();
      userOutletName = outlet_name.toString();
      userToken = user.token.toString();
      _dataSummaryDashboard(userToken, userOutletId);
      isLoading = false;
    });
  }

  Future<void> _dataSummaryDashboard(userToken, outletId) async {
    setState(() {
      _dashboardModel = null;
    });
    
    dashboardController = DashboardController();
    DashboardModel? data =
        await dashboardController.getDashboard(userToken, outletId);
    if (mounted) {
      setState(() {
        _dashboardModel = data;
      });
    }
  }

  // Method to get the current location
  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Check if location services are enabled
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     setState(() {
  //       _locationMessage = "Location services are disabled.";
  //     });
  //     return;
  //   }

  //   // Check location permission
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       setState(() {
  //         _locationMessage = "Location permissions are denied.";
  //       });
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     setState(() {
  //       _locationMessage = "Location permissions are permanently denied.";
  //     });
  //     return;
  //   }

  //   // Get the current position
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   if (mounted) {
  //     setState(() {
  //       _locationMessage =
  //           'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // print('Uid ${userId.toString()}');
    // print('Name ${userName.toString()}');
    // print('Email ${userEmail.toString()}');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        title: Row(
          children: [
            Container(
              height: 50,
              width: 200,
              decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  //  border: Border.all(color: Colors.grey, width: 1),
                  image: DecorationImage(
                      image: AssetImage("assets/images/logo.png"),
                      fit: BoxFit.cover)),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
        // actions: [
        // NotifIcon(
        //   uid: ref.watch(userDataProvider).valueOrNull!.uid,
        // ),
        // ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Stack(
            children: [
              const RoundedAppBar(),
              Positioned(
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? buildShimmer(200)
                          : Text(userName,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 17, 19, 21),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20)),
                      isLoading
                          ? buildShimmer(200)
                          : Text(userOutletName,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 17, 19, 21),
                                  // fontWeight: FontWeight.w700,
                                  fontSize: 15))
                    ],
                  )),
              Positioned(
                  // top: 20,
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              spreadRadius: 0,
                              offset: Offset(0, 3)),
                        ]),
                    alignment: Alignment.bottomCenter,
                    height: 90,
                    child: IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                              height: 100.0, //color: Colors.cyan,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Saldo",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 17, 19, 21),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20)),
                                  _dashboardModel == null
                                      ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                      : Text(
                                          CurrencyFormat.convertToIdr(
                                              int.parse(_dashboardModel!
                                                  .posts[0].saldo
                                                  .toString()),
                                              0),
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 17, 19, 21),
                                              // fontWeight: FontWeight.w700,
                                              fontSize: 17))
                                ],
                              ),
                            )),
                            const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: VerticalDivider(
                                thickness: 1,
                                width: 1, // total space taken by the divider
                                color: Color.fromARGB(80, 254, 187, 3) //Color.fromARGB(255, 236, 230, 230),
                              ),
                            ),
                            Expanded(
                                child: Container(
                                padding: const EdgeInsets.all(10.0),
                              // decoration: const BoxDecoration(
                              //     border: Border(
                              //   left: BorderSide(
                              //     color: Colors.black26, // Color for top border
                              //     width:
                              //         1.0, // Setting width to 0 makes the top border invisible
                              //   ),
                              // )),
                              height: 100.0, //color: Colors.cyan,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Penjualan",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 17, 19, 21),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20)),
                                  _dashboardModel == null
                                      ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                      : Text(
                                          CurrencyFormat.convertToIdr(
                                              int.parse(_dashboardModel!
                                                  .posts[0].penjualan
                                                  .toString()),
                                              0),
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 17, 19, 21),
                                              // fontWeight: FontWeight.w700,
                                              fontSize: 17))
                                ],
                              ),
                            )),
                          ]),
                    ),
                  ))
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color.fromARGB(255, 254, 185, 3),
              onRefresh: () => _dataUser(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB902),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.fingerprint,
                                          color: Colors.grey[800]),
                                      const SizedBox(height: 5),
                                      Text('Presensi',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1)),
                                      Text('Kehadiran',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB902),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart_sharp,
                                            color: Colors.grey[800]),
                                        const SizedBox(height: 5),
                                        Text('Tambah',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[800],
                                                height: 1)),
                                        Text('Pesanan',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[800],
                                                height: 1))
                                      ],
                                    ),
                                    onTap: () async {
                                      // final result = await Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             TambahPesananPage(
                                      //                 token: userToken,
                                      //                 outletId: userOutletId,
                                      //                 nota: _dashboardModel!
                                      //                     .posts[0]
                                      //                     .notapesanan)));

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainPage(currIndex: 1)));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB902),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warehouse_sharp,
                                          color: Colors.grey[800]),
                                      const SizedBox(height: 5),
                                      Text('Request',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1)),
                                      Text('Stock',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RequestStockPage(
                                                  token: userToken,
                                                  outletId: userOutletId)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB902),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.wallet_sharp,
                                          color: Colors.grey[800]),
                                      const SizedBox(height: 5),
                                      Text('Tambah',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1)),
                                      Text('Setor Saldo',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                              height: 1))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TambahSetorSaldoPage(
                                                    token: userToken,
                                                    outletId: userOutletId,
                                                    newnota: _dashboardModel!
                                                        .posts[0].notasetor)));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // const ListMenuShimmer(total: 5),
                    SizedBox(
                      height: screenHeight / 3,
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                  "Penjualan Hari Ini $_locationMessage",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17)),
                            ),
                            const Divider(color: Colors.black12, height: 0),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _dashboardModel == null
                                  ? const ListMenuShimmer(total: 4, circular: 4, height: 42)
                                  : _dashboardModel!.jual.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada pesanan'))
                                      : ListView.builder(
                                          physics: ScrollPhysics(
                                              parent: ClampingScrollPhysics()),
                                          itemCount:
                                              _dashboardModel!.jual.length,
                                          itemBuilder: (context, index) {
                                            var nota = _dashboardModel!
                                                .jual[index].nota
                                                .toString();
                                            var metode = _dashboardModel!
                                                .jual[index].metode
                                                .toString();
                                            var menu = _dashboardModel!
                                                .jual[index].menu
                                                .toString();
                                            var qty = int.parse(_dashboardModel!
                                                .jual[index].qty
                                                .toString());
                                            var harga = int.parse(
                                                _dashboardModel!
                                                    .jual[index].harga
                                                    .toString());
                                            var subtotal = int.parse(
                                                _dashboardModel!
                                                    .jual[index].subtotal
                                                    .toString());
                                            var jam = _dashboardModel!
                                                .jual[index].jam
                                                .toString();
                                            return listPenjualan(
                                                nota,
                                                metode,
                                                menu,
                                                qty,
                                                harga,
                                                subtotal,
                                                jam);
                                          },
                                        ),
                            ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: screenHeight / 3,
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Text("Request Stock",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17)),
                            ),
                            const Divider(color: Colors.black12, height: 0),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _dashboardModel == null
                                  ? const ListMenuShimmer(total: 4, circular: 4, height: 42)
                                  : _dashboardModel!.jual.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada data'))
                                      : ListView.builder(
                                          itemCount: _dashboardModel!
                                              .requeststock.length,
                                          itemBuilder: (context, index) {
                                            // return Text(
                                            //     '${_dashboardModel!.requeststock[index].material} ${_dashboardModel!.requeststock[index].tglRequest}');
                                            var material = _dashboardModel!
                                                .requeststock[index].material
                                                .toString();
                                            var tglRequest = _dashboardModel!
                                                .requeststock[index].tglRequest
                                                .toString();
                                            var keterangan = _dashboardModel!
                                                .requeststock[index].keterangan
                                                .toString();
                                            var satuan = _dashboardModel!
                                                .requeststock[index].satuan
                                                .toString();
                                            return listRequestStock(material,
                                                tglRequest, keterangan, satuan);
                                          },
                                        ),
                            ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget listPenjualan(String nota, String metode, String menu, int qty,
      int harga, int subtotal, String jam) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
            width: screenWidth,
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.09,
                  child: Column(
                    children: [
                      Text(nota,
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold)),
                      Text(metode,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: screenWidth * 0.70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(menu, style: TextStyle(color: Colors.grey[800])),
                          Text(jam,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[800]))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('@ ${CurrencyFormat.convertToIdr(harga, 0)}',
                              style: TextStyle(color: Colors.grey[800])),
                          Text('x ${qty}',
                              style: TextStyle(color: Colors.grey[800])),
                          Text(CurrencyFormat.convertToIdr(subtotal, 0),
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold))
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
        Divider(color: Colors.grey[200])
      ],
    );
  }

  Widget listRequestStock(
      String material, String tgl, String keterangan, String satuan) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
            width: screenWidth,
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              width: screenWidth * 0.73,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(material, style: TextStyle(color: Colors.grey[800])),
                      Text(tgl, style: TextStyle(color: Colors.grey[800]))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('@ $keterangan / $satuan',
                          style: TextStyle(color: Colors.grey[800]))
                    ],
                  )
                ],
              ),
            )),
        Divider(color: Colors.grey[200])
      ],
    );
  }

  // Build the shimmer effect while loading
  Widget buildShimmer(width) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFC79000),
      highlightColor: Color(0xFFFFC83A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: const Color(0xFFFFD464)),
              width: width.toDouble(),
              height: 20), // Simulate user name
          const SizedBox(height: 5),
          // Container(width: 200, height: 20, color: Colors.white), // Simulate email
          // SizedBox(height: 20),
          // Container(width: double.infinity, height: 150, color: Colors.white), // Simulate user details or avatar
        ],
      ),
    );
  }
}

class RoundedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoundedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth * 4;
        return ClipRect(
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SizedBox(
              width: width,
              height: width,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: width / 2 - preferredSize.height / 2),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 254, 185, 3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black54, blurRadius: 5.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(150.0);
}
