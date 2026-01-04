import 'package:carousel_slider/carousel_slider.dart';
import 'package:Eksys/controllers/old/outlet_controller.dart';
import 'package:Eksys/controllers/old/reportpenjualan_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/old/outlet_model.dart';
import 'package:Eksys/models/old/reportpenjualan_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Eksys/controllers/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPusatPage extends StatefulWidget {
  const DashboardPusatPage({super.key});

  @override
  State<DashboardPusatPage> createState() => _DashboardPusatPageState();
}

class MyMonth {
  String name;
  String id;
  MyMonth(this.name, this.id);
}

class MyYear {
  String year;
  MyYear(this.year);
}

class _DashboardPusatPageState extends State<DashboardPusatPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final storageService = StorageService();
  final userController = UserController(StorageService());

  late ReportPenjualanController reportpenjualanController;
  ReportPenjualanModel? _reportpenjualanModel;

  late OutletController outletController;
  OutletModel? _outletModel;

  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      periode = "";
  bool isLoading = true;

  late int _selectedPieIndex;

  final years = [
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

  final months = [
    MyMonth('Januari', '01'),
    MyMonth('Februari', '02'),
    MyMonth('Maret', '03'),
    MyMonth('April', '04'),
    MyMonth('Mei', '05'),
    MyMonth('Juni', '06'),
    MyMonth('Juli', '07'),
    MyMonth('Agustus', '08'),
    MyMonth('September', '09'),
    MyMonth('Oktober', '10'),
    MyMonth('November', '11'),
    MyMonth('Desember', '12'),
  ];
  String? filteredTahun = DateFormat("yyyy", "en_US").format(DateTime.now());
  String? filteredBulan = DateFormat("MM", "en_US").format(DateTime.now());
  String? filteredBulanName = "";
  String? filteredOutledId = "";
  String? filteredOutledName = "Pusat";
  int _currentSliderIndex = 0;

  @override
  void initState() {
    _selectedPieIndex = -1;
    periode = DateFormat("yyyy-MM", "en_US").format(DateTime.now());
    super.initState();
    _checkToken();
    // _dataUser();
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
      _dataUser();
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
    setState(() {
      userId = user!.uid.toString();
      userName = user.name.toString();
      userEmail = user.email.toString();
      userToken = user.token.toString();
      _dataSummaryDashboard(userToken, '', periode);
      _dataOutlet();
      isLoading = false;
    });
  }

  Future<void> _dataOutlet() async {
    final user = await userController.getUserFromStorage();
    outletController = OutletController();
    final userToken = user!.token.toString();

    OutletModel? data = await outletController.getAllOutlets(userToken);
    if (mounted) {
      setState(() {
        _outletModel = data;
      });
    }
  }

  Future<void> _dataSummaryDashboard(userToken, outletId, periode) async {
    setState(() {
      _reportpenjualanModel = null;
    });

    reportpenjualanController = ReportPenjualanController();
    ReportPenjualanModel? data = await reportpenjualanController
        .getReportPenjualan(userToken, outletId, periode);
    if (mounted) {
      setState(() {
        _reportpenjualanModel = data;
      });
    }
  }

  List<Color> pieColors = [
    const Color.fromARGB(179, 217, 163, 0),
    const Color.fromARGB(153, 217, 163, 0),
    const Color.fromARGB(128, 217, 163, 0),
    const Color.fromARGB(102, 217, 163, 0),
    const Color.fromARGB(77, 217, 163, 0),
    const Color.fromARGB(51, 217, 163, 0),
    const Color.fromARGB(26, 217, 163, 0),
  ];

  @override
  Widget build(BuildContext context) {
    // print('Uid ${userId.toString()}');
    // print('Name ${userName.toString()}');
    // print('Email ${userEmail.toString()}');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String tahun = DateFormat("yyyy", "en_US").format(DateTime.now());
    final bulan = months.firstWhere((month) =>
        month.id == DateFormat("MM", "en_US").format(DateTime.now()));
    final bulanName = months.firstWhere((month) => month.id == filteredBulan);

    setState(() {
      filteredBulanName = bulanName.name;
    });

    
    final List<String> imgList = [
      "https://erp.eahm-indonesia.co.id/treasure/img/slider/slider-apps-1.png",
      "https://erp.eahm-indonesia.co.id/treasure/img/slider/slider-apps-2.png",
      "https://erp.eahm-indonesia.co.id/treasure/img/slider/slider-apps-3.png",
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        title: Row(
          children: [
            Container(
              height: 30,
              width: 100,
              decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: AssetImage("assets/images/logo-mob-apps.png"),
                      fit: BoxFit.fill)),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
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
                top: 0,
                left: 16,
                right: 16,
                // bottom: 5,
                child: Row(
                  children: [
                    SizedBox(
                      height: 140,
                      width: (MediaQuery.of(context).size.width / 2) - 17,
                      child: const Card(
                        color: Colors.white,
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldoku', style: TextStyle( color: Color(0xFF757575),fontSize: 14, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text(
                                'Rp 11.410.000',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('Penjualan', style: TextStyle( color: Color(0xFF757575),fontSize: 12, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 4),
                                      Text(
                                        '275',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text('(Karton)', style: TextStyle( color: Color(0xFF757575),fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Pembelian', style: TextStyle( color: Color(0xFF757575),fontSize: 12, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 4),
                                      Text(
                                        '1200',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text('(Karton)', style: TextStyle( color: Color(0xFF757575),fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 70,
                          width: (MediaQuery.of(context).size.width / 2) - 17,
                          child: const Card(
                            color: Colors.white,
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Penjualan', style: TextStyle( color: Color(0xFF757575),fontSize: 14, fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp 11.410.000',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 70,
                          width: (MediaQuery.of(context).size.width / 2) - 17,
                          child: const Card(
                            color: Colors.white,
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pembelian', style: TextStyle( color: Color(0xFF757575),fontSize: 14, fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp 11.410.000',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ),
              Positioned(
                  // top: 20,
                  left: 20,
                  right: 20,
                  bottom: 5,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(31, 234, 233, 233),
                              blurRadius: 1.0,
                              spreadRadius: 0,
                              offset: Offset(0, 2)),
                        ]
                      ),
                    // alignment: Alignment.bottomCenter,
                    height: 91,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              // padding: const EdgeInsets.all(10),
                              // decoration: BoxDecoration(
                              //   color: const Color(0xFFFFB902),
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/1icoEvent.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Kelola Event',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/2icoMeeting.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Kelola Meeting',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/3icoSaldo.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Kelola Saldo',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/4icoLaporan.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Laporan Transaksi',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.none,
              showCursor: false,
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Padding(
                    padding: EdgeInsets.all(15),
                    child: FaIcon(FontAwesomeIcons.sliders,
                        color: Color(0xFFFFFFFF), size: 20)),
                hintText:
                    'Membership Aktif hingga 30 September 2025',
                hintStyle: const TextStyle(color: Colors.white, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Kene
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CarouselSlider.builder(
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imgList[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            color: Colors.grey,
                            width: double.infinity,
                            height: 100,
                          ),
                        );
                      },
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 100,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlay: false, // tidak auto play
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentSliderIndex = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 5),
              // 🔵 indikator bulat
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() => _currentSliderIndex = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentSliderIndex == entry.key ? 5.0 : 5.0,
                      height: _currentSliderIndex == entry.key ? 5.0 : 5.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentSliderIndex == entry.key
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color.fromARGB(255, 254, 185, 3),
              onRefresh: () => _checkToken(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              // boxShadow: const [
                              //   BoxShadow(
                              //       color: Colors.black12,
                              //       blurRadius: 5.0,
                              //       spreadRadius: 0,
                              //       offset: Offset(0, 3)),
                              // ]
                            ),
                            // alignment: Alignment.bottomCenter,
                            height: 60,
                            width: double.infinity,
                            child: _reportpenjualanModel == null
                                ? const SummaryShimmer()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                      Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/5icoBonusJual.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                      const SizedBox(width: 5),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Bonus Penjualan',
                                              style: TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 14)),
                                          Text(
                                              CurrencyFormat.convertToIdr(
                                                  int.parse(
                                                      _reportpenjualanModel!
                                                          .summary[0].totaltunai
                                                          .toString()),
                                                  0),
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              // boxShadow: const [
                              //   BoxShadow(
                              //       color: Colors.black12,
                              //       blurRadius: 5.0,
                              //       spreadRadius: 0,
                              //       offset: Offset(0, 3)),
                              // ]
                            ),
                            // alignment: Alignment.bottomCenter,
                            height: 60,
                            width: double.infinity,
                            child: _reportpenjualanModel == null
                                ? const SummaryShimmer()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                      Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/6icoBonusBeli.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                      const SizedBox(width: 5),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Bonus Pembelian',
                                              style: TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 14)),
                                          Text(
                                              CurrencyFormat.convertToIdr(
                                                  int.parse(
                                                      _reportpenjualanModel!
                                                          .summary[0].totalqris
                                                          .toString()),
                                                  0),
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              // boxShadow: const [
                              //   BoxShadow(
                              //       color: Colors.black12,
                              //       blurRadius: 5.0,
                              //       spreadRadius: 0,
                              //       offset: Offset(0, 3)),
                              // ]
                            ),
                            // alignment: Alignment.bottomCenter,
                            height: 60,
                            width: double.infinity,
                            child: _reportpenjualanModel == null
                                ? const SummaryShimmer()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Icon(Icons.account_balance_wallet,color: Color(0xFFFFB902), size: 40),
                                      Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/7icoSisaPelunasan.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                      const SizedBox(width: 5),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Sisa Hutang',
                                              style: TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 14)),
                                          Text(
                                              CurrencyFormat.convertToIdr(
                                                  int.parse(
                                                      _reportpenjualanModel!
                                                          .summary[0]
                                                          .totalonline
                                                          .toString()),
                                                  0),
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              // boxShadow: const [
                              //   BoxShadow(
                              //       color: Colors.black12,
                              //       blurRadius: 2.0,
                              //       spreadRadius: 0,
                              //       offset: Offset(0, 1)),
                              // ]
                            ),
                            // alignment: Alignment.bottomCenter,
                            height: 60,
                            width: double.infinity,
                            child: _reportpenjualanModel == null
                                ? const SummaryShimmer()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // const SummaryShimmer()
                                      Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  image: AssetImage("assets/images/icons/8icoSisaStok.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                      const SizedBox(width: 5),
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Stock (Karton)',
                                              style: TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 14)),
                                          Text(
                                              CurrencyFormat.convertToIdr(
                                                  int.parse(
                                                      _reportpenjualanModel!
                                                          .summary[0].totaljual
                                                          .toString()),
                                                  0),
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Volume Penjualan Unit / Tanggal",
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17)),
                                  FaIcon(FontAwesomeIcons.bars,
                                      color: Colors.grey[800], size: 17),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.black12, height: 0),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SfCartesianChart(
                                primaryXAxis: const CategoryAxis(
                                  autoScrollingDelta:
                                      7, // Show only 10 points at a time
                                  autoScrollingMode: AutoScrollingMode.end,
                                ),
                                primaryYAxis: NumericAxis(
                                  numberFormat: NumberFormat.compact(),
                                ),
                                zoomPanBehavior: ZoomPanBehavior(
                                  enablePanning: true,
                                  zoomMode: ZoomMode.x,
                                  // enableMouseWheelZooming: true
                                ),
                                // title: ChartTitle(text: 'Sales Analysis'),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  builder: (dynamic dataPoint,
                                      dynamic point,
                                      dynamic series,
                                      int pointIndex,
                                      int seriesIndex) {
                                    final xValue = dataPoint.date;
                                    final yValue = dataPoint.unit;
                                    final yFormatted = NumberFormat.compact()
                                        .format(int.parse(dataPoint.unit));
                                    return Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            xValue, // dynamic header
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Unit : $yFormatted',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                series: <CartesianSeries>[
                                  LineSeries<PenjualanUnit, String>(
                                    dataSource: _reportpenjualanModel == null
                                        ? []
                                        : _reportpenjualanModel!.penjualanunit,
                                    xValueMapper: (PenjualanUnit data, _) =>
                                        data.date,
                                    yValueMapper: (PenjualanUnit data, _) =>
                                        int.parse(data.unit.toString()),
                                    name: 'Unit',
                                    width: 1,
                                    dataLabelSettings: const DataLabelSettings(
                                        isVisible: false),
                                    // pointColorMapper: (SalesData sales, _) => Colors.grey[350],
                                    markerSettings: const MarkerSettings(
                                        isVisible: true, color: Colors.amber),
                                    color: Colors.grey[350],
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                              child: Text("Volume Penjualan Rupiah / Tanggal",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17)),
                            ),
                            const Divider(color: Colors.black12, height: 0),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  autoScrollingDelta:
                                      7, // Show only 10 points at a time
                                  autoScrollingMode: AutoScrollingMode.end,
                                ),
                                primaryYAxis: NumericAxis(
                                  numberFormat: NumberFormat.compact(),
                                ),
                                zoomPanBehavior: ZoomPanBehavior(
                                  enablePanning: true,
                                  zoomMode: ZoomMode.x,
                                  // enableMouseWheelZooming: true
                                ),
                                // title: ChartTitle(text: 'Sales Analysis'),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  builder: (dynamic dataPoint,
                                      dynamic point,
                                      dynamic series,
                                      int pointIndex,
                                      int seriesIndex) {
                                    final xValue = dataPoint.date;
                                    final yValue = dataPoint.unit;
                                    final yFormatted = NumberFormat.compact()
                                        .format(int.parse(dataPoint.unit));
                                    return Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            xValue, // dynamic header
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Rp : $yFormatted',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                series: <CartesianSeries>[
                                  LineSeries<PenjualanRupiah, String>(
                                    dataSource: _reportpenjualanModel == null
                                        ? []
                                        : _reportpenjualanModel!
                                            .penjualanrupiah,
                                    xValueMapper: (PenjualanRupiah data, _) =>
                                        data.date,
                                    yValueMapper: (PenjualanRupiah data, _) =>
                                        int.parse(data.unit.toString()),
                                    name: 'Rupiah',
                                    width: 1,
                                    dataLabelSettings: const DataLabelSettings(
                                        isVisible: false),
                                    // pointColorMapper: (SalesData sales, _) => Colors.grey[350],
                                    markerSettings: const MarkerSettings(
                                        isVisible: true, color: Colors.amber),
                                    color: Colors.grey[350],
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: screenHeight / 2,
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
                              child: Text("Produk Terlaris",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17)),
                            ),
                            const Divider(color: Colors.black12, height: 0),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SfCircularChart(
                                      enableMultiSelection: false,
                                      margin: EdgeInsets.zero,
                                      // title: const ChartTitle(text: 'Monthly Sales'),
                                      legend: const Legend(
                                        isVisible: true,
                                        itemPadding: 8,
                                        position: LegendPosition.bottom,
                                        orientation:
                                            LegendItemOrientation.vertical,
                                        // toggleSeriesVisibility: false,
                                        overflowMode: LegendItemOverflowMode
                                            .wrap, // 👈 can be .top, .bottom, .left, .right
                                      ),
                                      onLegendTapped: (LegendTapArgs args) {
                                        setState(() {
                                          _selectedPieIndex = args.pointIndex!;
                                        });
                                      },
                                      tooltipBehavior:
                                          TooltipBehavior(enable: true),
                                      series: <PieSeries<ProdukTerlaris,
                                          String>>[
                                        PieSeries<ProdukTerlaris, String>(
                                            dataSource:
                                                _reportpenjualanModel == null
                                                    ? []
                                                    : _reportpenjualanModel!
                                                        .produkterlaris,
                                            xValueMapper:
                                                (ProdukTerlaris data, _) =>
                                                    data.menu,
                                            yValueMapper: (ProdukTerlaris data,
                                                    _) =>
                                                int.parse(data.qty.toString()),
                                            dataLabelSettings:
                                                const DataLabelSettings(
                                                    isVisible: true),
                                            // pointColorMapper: (_ChartData data, _) => data.color,
                                            pointColorMapper: (datum, index) =>
                                                pieColors[
                                                    index % pieColors.length],
                                            explode: true,
                                            explodeIndex: _selectedPieIndex
                                            // explodeAll: true,
                                            // startAngle: 270,
                                            // endAngle: 180,
                                            )
                                      ],
                                    )))
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