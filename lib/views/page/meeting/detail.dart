import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/master_controller.dart';
import 'package:eahmindonesia/controllers/meeting_controller.dart';
import 'package:eahmindonesia/controllers/pesanan_controller.dart';
import 'package:eahmindonesia/controllers/purchaseorder_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/master_model.dart';
import 'package:eahmindonesia/models/meeting_model.dart';
import 'package:eahmindonesia/models/old/pesanan_model.dart';
import 'package:eahmindonesia/models/pembelian_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/views/page/meeting/chat.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:eahmindonesia/main.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FormMeetingDetailManager {
  final List<FormMeetingDetail> _entries = [];

  List<FormMeetingDetail> get entries => _entries;

  void addEntry(String userid,String meeting_id, String wilayah_id, String anggota_id) {
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

class MeetingDetailPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? id;
  final String? usergroup;
  
  const MeetingDetailPage({super.key, this.token, this.userid, this.id, this.usergroup});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();

  
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  final storageService = StorageService();
  final userController = UserController(StorageService());

  String userId = "", userName = "", userEmail = "", userToken = "", userGroup = "";
  bool isLoading = true;

  late MeetingController meetingController;
  MeetingModel? _meetingModel;
  MeetingDispatchModel? _meetingDispatchModel;

  TextEditingController notulensiController = TextEditingController();
  String notulensi = "";
  
  final _formKey = GlobalKey<FormState>();
  List<File> _files = [];
  List<String> fileList = [];
  bool _loading = false;
  
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
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
      _dataPembelian(widget.token.toString(), widget.userid.toString(), widget.id.toString());
      _dataPembelianDetail(widget.token.toString(), widget.id.toString());
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

  void _dataPembelian(String token, String userid, String idencrypt) async {
    meetingController = MeetingController();
    MeetingModel? data = await meetingController.getmeetingbyid(token, userid, idencrypt);
    if (mounted) {
      setState(() {
        _meetingModel = data;
        if (_meetingModel!.data[0].file_meeting.toString() != '') {
          fileList = List<String>.from(jsonDecode(_meetingModel!.data[0].file_meeting.toString()));
        }
        
      });
    }
  }

  void _dataPembelianDetail(String token, String idencrypt) async {
    MeetingDispatchModel? data = await meetingController.getmeetingdispatchbyid(token, idencrypt);
    if (mounted) {
      setState(() {
        _meetingDispatchModel = data;
      });
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // 👈 multiple file
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _files = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> downloadFile(BuildContext context, String url, String filename) async {
  try {
    // Tentukan lokasi penyimpanan
    Directory? dir;

    if (Platform.isAndroid) {
      dir = Directory("/storage/emulated/0/Download"); // folder Download Android
    } else {
      dir = await getApplicationDocumentsDirectory(); // iOS / lainnya
    }

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String savePath = "${dir.path}/$filename";

    Dio dio = Dio();
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );

    // ✅ Tampilkan notifikasi (SnackBar)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        // content: Text("Download selesai ✅\nLokasi: $savePath"),
        content: Text("Download selesai"),
        duration: Duration(seconds: 4),
      ),
    );

    print("File berhasil diunduh: $savePath");
  } catch (e) {
    print("Error download: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal download: $e")),
    );
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
                      usergroup: widget.usergroup, id: widget.id),
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
        // _dataTempMeeting(widget.token.toString(), widget.userid.toString());
      });
    }
  }

  Future<void> navigateToChatMeeting() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  ChatMeetingPage(
                      token: widget.token,
                      userid: widget.userid,
                      usergroup: widget.usergroup, id: widget.id),
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

  void _saveMeetingSelesai() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Validasi
      if (notulensi.isEmpty) {
        shoMyBadDialog(
          context: context,
          title: "Detail Meeting",
          message: "Notulensi tidak boleh kosong!",
        );
      } else {
        print("${widget.id}, ${notulensi}");
        showLoadingDialog(context: context);
        meetingController = MeetingController();
        var response = await meetingController.saveMeetingSelesai(
          widget.token.toString(),
          widget.id.toString(),
          notulensi,
          _files
        );

        if (response) {
          hideLoadingDialog(context);
          Navigator.pop(context, 'refresh');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Detail Meeting", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFf3f6f9),
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
                        height: 40,
                        children: [
                          BootstrapCol(
                            sizes: 'col-12',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Topik',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _meetingModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _meetingModel!.data[0].topik.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
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
                            sizes: 'col-md-6',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal & Jam',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  _meetingModel == null
                                  ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                  : Text(
                                    '${formatDate(_meetingModel!.data[0].tgl_meeting.toString())}, ${_meetingModel!.data[0].jam_meeting.toString()}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          BootstrapCol(
                            fit: FlexFit.tight,
                            sizes: 'col-md-6',
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Iuran',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  _meetingModel == null
                                  ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                  : Text(CurrencyFormat.convertToIdr((int.parse(_meetingModel!.data[0].nominal_iuran.toString())),0),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      BootstrapRow(
                        children: [
                          BootstrapCol(
                            fit: FlexFit.tight,
                            sizes: 'col-md-12',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lokasi',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _meetingModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _meetingModel!.data[0].lokasi.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        ]
                      ),
                      Divider(height: 16, color: Colors.grey[300]),
                      BootstrapRow(
                        height: 40,
                        children: [
                          BootstrapCol(
                            sizes: 'col-6',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dibuat Oleh',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                _meetingModel == null
                                ? const ListMenuShimmer(total: 1, circular: 4, height: 16)
                                : Text(
                                  _meetingModel!.data[0].creator.toString(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                Visibility(
                                  visible: (_meetingModel?.data[0].status.toString() == 'Selesai') ? false : true,
                                  child: GestureDetector(
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
                                    child: _meetingDispatchModel == null
                                  ? const ListMenuShimmer(total: 4, circular: 4, height: 42)
                                  : _meetingDispatchModel!.data.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada data'))
                                      : ListView.builder(
                                          physics: ScrollPhysics(parent: ClampingScrollPhysics()),
                                          itemCount: _meetingDispatchModel!.data.length,
                                          itemBuilder: (context, index) {
                                            var item = _meetingDispatchModel!.data[index];
                                            var id = item.id.toString();
                                            var anggota = item.anggota.toString();
                                            var nama_wilayah = item.nama_wilayah.toString();
                                            var totanggota = int.parse(item.totanggota.toString());
                                            var is_hadir = int.parse(item.is_hadir.toString());
                                            var is_creator = int.parse(item.is_creator.toString());
                                            return orderItemDetail(index, id, anggota, nama_wilayah, totanggota, is_hadir, is_creator);
                                          },
                                        ),
                                  )),
                                  Divider(height: 1, color: Colors.grey[200]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: _meetingModel == null ? const Text('Partisipan : 0 Anggota')
                                        : Text('Partisipan : ${CurrencyFormat.convertNumber((int.parse(_meetingModel!.data[0].participant.toString())),0)} Anggota'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: (_meetingModel?.data[0].is_hadir == '1'  && widget.userid == _meetingModel?.data[0].creator_userid) ? true : false,
                  child: Container(
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
                              child: Text("Notulensi Meeting",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                        BootstrapRow(
                          height: 95,
                          children: [
                            BootstrapCol(
                              sizes: 'col-12',
                              child: (_meetingModel?.data[0].status.toString() == 'Baru') ?
                              TextFormField(
                                maxLines: 3,
                                controller: notulensiController,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                    labelText: 'Notulensi',
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
                                  notulensi = value!;
                                },
                              ) : (_meetingModel == null) ? const Text('') : Text(_meetingModel!.data[0].notulensi.toString())
                            ),
                          ],
                        ),
                        Visibility(
                          visible: (_meetingModel?.data[0].status.toString() == 'Baru') ? true : false,
                          child: BootstrapRow(
                            height: 30,
                            children: [
                              BootstrapCol(
                                sizes: 'col-12',
                                child: ElevatedButton.icon(
                                  onPressed: _pickFiles,
                                  icon: const Icon(Icons.attach_file),
                                  label: const Text("Upload File"),
                                )
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: (_meetingModel?.data[0].status.toString() == 'Baru') ? true : false,
                          child: BootstrapCol(
                            fit: FlexFit.tight,
                            sizes: 'col-md-12',
                            child: SizedBox(
                              height: (_files.length != 0) ? screenHeight / 5 : 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      physics: ScrollPhysics(parent: ClampingScrollPhysics()),
                                      itemCount: _files.length,
                                      itemBuilder: (context, index) {
                                        return listAttach(index, _files[index].path.split('/').last);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: (_meetingModel?.data[0].status.toString() == 'Selesai') ? true : false,
                  child: Container(
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
                              child: Text("File Meeting",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ]
                        ),
                        BootstrapRow(
                          height: 30,
                          children: [
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-12',
                              child: SizedBox(
                                height: screenHeight / 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: fileList.length,
                                        itemBuilder: (context, index) {
                                          String fileName = fileList[index];
                                          // return ListTile(
                                          //   leading: const Icon(Icons.attach_file),
                                          //   title: Text(fileList[index]),
                                          //   onTap: () {
                                          //     downloadFile(url, fileName); // 👈 langsung download
                                          //   }
                                          // );
                                          return listAttach(index, fileName);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ]
                    )
                  )
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: (_meetingModel?.data[0].status.toString() == 'Baru') ? true : false,
        child: Container(
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
                          (_meetingModel?.data[0].is_hadir == '1' && widget.userid == _meetingModel?.data[0].creator_userid) ? 
                          Container(
                            width: (screenWidth) - 16,
                            child: ElevatedButton(
                              onPressed: _saveMeetingSelesai,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                backgroundColor:
                                    const Color.fromARGB(255, 254, 185, 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Simpan Notulensi & Meeting Selesai',
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 16),
                              ),
                            ),
                          ) : Container(
                            width: (screenWidth) - 16,
                            child: ElevatedButton(
                              onPressed: () {}, //_saveProduks,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                backgroundColor:
                                    const Color.fromARGB(255, 254, 185, 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Hadir',
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
      ),
      floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 0, 48, 47),
            onPressed: () => navigateToChatMeeting(),
            child: const FaIcon(FontAwesomeIcons.commentDots, color: Colors.white, size: 25)
      )
    );
  }

  Widget orderItem(String nopo, String tglpo, String supplier, String tipe_ppn, String syaratbayar, String keterangan) {
    
    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      final df = DateFormat('dd MMM yyyy', 'id_ID');
      return df.format(date);
    }
    
    return Container(
        // height: screenHeight * 0.085,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  buildBox("Nomor PO",nopo),
                  buildBox("Tanggal",formatDate(tglpo)),
                  buildBox("",""),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildBox("Supplier",supplier),
                  buildBox("Tipe Ppn",tipe_ppn),
                  buildBox("Syarat Bayar",syaratbayar),
                ]
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildBox("Keterangan",keterangan)
                ]
              ),
            ],
          ),
        )
      );
  }

  Widget orderItemDetail(int index, String id, String anggota, String nama_wilayah, int totanggota, int is_hadir, int is_creator) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    var no = index + 1;
    Color? color = Colors.white;
    if (no%2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    // bool? visibility = nopo.isEmpty ? false : true;
    String hadir = "";
    if (is_hadir == 0) {
      hadir = "";
    } else if (is_hadir == 1) {
      hadir = "Hadir";
    } else {
      hadir = "Tidak Hadir";
    }

    return Column(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(anggota,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                            (is_creator == 1) ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF019cff),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              padding: const EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
                              child: const Text('Creator',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white)),
                            ) 
                            : (is_hadir != 0) ? Container(
                              decoration: BoxDecoration(
                                color: (is_hadir == 1) ? const Color(0xFF31a350) : const Color(0xFFe24134),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              padding: const EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
                              child: Text(hadir,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                            ) : const Text('')
                          ],
                        ),
                        Text(nama_wilayah,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800])),
                      ],
                    ),
                  )
                ],
              ))
        // Divider(color: Colors.grey[200])
      ],
    );
  }

  Widget listAttach(int index, String filename) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    var no = index + 1;
    Color? color = Colors.white;
    if (no%2 == 0) {
      color = Colors.white;
    } else {
      color = Colors.grey[300];
    }

    String url = "https://erp.eahm-indonesia.co.id/treasure/uploads/mobile/meetings/$filename";
    
    return GestureDetector(
      onTap: () {
        downloadFile(context, url, filename);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          // borderRadius: BorderRadius.circular(0),
        ),
        width: screenWidth,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.attach_file, size: 20),
            const SizedBox(width: 10),
            Text(filename,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[800])),
          ],
        )),
    );
  }
}

class ProdukPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? usergroup;
  final String? id;
  const ProdukPage({super.key, this.token, this.userid, this.usergroup, this.id});

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

  void _addEntry(wilayah_id, meeting_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(wilayah_id) == false) {
        _entryManager.addEntry(widget.userid.toString(), meeting_id, wilayah_id, anggota_id);
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

  void _addEntryAnggota(wilayah_id, meeting_id, anggota_id) {
    setState(() {
      if (_entryManager.entryExists(anggota_id) == false) {
        _entryManager.addEntry(widget.userid.toString(), meeting_id, wilayah_id, anggota_id);
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
    print(inspect(_entryManager.entries));
    if (_entryManager.entries.length > 0) {
      showLoadingDialog(context: context);
      meetingController = MeetingController();
      for (var entry in _entryManager.entries) {
        await meetingController.saveMeetingDispatch(widget.token.toString(), widget.id.toString(), entry);
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
      _addEntry(node.id, widget.id, '');
    } else {
      _removeEntry(node.id, '');
    }
  }

  void _toggleAnggota(Anggota node, bool? value) {
    setState(() {
      checked2[node.id ?? ""] = value ?? false;
    });
    if (value == true) {
      _addEntryAnggota('', widget.id,node.id);
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

Widget buildBox(String label, String value, {double? width, bool isBold = false}) {
  return Expanded(
    flex: width == null ? 1 : 0,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

Widget _labelValue(String label, String value, {bool isBold = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500),
      ),
    ],
  );
}