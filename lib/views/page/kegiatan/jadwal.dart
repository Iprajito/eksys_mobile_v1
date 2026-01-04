import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/kegiatan_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/kegiatan_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/kegiatan/detail.dart';
import 'package:Eksys/views/page/kegiatan/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:intl/intl.dart';

class JadwalKegiatanPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const JadwalKegiatanPage({super.key, this.token, this.userid});

  @override
  State<JadwalKegiatanPage> createState() => _JadwalKegiatanPageState();
}

class _JadwalKegiatanPageState extends State<JadwalKegiatanPage> {
  late KegiatanController kegiatanController;
  KegiatanModel? _kegiatanModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
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
      // print('Valid Token');
      _dataUser();
      _dataJadwalKegiatan(widget.token, widget.userid);
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();
    // print(user?.user_group.toString());
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

  Future<void> toTambahKegiatanPage() async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation,
                  secondaryAnimation) => //DrawerExample(),
              TambahKegiatanPage(token: widget.token, userid: widget.userid),
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
        ));

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        kegiatanController = KegiatanController();
        _dataJadwalKegiatan(widget.token, widget.userid);
      });
    }
  }

  Future<void> toDetailKegiatanPage(
      String token, String userid, String id) async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  KegiatanDetailPage(
                      token: token, userid: userid, id: id, usergroup : userGroup),
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
        kegiatanController = KegiatanController();
        _dataJadwalKegiatan(widget.token, widget.userid);
      });
    }
  }

  void _dataJadwalKegiatan(token, userid) async {
    kegiatanController = KegiatanController();
    KegiatanModel? data = await kegiatanController.getkegiatan(token, userid, 'new');
    if (mounted) {
      setState(() {
        _kegiatanModel = data;
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
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _kegiatanModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _kegiatanModel!.data.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _kegiatanModel!.data.length,
                          itemBuilder: (context, index) {
                            var id = _kegiatanModel!.data[index].id.toString();
                            var creator =_kegiatanModel!.data[index].creator.toString();
                            var wilayah = _kegiatanModel!.data[index].wilayah.toString();
                            var tgl_kegiatan = _kegiatanModel!.data[index].tgl_kegiatan.toString();
                            var jam_kegiatan = _kegiatanModel!.data[index].jam_kegiatan.toString();
                            var namakegiatan = _kegiatanModel!.data[index].namakegiatan.toString();
                            var aktifitas = _kegiatanModel!.data[index].aktifitas.toString();
                            var lokasi = _kegiatanModel!.data[index].lokasi.toString();
                            var participant = _kegiatanModel!.data[index].participant.toString();
                            var status = _kegiatanModel!.data[index].status.toString();
                            return orderItem(id,creator,wilayah,tgl_kegiatan,jam_kegiatan,namakegiatan,aktifitas,lokasi,int.parse(participant),status);
                          }),
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 0, 48, 47),
            onPressed: toTambahKegiatanPage,
            child: const Icon(Icons.add_outlined, color: Colors.white)));
  }

  Widget orderItem(
      String id,
      String creator,
      String wilayah,
      String tgl_kegiatan,
      String jam_kegiatan,
      String namakegiatan,
      String aktifitas,
      String lokasi,
      int participant,
      String status) {
    double screenWidth = MediaQuery.of(context).size.width;

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return GestureDetector(
        child: Container(
            // width: screenWidth * 0.085,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    namakegiatan,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    aktifitas,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  BootstrapContainer(
                      fluid: true,
                      children: [
                        BootstrapRow(
                          // height: 30,
                          children: [
                            BootstrapCol(
                              fit: FlexFit.loose,
                              sizes: 'col-6',
                              child: _labelValue('Tanggal & Jam', "${formatDate(tgl_kegiatan)}, ${jam_kegiatan}"),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-6',
                              child: _labelValue('Lokasi', lokasi),
                            ),
                          ],
                        )
                      ]
                  ),
                  Divider(height: 16, color: Colors.grey[300]),
                  BootstrapContainer(
                      fluid: true,
                      children: [
                        BootstrapRow(
                          // height: 30,
                          children: [
                            BootstrapCol(
                              fit: FlexFit.loose,
                              sizes: 'col-6',
                              child: _labelValue('Dibuat Oleh', creator),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-6',
                              child: _labelValue('Partisipan', "${CurrencyFormat.convertNumber(participant, 0)} Anggota"),
                            ),
                          ],
                        )
                      ]
                  ),
                ],
              ),
            )),
        onTap: () {
          toDetailKegiatanPage(
              widget.token.toString(), widget.userid.toString(), id);
        });
  }
}

Widget _labelValue(String label, String value, {bool isBold = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal),
      ),
    ],
  );
}
