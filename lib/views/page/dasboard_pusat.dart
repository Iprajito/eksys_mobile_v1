import 'package:Eksys/controllers/kegiatan_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/meeting_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/kegiatan_model.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/models/meeting_model.dart';
// import 'package:Eksys/nofitication/get_fcm.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/kegiatan/detail.dart';
import 'package:Eksys/views/page/kegiatan/kegiatan.dart';
import 'package:Eksys/views/page/meeting/detail.dart';
// import 'package:Eksys/views/page/meeting/jadwal.dart';
import 'package:Eksys/views/page/meeting/meeting.dart';
import 'package:Eksys/views/page/subscribe/subscribe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Eksys/controllers/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../widgets/global_widget.dart';

class DashboardPusatPage extends StatefulWidget {
  const DashboardPusatPage({super.key});

  @override
  State<DashboardPusatPage> createState() => _DashboardPusatPageState();
}

class _DashboardPusatPageState extends State<DashboardPusatPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final storageService = StorageService();
  final userController = UserController(StorageService());

  late MasterController masterController;
  PelangganModel? _pelangganModel;

  late MeetingController meetingController;
  MeetingModel? _meetingModel;

  late KegiatanController kegiatanController;
  KegiatanModel? _kegiatanModel;

  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true, buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
    // _checkButtonEnabled();
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
      _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _checkButtonEnabled() async {
    final pb = PocketBase('https://pb.pemapi.com');

    final record = await pb
        .collection('config')
        .getFirstListItem('config_name="dashboardPusatButton"');

    final isEnabled = record.getBoolValue('active');

    print("isEnabled aktif g nih : $isEnabled");

    if (mounted) {
      setState(() {
        buttonEnabled = isEnabled;
      });
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
        _dataPelanggan(userToken, userId);
        _dataJadwaMeeting(userToken, userId);
        _dataJadwaKegiatan(userToken, userId);
        isLoading = false;
      });
    }
  }

  void _dataPelanggan(token, userid) async {
    masterController = MasterController();
    PelangganModel? dataPelanggan =
        await masterController.getpelangganbyid(token, userid);
    if (mounted) {
      setState(() {
        _pelangganModel = dataPelanggan;
      });
    }
  }

  void _dataJadwaMeeting(token, userid) async {
    meetingController = MeetingController();
    MeetingModel? dataMeeting =
        await meetingController.getmeeting(token, userid, 'new');
    if (mounted) {
      setState(() {
        _meetingModel = dataMeeting;
      });
    }
  }

  void _showComingSoonDialog(ctx) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Under Development'),
        content: const Text('Coming Soon'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _dataJadwaKegiatan(token, userid) async {
    kegiatanController = KegiatanController();
    KegiatanModel? dataMeeting =
        await kegiatanController.getkegiatan(token, userid, 'new');
    if (mounted) {
      setState(() {
        _kegiatanModel = dataMeeting;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await authController.logout();
    GoRouter.of(context).go('/login');
  }

  Future<void> navigateToKegiatanPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  KegiatanPage(token: userToken, userid: userId),
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
    // if (result != null) {
    //   setState(() {
    //     // misal tampilkan nama supplier yang dipilih
    //     supplier_id = result["id"];
    //     supplier_nama = result["nama"];
    //     supplier_tipeppn = result["tipeppn"];
    //     supplier_syaratbayar = result["id_syaratbayar"];
    //   });
    // }
  }

  Future<void> navigateToMeetingPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  MeetingPage(token: userToken, userid: userId),
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

  Future<void> navigateToSubscribePage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SubscribePage(token: userToken, id: userId),
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

  String formatSubscribeDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'Tidak Aktif';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return 'Format Tanggal Tidak Valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String tahun = DateFormat("yyyy", "en_US").format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00302F), // hijau tua (base)
            Color(0xFF005F5B), // hijau emerald
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent, // penting biar gradient kelihatan
        extendBodyBehindAppBar: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: AppBar(
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0.0,
                title: Row(
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          color: const Color(0xFFF5F5F5),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(getInitials(userName.toUpperCase().toString()),
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 17, 19, 21),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25))
                          ],
                        )),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pelangganModel == null
                            ? const SizedBox(
                                width: 200,
                                child: ListMenuShimmer(
                                    total: 1, circular: 4, height: 16))
                            : Text(userName.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18)),
                        _pelangganModel == null
                            ? const SizedBox(
                                width: 200,
                                child: ListMenuShimmer(
                                    total: 1, circular: 4, height: 16))
                            : Text(
                                _pelangganModel!.data[0].kode_pelanggan
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                actions: [
                  // 🔹 kanan
                  IconButton(
                    icon: const Badge(
                      label: Text('2'),
                      child: FaIcon(FontAwesomeIcons.envelope,
                          color: Colors.amber),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _logout(context),
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage("assets/images/icon/logout.png"),
                              fit: BoxFit.fill)),
                    ),
                  ),
                  const SizedBox(width: 15)
                ]),
          ),
        ),
        // backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: RefreshIndicator(
            color: const Color.fromARGB(255, 254, 185, 3),
            onRefresh: () => _checkToken(),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(31, 234, 233, 233),
                              blurRadius: 1.0,
                              spreadRadius: 0,
                              offset: Offset(0, 2)),
                        ]),
                    // alignment: Alignment.bottomCenter,
                    // height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DOMPETKU',
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w700,
                                fontSize: 18)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20, bottom: 20),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: Color(0xFF00302F),
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/icon/bgsaldo.png"), // gambar dari assets
                                fit: BoxFit.fill, // cover = penuh layar
                              )),
                          // height: 60,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dompetku',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17)),
                              _pelangganModel == null
                                  ? const SizedBox(
                                      width: 200,
                                      child: ListMenuShimmer(
                                          total: 1, circular: 4, height: 16))
                                  : Text(userName.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 17)),
                              const SizedBox(height: 16),
                              // _pelangganModel == null
                              //     ? const ListMenuShimmer(
                              //         total: 1, circular: 4, height: 16)
                              //     : Text(
                              //         _pelangganModel!.data[0].va_dompetku
                              //                     .toString() ==
                              //                 'null'
                              //             ? 'xxxx-xxxx-xxxx'
                              //             : _pelangganModel!.data[0].va_dompetku
                              //                 .toString(),
                              //         style: const TextStyle(
                              //             color: Colors.white,
                              //             fontWeight: FontWeight.bold,
                              //             fontSize: 17)),
                              const SizedBox(height: 20),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: _pelangganModel == null
                                      ? const ListMenuShimmer(
                                          total: 1, circular: 4, height: 32)
                                      : Text(
                                          'Rp ${_pelangganModel!.data[0].saldo}',
                                          style: const TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 27))
                                  //     ? Container()
                                  // Container(
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(0xFFFFB902),
                                  //       border: Border.all(
                                  //           color:
                                  //               const Color(0xFFFFB902)),
                                  //       borderRadius:
                                  //           BorderRadius.circular(15),
                                  //     ),
                                  //     padding: const EdgeInsets.only(
                                  //         left: 16,
                                  //         right: 16,
                                  //         top: 8,
                                  //         bottom: 8),
                                  //     child: const Text('Daftar Sekarang',
                                  //         style: TextStyle(
                                  //             fontWeight:
                                  //                 FontWeight.bold)),
                                  //   )
                                  // :
                                  // ? ),
                                  )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => !buttonEnabled
                                      ? _showComingSoonDialog(context)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 10,
                                        right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    // alignment: Alignment.bottomCenter,
                                    height: 60,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/icon/withdraw.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(width: 5),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Penarikan Saldo',
                                                style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => !buttonEnabled
                                      ? _showComingSoonDialog(context)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 10,
                                        right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    // alignment: Alignment.bottomCenter,
                                    height: 60,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/icon/bill.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(width: 5),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Mutasi Saldo',
                                                style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 10),
                              // GestureDetector(
                              //   onTap: () => !buttonEnabled ? _showComingSoonDialog(context) : null,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.center,
                              //         children: [
                              //           ClipRRect(
                              //             borderRadius: const BorderRadius.only(
                              //               topLeft: Radius.elliptical(20, 20),
                              //               topRight: Radius.elliptical(20, 20),
                              //               bottomLeft: Radius.elliptical(20, 20),
                              //               bottomRight:
                              //                   Radius.elliptical(20, 20),
                              //             ),
                              //             child: Container(
                              //               padding: EdgeInsets.all(10),
                              //               color: Colors.grey[200],
                              //               child: Container(
                              //                 height: 35,
                              //                 width: 35,
                              //                 decoration: const BoxDecoration(
                              //                     image: DecorationImage(
                              //                         image: AssetImage(
                              //                             "assets/images/icon/topup.png"),
                              //                         fit: BoxFit.fill)),
                              //               ),
                              //             ),
                              //           ),
                              //           const SizedBox(height: 5),
                              //           const Text('Top Up',
                              //               style: TextStyle(
                              //                   fontSize: 14,
                              //                   color: Colors.black87))
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // const SizedBox(width: 5),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         ClipRRect(
                              //           borderRadius: const BorderRadius.only(
                              //             topLeft: Radius.elliptical(20, 20),
                              //             topRight: Radius.elliptical(20, 20),
                              //             bottomLeft: Radius.elliptical(20, 20),
                              //             bottomRight:
                              //                 Radius.elliptical(20, 20),
                              //           ),
                              //           child: Container(
                              //             padding: EdgeInsets.all(10),
                              //             color: Colors.grey[200],
                              //             child: Container(
                              //               height: 35,
                              //               width: 35,
                              //               decoration: const BoxDecoration(
                              //                   image: DecorationImage(
                              //                       image: AssetImage(
                              //                           "assets/images/icon/withdraw.png"),
                              //                       fit: BoxFit.fill)),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(height: 5),
                              //         const Text('Penarikan',
                              //             style: TextStyle(
                              //                 fontSize: 14,
                              //                 color: Colors.black87))
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(width: 5),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         ClipRRect(
                              //           borderRadius: const BorderRadius.only(
                              //             topLeft: Radius.elliptical(20, 20),
                              //             topRight: Radius.elliptical(20, 20),
                              //             bottomLeft: Radius.elliptical(20, 20),
                              //             bottomRight:
                              //                 Radius.elliptical(20, 20),
                              //           ),
                              //           child: Container(
                              //             padding: EdgeInsets.all(10),
                              //             color: Colors.grey[200],
                              //             child: Container(
                              //               height: 35,
                              //               width: 35,
                              //               decoration: const BoxDecoration(
                              //                   image: DecorationImage(
                              //                       image: AssetImage(
                              //                           "assets/images/icon/paper-plane.png"),
                              //                       fit: BoxFit.fill)),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(height: 5),
                              //         const Text('Transfer',
                              //             style: TextStyle(
                              //                 fontSize: 14,
                              //                 color: Colors.black87))
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(width: 5),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         ClipRRect(
                              //           borderRadius: const BorderRadius.only(
                              //             topLeft: Radius.elliptical(20, 20),
                              //             topRight: Radius.elliptical(20, 20),
                              //             bottomLeft: Radius.elliptical(20, 20),
                              //             bottomRight:
                              //                 Radius.elliptical(20, 20),
                              //           ),
                              //           child: Container(
                              //             padding: EdgeInsets.all(10),
                              //             color: Colors.grey[200],
                              //             child: Container(
                              //               height: 35,
                              //               width: 35,
                              //               decoration: const BoxDecoration(
                              //                   image: DecorationImage(
                              //                       image: AssetImage(
                              //                           "assets/images/icon/bill.png"),
                              //                       fit: BoxFit.fill)),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(height: 5),
                              //         const Text('Mutasi',
                              //             style: TextStyle(
                              //                 fontSize: 14,
                              //                 color: Colors.black87))
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(width: 5),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         ClipRRect(
                              //           borderRadius: const BorderRadius.only(
                              //             topLeft: Radius.elliptical(20, 20),
                              //             topRight: Radius.elliptical(20, 20),
                              //             bottomLeft: Radius.elliptical(20, 20),
                              //             bottomRight:
                              //                 Radius.elliptical(20, 20),
                              //           ),
                              //           child: Container(
                              //             padding: EdgeInsets.all(10),
                              //             color: Colors.amber,
                              //             child: Container(
                              //               height: 35,
                              //               width: 35,
                              //               child: const Center(
                              //                   child: FaIcon(
                              //                       FontAwesomeIcons.ellipsis,
                              //                       color: Color(0xFF005F5B),
                              //                       size: 35)),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(height: 5),
                              //         const Text('Lainnya',
                              //             style: TextStyle(
                              //                 fontSize: 14,
                              //                 color: Colors.black87))
                              //       ],
                              //     ),
                              //   ],
                              // ),
                            ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                      onTap: () => navigateToSubscribePage(),
                      child: SubscribeContainer(
                        endSubscribe: _pelangganModel?.data[0].end_subscribe,
                      )),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => navigateToKegiatanPage(),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, bottom: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                ),
                                // alignment: Alignment.bottomCenter,
                                height: 60,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/icon/appointment.png"),
                                              fit: BoxFit.fill)),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Kelola Kegiatan',
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: GestureDetector(
                              onTap: () => navigateToMeetingPage(),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, bottom: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                ),
                                height: 60,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/icon/meeting.png"),
                                              fit: BoxFit.fill)),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Kelola Meeting',
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                      ),
                      // alignment: Alignment.bottomCenter,
                      height: 300,
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: Colors.grey[800],
                              indicatorColor: Colors.amber,
                              unselectedLabelColor: Colors.grey[800],
                              tabs: const [
                                Tab(text: 'Jadwal Kegiatan'),
                                Tab(text: 'Jadwal Meeting'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  dataKegiatan(),
                                  dataMeeting(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
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

  Widget dataMeeting() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: _meetingModel == null
              ? const ListMenuShimmer(total: 4)
              : _meetingModel!.data.length == 0
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _meetingModel!.data.length,
                      itemBuilder: (context, index) {
                        return listMeeting(index, _meetingModel!.data[index]);
                      }),
        )),
        // const SizedBox(height: 20),
        // Text('Entries: ${_entryManager.entries.length}'),
      ],
    );
  }

  Widget listMeeting(int index, Meeting node) {
    var no = index + 1;
    Color? color = Colors.white;
    if (no % 2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MeetingDetailPage(
                      token: userToken,
                      userid: userId,
                      id: node.id,
                      usergroup: userGroup,
                    )));
      },
      child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(0.0)),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          margin: const EdgeInsets.only(bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.topik.toString(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDate(node.tgl_meeting.toString())}, ${node.jam_meeting.toString()}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              )
            ],
          )),
    );
  }

  Widget dataKegiatan() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: _kegiatanModel == null
              ? const ListMenuShimmer(total: 4)
              : _kegiatanModel!.data.length == 0
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _kegiatanModel!.data.length,
                      itemBuilder: (context, index) {
                        return listKegiatan(index, _kegiatanModel!.data[index]);
                      }),
        )),
        // const SizedBox(height: 20),
        // Text('Entries: ${_entryManager.entries.length}'),
      ],
    );
  }

  Widget listKegiatan(int index, Kegiatan node) {
    var no = index + 1;
    Color? color = Colors.white;
    if (no % 2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => KegiatanDetailPage(
                      token: userToken,
                      userid: userToken,
                      id: node.id,
                      usergroup: userGroup,
                    )));
      },
      child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(0.0)),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.namakegiatan.toString(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDate(node.tgl_kegiatan.toString())}, ${node.jam_kegiatan.toString()}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              )
            ],
          )),
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
        final width = constraint.maxWidth * 10;
        return ClipRect(
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SizedBox(
              width: width,
              height: width,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: width / 2 - preferredSize.height / 3),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 48, 47),
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(color: Colors.black54, blurRadius: 5.0)
                    // ],
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
  Size get preferredSize => const Size.fromHeight(240.0);
}

