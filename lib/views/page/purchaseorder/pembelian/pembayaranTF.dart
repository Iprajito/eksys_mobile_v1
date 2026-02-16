import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/purchaseorder_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/main.dart';
import 'package:Eksys/models/pembelian_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:pocketbase/pocketbase.dart';

class PembelianPembayaranTFPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  
  const PembelianPembayaranTFPage({super.key, this.token, this.userid, this.idencrypt});

  @override
  State<PembelianPembayaranTFPage> createState() => _PembelianPembayaranTFPageState();
}

class _PembelianPembayaranTFPageState extends State<PembelianPembayaranTFPage> {
  late DateTime targetDateTime;
  Duration remaining = Duration.zero;
  Timer? timer;
  bool isFinished = false;

  final storageService = StorageService();
  final userController = UserController(StorageService());
  late PurchaseorderController purchaseorderController;
  PembelianModel? _pembelianModel;
  
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  bool isLoading = true;

  String? _imageUrl = null;
  final ImagePicker _picker = ImagePicker();
  
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  String formatInGroupsOf4(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[i]);
      // tambahkan spasi tiap 4 digit, kecuali kalau sudah di akhir string
      if ((i + 1) % 4 == 0 && i + 1 != input.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        remaining = targetDateTime.difference(now);
        if (remaining.isNegative || remaining.inSeconds == 0) {
          remaining = Duration.zero;
          isFinished = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours jam $minutes menit $seconds detik";
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
        purchaseorderController = PurchaseorderController();
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        _dataPembelian(userToken, userId, widget.idencrypt.toString());
      });
    }
  }

  void _dataPembelian(String token, String userid, String idencrypt) async {
    PembelianModel? data =
        await purchaseorderController.getpembelianbyid(token, userid, idencrypt);
    if (mounted) {
      setState(() {
        _pembelianModel = data;
        _imageUrl = _pembelianModel!.data[0].bukti_transfer.toString() != "" ? _pembelianModel!.data[0].bukti_transfer.toString() : null;
      });
    }
  }

  void showLunasDialog({
    required BuildContext context,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_sharp, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Pembayaran"),
            ],
          ),
          content: const Text(
            // "Selamat pembayaran anda telah berhasil!",
            "Bukti pembayaran berhasil dikirim dan sedang menunggu konfirmasi admin.\n\nProses verifikasi kurang dari 2x24 jam setelah pembayaran berhasil.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context); // Close the dialog
            //   },
            //   child: Text("Cancel"),
            // ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, 'refresh');
                Navigator.pop(context, 'refresh');
              },
              child: Text("OK", style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _pickImage() async {
    purchaseorderController = PurchaseorderController();
    showLoadingDialog(context: context);
    purchaseorderController = PurchaseorderController();

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileName = path.basename(File(pickedFile.path).path);
      FormData formData = FormData.fromMap({
        "userid": widget.userid.toString(),
        "idencrypt": widget.idencrypt.toString(),
        "image": await MultipartFile.fromFile(
          File(pickedFile.path).path,
          filename: fileName,
        ),
      });
  // print(inspect(formData));
      var response = await purchaseorderController.uploadImage(
          widget.token.toString(), formData);
      if (response != 'error') {
        hideLoadingDialog(context);
        setState(() {
          _imageUrl = response;
          print(_imageUrl);
        });
        showLunasDialog(context: context);
        // Navigator.pop(context, 'refresh');
      } else {
        hideLoadingDialog(context);
        print('Proses Gagal!');
      }
    } else {
      print('No image selected.');
    }
  }

  void _delImageUpload() async {
    purchaseorderController = PurchaseorderController();
    showLoadingDialog(context: context);
    purchaseorderController = PurchaseorderController();
    var response = await purchaseorderController.deleteImageUpload(
        widget.token.toString(), widget.idencrypt.toString());
    if (response) {
      hideLoadingDialog(context);
      setState(() {
        _imageUrl = null;
      });
    } else {
      hideLoadingDialog(context);
      print('Proses Gagal!');
    }
  }
  // void _dataPembayaran(token, userid) async {
  //   purchaseorderController = PurchaseorderController();
  //   PembelianVAModel? dataPelanggan = await purchaseorderController.getvabypembelianid(token, userid, widget.idencrypt.toString());
  //   if (mounted) {
  //     setState(() {
  //       _pembelianVAModel = dataPelanggan;
  //       targetDateTime = DateTime.parse(_pembelianVAModel!.data[0].expired_date.toString());
  //       print('isLoading ${isLoading}');
  //       fetchAllRecords(_pembelianVAModel!.data[0].trx_id.toString());
  //       subscribeToCollectionChanges();
  //       _startCountdown();
  //       // isLoading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    timer?.cancel();
    // pb.collection('trx_pembelian_va').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
        title: const Text("Pembayaran", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFf3f6f9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    // height: 120,
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        // isLoading ? Text('data') : Text('${records[0]['status']}'),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nomor PO',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text('${_pembelianModel?.data[0].nopo.toString()}',
                                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Pembayaran',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormat.convertToIdr((int.parse(_pembelianModel!.data[0].grandtotal.toString())),0),
                                      style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Divider(height: 16,color: Colors.grey[300]),
                        // Container(
                        //   padding: const EdgeInsets.only(top: 8, bottom: 8),
                        //   child: Row(
                        //     children: <Widget>[
                        //       Expanded(
                        //         child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             const Text(
                        //               'Bayar Dalam',
                        //               style: TextStyle(
                        //                 fontSize: 15,
                        //                 color: Colors.black,
                        //               ),
                        //             ),
                        //             Text(
                        //               isFinished ? "Waktu Habis" : _formatDuration(remaining),
                        //               style: TextStyle(fontSize: 15, color: Colors.amber[900]),
                        //             )
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ]
                    )
                  )
              ),
              const SizedBox(height: 16),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    // height: 120,
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) 
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nama Bank',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _pembelianModel!.data[0].nama_bank.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) 
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nama Penerima',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _pembelianModel!.data[0].norek_nama.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No. Rekening',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _pembelianModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatInGroupsOf4(_pembelianModel!.data[0].norekening.toString()),
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.amber[900]!,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            copyToClipboard(_pembelianModel!.data[0].norekening.toString());
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                            size: 20,
                                            color: Color.fromARGB(255, 22, 142, 197),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    )
                  )
              ),
              const SizedBox(height: 16),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    // height: 120,
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Upload Bukti Transfer',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _imageUrl == null
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (screenWidth * 0.41),
                                            // height: 30,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: const Color(0xFFfcf5e1),
                                                  padding: const EdgeInsets.all(10),
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  side: const BorderSide(
                                                    width: 1.0,
                                                    color: Color(0xFFFFB902),
                                                  )),
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TakePictureScreen(
                                                        token: widget.token.toString(),
                                                        userid: widget.userid.toString(),
                                                        idencrypt: widget.idencrypt.toString(),
                                                        camera: cameras.first),
                                                  ),
                                                );
                                                if (result != null) {
                                                  setState(() {
                                                    _imageUrl = result;
                                                  });
                                                  showLunasDialog(context: context);
                                                  print(_imageUrl);
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera_alt,
                                                      color: Colors.grey[800], size: 25),
                                                  const SizedBox(width: 8),
                                                  Text('Kamera',
                                                      style: TextStyle(
                                                          color: Colors.grey[800],
                                                          fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (screenWidth * 0.41),
                                            // height: 30,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: const Color(0xFFfcf5e1),
                                                  padding: const EdgeInsets.all(10),
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  side: const BorderSide(
                                                    width: 1.0,
                                                    color: Color(0xFFFFB902),
                                                  )),
                                              onPressed: _pickImage,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image,
                                                      color: Colors.grey[800], size: 25),
                                                  const SizedBox(width: 8),
                                                  Text('Galeri',
                                                      style: TextStyle(
                                                          color: Colors.grey[800],
                                                          fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                      children: [
                                        SizedBox(
                                          width: (screenWidth * 0.72) - 11,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: const Color(0xFFc3e6cb),
                                              padding: const EdgeInsets.all(10),
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(15),
                                                    bottomLeft: Radius.circular(15)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DisplayImageUrl(
                                                      idencrypt: _pembelianModel!.data[0].nopo.toString(),
                                                      imageUrl: _imageUrl),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image,
                                                    color: Colors.grey[800], size: 25),
                                                const SizedBox(width: 8),
                                                Text('Image uploaded',
                                                    style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (screenWidth * 0.15),
                                          // height: 30,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Color(0xFFea4336),
                                              padding: const EdgeInsets.all(10),
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(15),
                                                    bottomRight: Radius.circular(15)),
                                              ),
                                            ),
                                            onPressed: _delImageUpload,
                                            child: Icon(Icons.delete,
                                                color: Colors.grey[800], size: 25),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 16,color: Colors.grey[300]),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child:  const Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Proses verifikasi kurang 2x24 jam setelah pembayaran berhasil',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 22, 142, 197),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Penting: Pastikan kamu mentransfer ke Nama dan Rekening yang tertera di atas.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Penting: Pastikan bukti transfer kamu sudah benar dan sesuai dengan data yang tertera.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    )
                  )
              ),
            ]
          ),
        ),
      ),
      // bottomNavigationBar : Container(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      //   decoration: BoxDecoration(
      //     boxShadow: <BoxShadow>[
      //       BoxShadow(
      //           color: Colors.grey[300]!,
      //           blurRadius: 1.0,
      //           spreadRadius: 2 //, offset: Offset(0, -3)
      //           )
      //     ],
      //   ),
      //   child: Container(
      //     height: 65,// 65,
      //     // width: (screenWidth/2),
      //     // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
      //     padding: const EdgeInsets.all(8),
      //     decoration: const BoxDecoration(
      //       // border: Border.all(color: Colors.white),
      //       color: Colors.white,
      //       // borderRadius: BorderRadius.all(Radius.circular(10.0)),
      //     ),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         SizedBox(
      //           width: (screenWidth) - 10,
      //           child: ElevatedButton(
      //             onPressed: () {
      //               Navigator.pop(context, 'refresh');
      //             },
      //             style: ElevatedButton.styleFrom(
      //               padding: const EdgeInsets.all(8),
      //               backgroundColor:
      //                   const Color.fromARGB(255, 254, 185, 3),
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10),
      //               ),
      //             ),
      //             child: Text(
      //               'OK',
      //               style: TextStyle(
      //                   color: Colors.grey[800], fontSize: 16),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   )
      // )
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  const TakePictureScreen(
      {super.key, this.token, this.userid, this.idencrypt, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  FlashMode _flashMode = FlashMode.off;

  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture = _controller.initialize().then((_) async {
      await _controller.setFlashMode(_flashMode); // <-- WAJIB
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    setState(() {
      _flashMode = newMode;
    });

    await _controller.setFlashMode(newMode);
  }

  void _handleFocus(TapDownDetails details, BuildContext context) async {
    if (!_controller.value.isInitialized) return;

    final size = MediaQuery.of(context).size;
    final offset = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    await _controller.setFocusPoint(offset);
    await _controller.setExposurePoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: _toggleFlash,
            child: Icon(
              _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              // size: 30,
            ),
          ),
          const SizedBox(width: 10)
        ],
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      backgroundColor: const Color(0xFF000000),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Center(
              child: GestureDetector(
                  onTapDown: (details) => _handleFocus(details, context),
                  onScaleStart: (details) {
                    _baseZoom = _currentZoom;
                  },
                  onScaleUpdate: (details) async {
                    double newZoom = (_baseZoom * details.scale).clamp(1.0, 2);
                    setState(() {
                      _currentZoom = newZoom;
                    });
                    await _controller.setZoomLevel(newZoom);
                  },
                  // child: CameraPreview(_controller),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: CameraPreview(_controller),
                  )),
            );
            // return Stack(
            //   children: [
            //     Center(
            //       child: GestureDetector(
            //           onTapDown: (details) => _handleFocus(details, context),
            //           onScaleStart: (details) {
            //             _baseZoom = _currentZoom;
            //           },
            //           onScaleUpdate: (details) async {
            //             double newZoom = (_baseZoom * details.scale).clamp(1.0, _controller.value.aspectRatio);
            //             setState(() {
            //               _currentZoom = newZoom;
            //             });
            //             await _controller.setZoomLevel(newZoom);
            //           },
            //           // child: CameraPreview(_controller),
            //           child: AspectRatio(
            //             aspectRatio: 9/16,
            //             child: CameraPreview(_controller),
            //           )
            //         ),
            //     ),
            //     Positioned(
            //       top: 40,
            //       left: 20,
            //       child: IconButton(
            //         icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            //         onPressed: () {
            //           Navigator.pop(context);
            //         },
            //       ),
            //     ),
            //     Positioned(
            //       top: 40,
            //       right: 30,
            //       child: IconButton(
            // icon: Icon(
            //   _flashMode == FlashMode.torch
            //       ? Icons.flash_on
            //       : Icons.flash_off,
            //   color: Colors.white,
            //   // size: 30,
            // ),
            //         onPressed: _toggleFlash,
            //       ),
            //     ),
            //   ],
            // );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: Colors.white,
          // elevation: 0,
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and get the file `image`
              // where it was saved.
              final image = await _controller.takePicture();

              if (!context.mounted) return;

              // If the picture was taken, display it on a new screen.

              // setState(() {
              //   _image = File(image.path);
              // });

              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    token: widget.token.toString(),
                    userid: widget.userid.toString(),
                    idencrypt: widget.idencrypt.toString(),
                    imagePath: image.path,
                  ),
                ),
              );
              // print(result);
              if (result != 'camera') {
                Navigator.pop(context, result);
              }
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          child: const Icon(
            Icons.camera_alt,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? idencrypt;
  final String? imagePath;
  const DisplayPictureScreen(
      {super.key, this.token, this.userid, this.idencrypt, this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreen();
}

// A widget that displays the picture taken by the user.
class _DisplayPictureScreen extends State<DisplayPictureScreen> {
  late PurchaseorderController purchaseorderController;

  void _uploadImage() async {
    purchaseorderController = PurchaseorderController();
    showLoadingDialog(context: context);
    purchaseorderController = PurchaseorderController();

    String fileName = path.basename(File(widget.imagePath.toString()).path);
    FormData formData = FormData.fromMap({
      "userid": widget.userid.toString(),
      "idencrypt": widget.idencrypt.toString(),
      "image": await MultipartFile.fromFile(
        File(widget.imagePath.toString()).path,
        filename: fileName,
      ),
    });

    var response =
        await purchaseorderController.uploadImage(widget.token.toString(), formData);
    if (response != 'error') {
      hideLoadingDialog(context);
      Navigator.pop(context, response);
      // Navigator.pop(context, 'refresh');
    } else {
      hideLoadingDialog(context);
      print('Proses Gagal!');
    }

    // Navigator.pop(context, File(widget.imagePath.toString()));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Display the Picture')
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AspectRatio(
              aspectRatio: 9 / 16,
              child: Center(
                child: Image.file(
                  File(widget.imagePath.toString()),
                  fit: BoxFit.fill, // or BoxFit.cover for edge-to-edge
                  width: double.infinity,
                  height: double.infinity,
                ),
              )),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: screenWidth,
              color: const Color.fromARGB(61, 0, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context, 'camera');
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon:
                          const Icon(Icons.save, color: Colors.white, size: 30),
                      onPressed: () {
                        _uploadImage();
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DisplayImageUrl extends StatefulWidget {
  final String? idencrypt;
  final String? imageUrl;
  const DisplayImageUrl({super.key, this.idencrypt, this.imageUrl});

  @override
  State<DisplayImageUrl> createState() => _DisplayImageUrl();
}

class _DisplayImageUrl extends State<DisplayImageUrl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.idencrypt}',style: const TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        )
      ),
      backgroundColor: Colors.transparent,
      body: AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(
          child: InteractiveViewer(
            panEnabled: true, // Set it to false if you only want to zoom
            boundaryMargin: const EdgeInsets.all(0),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              fit: BoxFit.fill, // or BoxFit.cover for edge-to-edge
              width: double.infinity,
              height: double.infinity,
              widget.imageUrl.toString(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Failed to load image');
              },
            ),
          ),
        ),
      ),
    );
  }
}