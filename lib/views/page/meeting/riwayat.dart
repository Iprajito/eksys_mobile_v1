import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/meeting_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/models/meeting_model.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/meeting/detail.dart';
import 'package:Eksys/views/page/meeting/tambah.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/tambah.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:intl/intl.dart';

class RiwayatMeetingPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const RiwayatMeetingPage({super.key, this.token, this.userid});

  @override
  State<RiwayatMeetingPage> createState() => _RiwayatMeetingPageState();
}

class _RiwayatMeetingPageState extends State<RiwayatMeetingPage> {
  late MeetingController meetingController;
  MeetingModel? _meetingModel;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    meetingController = MeetingController();
    _checkToken();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
    _dataPesanan(widget.token, widget.userid);
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      // print('Valid Token');
      _dataUser();
      _dataPesanan(widget.token, widget.userid);
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

  Future<void> toTambahPesananPage() async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation,
                  secondaryAnimation) => //DrawerExample(),
              TambahMeetingPage(token: widget.token, userid: widget.userid),
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
        meetingController = MeetingController();
        _dataPesanan(widget.token, widget.userid);
      });
    }
  }

  Future<void> toDetailPesananPage(
      String token, String userid, String id) async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  MeetingDetailPage(
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
        meetingController = MeetingController();
        _dataPesanan(widget.token, widget.userid);
      });
    }
  }

  void _dataPesanan(token, userid) async {
    MeetingModel? dataMeeting = await meetingController.getmeeting(token, userid, 'history');
    if (mounted) {
      setState(() {
        _meetingModel = dataMeeting;
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
              child: _meetingModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _meetingModel!.data.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _meetingModel!.data.length,
                          itemBuilder: (context, index) {
                            var id = _meetingModel!.data[index].id.toString();
                            var creator =_meetingModel!.data[index].creator.toString();
                            var wilayah = _meetingModel!.data[index].wilayah.toString();
                            var tgl_meeting = _meetingModel!.data[index].tgl_meeting.toString();
                            var jam_meeting = _meetingModel!.data[index].jam_meeting.toString();
                            var topik = _meetingModel!.data[index].topik.toString();
                            var lokasi = _meetingModel!.data[index].lokasi.toString();
                            var participant = _meetingModel!.data[index].participant.toString();
                            var status = _meetingModel!.data[index].status.toString();
                            return orderItem(id,creator,wilayah,tgl_meeting,jam_meeting,topik,lokasi,int.parse(participant),status);
                          }),
            ))
          ],
        )
        // ,
        // floatingActionButton: FloatingActionButton(
        //     backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        //     onPressed: toTambahPesananPage,
        //     child: const Icon(Icons.add_outlined, color: Colors.white))
      );
  }

  Widget orderItem(
      String id,
      String creator,
      String wilayah,
      String tgl_meeting,
      String jam_meeting,
      String topik,
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
                    topik,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                              child: _labelValue('Tanggal & Jam', "${formatDate(tgl_meeting)}, ${jam_meeting}"),
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
                              sizes: 'col-4',
                              child: _labelValue('Dibuat Oleh', creator),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-4',
                              child: _labelValue('Partisipan', "${CurrencyFormat.convertNumber(participant, 0)} Anggota"),
                            ),
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-4',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    status,
                                    style: TextStyle(fontSize: 14, color: Colors.amber[900]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ]
                  ),
                ],
              ),
            )),
        onTap: () {
          toDetailPesananPage(
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