class SubscribeContainer extends StatefulWidget {
  final String? endSubscribe;

  const SubscribeContainer({super.key, this.endSubscribe});

  @override
  State<SubscribeContainer> createState() => _SubscribeContainerState();
}

class _SubscribeContainerState extends State<SubscribeContainer> {
  String formatSubscribeDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'Tidak Aktif';
    }
    final dt = parsePossibleDate(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
  }

  DateTime? parsePossibleDate(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    raw = raw.trim();
    // numeric timestamp (seconds or milliseconds)
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      final n = int.tryParse(raw);
      if (n == null) return null;
      return raw.length >= 13
          ? DateTime.fromMillisecondsSinceEpoch(n)
          : DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }
    // try ISO parse
    return DateTime.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentTime = DateTime.now();
    final DateTime endSubscribeDate =
        parsePossibleDate(widget.endSubscribe) ?? currentTime;
    final Duration remaining = endSubscribeDate.difference(currentTime);
    final bool expired = remaining.isNegative;
    final bool threeDaysRemaining = remaining.inDays <= 3 && !expired;
    final String formattedEndDate = formatSubscribeDate(widget.endSubscribe);
    return widget.endSubscribe == null
        ? Container(
            padding:
                const EdgeInsets.only(top: 10, left: 15, bottom: 10, right: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Colors.grey[800],
            ),
            height: 50,
            width: double.infinity,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: Color(0xFFFFFFFF),
                  size: 25,
                ),
                SizedBox(width: 10),
                Flexible(
                    child: ListMenuShimmer(total: 1, circular: 4, height: 14)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
              ],
            ),
          )
        : Container(
            padding:
                const EdgeInsets.only(top: 10, left: 15, bottom: 10, right: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: threeDaysRemaining
                  ? Colors.yellow[800]
                  : expired
                      ? Colors.red[800]
                      : Colors.grey[800],
            ),
            height: 50,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Color(0xFFFFFFFF),
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        threeDaysRemaining
                            ? 'Membership akan kadaluarsa pada $formattedEndDate'
                            : expired
                                ? 'Membership tidak aktif!'
                                : 'Membership aktif hingga $formattedEndDate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 12, color: Colors.white),
              ],
            ),
          );
  }
}
