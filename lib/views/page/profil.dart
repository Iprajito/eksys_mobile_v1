import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/master_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/master_model.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final authController = AuthController(ApiServive(), StorageService());
  final storageService = StorageService();
  final userController = UserController(StorageService());

  // Ubah jadi masterController
  late MasterController masterController;
  PelangganModel? _pelangganModel;

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

  Future<void> _logout(BuildContext context) async {
    await authController.logout();
    GoRouter.of(context).go('/login');
  }

  Future<void> _logoutcabang(BuildContext context) async {
    await authController.logoutOutlet();
    GoRouter.of(context).go('/logincabang');
  }

  String getInitials(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .join()
        .toUpperCase(); // Optional: make it uppercase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text("Profil",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                const RoundedAppBar(),
                Center(
                  child: Container(
                      width: 75,
                      height: 75,
                      padding: const EdgeInsets.all(10.0),
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
                          Text(
                              _pelangganModel == null
                                  ? ""
                                  : getInitials(
                                      _pelangganModel!.data[0].nama.toString()),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 17, 19, 21),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25))
                        ],
                      )),
                ),
                Positioned(
                    // top: 0,
                    left: 20,
                    right: 20,
                    bottom: 10,
                    child: Container(
                      width: 50,
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.bottomCenter,
                      height: 65,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _pelangganModel == null
                              ? const ListMenuShimmer(
                                  total: 1, circular: 4, height: 16)
                              : Text(_pelangganModel!.data[0].nama.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20)),
                          _pelangganModel == null
                              ? const ListMenuShimmer(
                                  total: 1, circular: 4, height: 16)
                              : const Text("EA-100A001",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16))
                        ],
                      ),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Tipe Anggota'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(_pelangganModel!.data[0].tipe_pelanggan
                                .toString()),
                      )),
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Nomor Kartu Tanda Anggota'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(
                                _pelangganModel!.data[0].nomor_kta.toString()),
                      )),
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Email'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(_pelangganModel!.data[0].email.toString()),
                      )),
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Kontak'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(_pelangganModel!.data[0].telepon.toString()),
                      )),
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Tempat Tanggal Lahir'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(
                                "${_pelangganModel!.data[0].kota_lahir.toString().trim()}, ${_pelangganModel!.data[0].tgl_lahir.toString()}"),
                      )),
                  Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: const Text('Alamat'),
                        subtitle: _pelangganModel == null
                            ? const ListMenuShimmer(
                                total: 1, circular: 4, height: 16)
                            : Text(_pelangganModel!.data[0].alamat.toString()),
                      )),
                  // const SizedBox(height: 10),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () => _logoutcabang(context),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white, // background color
                  //       foregroundColor: Colors.white, // text (foreground) color
                  //       elevation: 0,
                  //       padding:
                  //           const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.pin_drop_outlined,
                  //             color: Colors.grey[800], size: 20),
                  //         const SizedBox(width: 10),
                  //         Text('Pindah Cabang',
                  //             style: TextStyle(
                  //                 color: Colors.grey[800], fontSize: 16))
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // background color
                        foregroundColor:
                            Colors.white, // text (foreground) color
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.password_outlined,
                              color: Colors.black, size: 20),
                          SizedBox(width: 10),
                          Text('Ubah Password',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // background color
                        foregroundColor:
                            Colors.white, // text (foreground) color
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_outlined,
                              color: Colors.red, size: 20),
                          SizedBox(width: 10),
                          Text('Logout',
                              style: TextStyle(color: Colors.red, fontSize: 16))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        final width = constraint.maxWidth * 8;
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
  Size get preferredSize => const Size.fromHeight(150.0);
}
