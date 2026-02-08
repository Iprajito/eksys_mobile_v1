import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:go_router/go_router.dart';

class AlamatPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const AlamatPage({super.key, this.token, this.userid});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final authController = AuthController(ApiServive(), StorageService());
  final storageService = StorageService();
  final userController = UserController(StorageService());

  // Ubah jadi masterController
  late MasterController masterController;
  PelangganModel? _pelangganModel;
  PelangganAlamatModel? _pelangganAlamatModel;

  String userId = "", userToken = "";

  bool isLoading = true;

  @override
  void initState() {
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
      // ini uncomment
      _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();

    setState(() {
      isLoading = true;
    });

    setState(() {
      userId = user!.uid.toString();
      userToken = user.token.toString();
      _dataPelanggan(userToken, userId);
      _dataPelangganAlamat(userToken, userId);
      isLoading = false;
    });
  }

  void _dataPelanggan(String token, String id) async {
    masterController = MasterController();
    PelangganModel? data = await masterController.getpelangganbyid(token, id);
    if (mounted) {
      setState(() {
        _pelangganModel = data;
      });
    }
  }

  void _dataPelangganAlamat(String token, String id) async {
    masterController = MasterController();
    PelangganAlamatModel? data = await masterController.getpelangganalamatbyuserid(token, id);
    if (mounted) {
      setState(() {
        _pelangganAlamatModel = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Text("Alamat Saya",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _pelangganAlamatModel == null
              ? const ListMenuShimmer(total: 5)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pelangganAlamatModel!.data.length,
                  itemBuilder: (context, index) {
                    final item = _pelangganAlamatModel!.data[index];
                    return listAlamat(
                      item.id.toString(),
                      item.nama_penerima.toString(),
                      item.telepon_penerima.toString(),
                      item.alamat_kirim1.toString(),
                      item.alamat_kirim2.toString(),
                      item.prim_address.toString(),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                      onPressed: () {}, //_saveProduks
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Tambah Alamat Baru',
                        style: TextStyle(
                            color: Colors.grey[800], fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ))
    );
  }

  Widget listAlamat(String id, String nama, String telepon, String alamat1, String alamat2, String prim_address) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.all(16),
        child: BootstrapContainer(
            fluid: true,
            children: [
              BootstrapRow(
                // height: 60,
                children: [
                  BootstrapCol(
                    sizes: 'col-12',
                    child: Row(
                      children: [
                        Text(nama.toUpperCase(), 
                        style: TextStyle( color: Colors.grey[800],fontWeight: FontWeight.w700,fontSize: 16)),
                        const SizedBox(width: 5),
                        Text(telepon,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              BootstrapRow(
                // height: 60,
                children: [
                  BootstrapCol(
                    sizes: 'col-12',
                    child: Text(alamat1,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                  ),
                ],
              ),
              BootstrapRow(
                // height: 60,
                children: [
                  BootstrapCol(
                    sizes: 'col-12',
                    child: Text(alamat2,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                  ),
                ],
              ),
              BootstrapRow(
                // height: 60,
                children: [
                  BootstrapCol(
                    sizes: 'col-2',
                    child: prim_address != 'Utama' ? const Text('') : Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all( color: Colors.orangeAccent.shade700, width: 1.0),
                      ),
                      child: Text('Utama', style: TextStyle(
                          color: Colors.orangeAccent.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ),
      ),
    );
  }
}

