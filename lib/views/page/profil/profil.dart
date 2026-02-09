import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/profil/alamat.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
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

  Future<void> navigateToAlamatPage() async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => //DrawerExample(),
                  AlamatPage(token: userToken, userid: userId),
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
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
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
                        )
                      ),
                      const SizedBox(height: 8),
                      _pelangganModel == null ? const Text('')
                      : Text(_pelangganModel!.data[0].nama.toString().toUpperCase(),
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 20)),
                      _pelangganModel == null ? const Text('')
                      : Text(_pelangganModel!.data[0].kode_pelanggan.toString(), 
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 16)),
                      const SizedBox(height: 8),
                      _pelangganModel == null ? const Text('')
                      : Text('${_pelangganModel!.data[0].anggota} Anggota', style: const TextStyle(color: Colors.white,fontSize: 14))
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.all(16),
                      child: BootstrapContainer(fluid: true, children: [
                        // BootstrapRow(
                        //   height: 30,
                        //   children: [
                        //     BootstrapCol(
                        //       sizes: 'col-12',
                        //       child: Text("Profil",
                        //           style: TextStyle(
                        //               color: Colors.grey[800],
                        //               fontWeight: FontWeight.w700,
                        //               fontSize: 18)),
                        //     ),
                        //   ],
                        // ),
                        BootstrapRow(
                          // height: 60,
                          children: [
                            BootstrapCol(
                              fit: FlexFit.tight,
                              sizes: 'col-md-12',
                              child: SizedBox(
                                // height: 100,
                                child: Column(
                                    mainAxisAlignment:MainAxisAlignment.start,
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      _pelangganModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : 
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Tipe Anggota", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Text(_pelangganModel!.data[0].tipe_pelanggan.toString(), style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      _pelangganModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : 
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text("NIK", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Text(_pelangganModel!.data[0].nik.toString(), style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      _pelangganModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : 
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text("Email", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Text(_pelangganModel!.data[0].email.toString(), style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      _pelangganModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : 
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text("No. Handphone", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Text(_pelangganModel!.data[0].telepon.toString(), style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      _pelangganModel == null ? const ListMenuShimmer(total: 1, circular: 4, height: 16) : 
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text("Tanggal Lahir", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Text(_pelangganModel!.data[0].tgl_lahir.toString(), style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () {
                                          navigateToAlamatPage();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text("Alamat Saya", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                            Icon(Icons.arrow_forward_ios,size: 12, color: Colors.grey[500]),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                          height: 1,
                                          color: Colors.grey[100]),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text("Anggota Saya", style: TextStyle(color: Colors.grey[800], fontSize: 17)),
                                          Icon(Icons.arrow_forward_ios,size: 12, color: Colors.grey[500]),
                                        ],
                                      ),
                                    ]
                                  )
                                )
                            )
                          ]
                        )
                      ])),
                  const SizedBox(height: 16),
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
