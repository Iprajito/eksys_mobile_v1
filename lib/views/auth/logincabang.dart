import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/old/outlet_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/models/old/outlet_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginCabangPage extends StatefulWidget {
  const LoginCabangPage({super.key});

  @override
  State<LoginCabangPage> createState() => _LoginCabangPageState();
}

class _LoginCabangPageState extends State<LoginCabangPage> {
  final apiService = ApiServive();
  final storageService = StorageService();
  final userController = UserController(StorageService());

  late OutletController outletController;
  OutletModel? _outletModel;

  late String selectedOutletId = "";
  late String selectedOutlet = "Pilih Cabang";
  late String UserName = "";

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _dataOutlet();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final user = await userController.getUserFromStorage();
    final outlet_id = await storageService.getOutletId();
    if (mounted) {
      setState(() {
        UserName = user!.name.toString();
      });
    }
    if (user!.user_group == 'User' && outlet_id == null) {
      GoRouter.of(context).go('/logincabang');
    } else {
      GoRouter.of(context).go('/main');
    }
  }

  Future<void> _setOutlet(id, name) async {
    await storageService.saveOutlet(id, name);
    _checkLoginStatus();
  }

  Future<void> _dataOutlet() async {
    final user = await userController.getUserFromStorage();
    outletController = OutletController();
    final userToken = user!.token.toString();
    
    OutletModel? data = await outletController.fetchData(userToken);
    if (mounted) {
      setState(() {
        _outletModel = data;
      });
    }
  }

  final authController = AuthController(ApiServive(), StorageService());
  Future<void> _logout(BuildContext context) async {
    await authController.logout();
    GoRouter.of(context).go('/login');
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
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              const RoundedAppBar(),
              Positioned(
                left: 20,
                right: 20,
                top: 20,
                child: Center(
                  child: Container(
                      width: 75,
                      height: 75,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(getInitials(UserName),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 17, 19, 21),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25))
                        ],
                      )),
                ),
              ),
              Positioned(
                  // top: 0,
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: Container(
                    width: 50,
                    padding: const EdgeInsets.all(10.0),
                    alignment: Alignment.bottomCenter,
                    height: 65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserName == "" ? const ListMenuShimmer(total: 1, circular: 4, height: 16) :
                        Text(
                            UserName,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 17, 19, 21),
                                fontWeight: FontWeight.w700,
                                fontSize: 20)),
                      ],
                    ),
                  ))
            ],
          ),
          const Padding(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Text("Pilih Outlet",
                  style: TextStyle(
                      color: Color.fromARGB(255, 17, 19, 21),
                      fontWeight: FontWeight.w700,
                      fontSize: 20))),
          Expanded(
              child: RefreshIndicator(
            color: Colors.grey[800],
            onRefresh: () => _dataOutlet(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _outletModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _outletModel!.posts.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _outletModel!.posts.length,
                          itemBuilder: (context, index) {
                            var id = _outletModel!.posts[index].id.toString();
                            var outlet =
                                _outletModel!.posts[index].outlet.toString();
                            var alamat =
                                _outletModel!.posts[index].alamat.toString();
                            return listData(id, outlet, alamat);
                          }),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // background color
                  foregroundColor: Colors.white, // text (foreground) color
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          )
        ],
      ),
    );
  }

  Widget listData(String id, String outlet, String alamat) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        _setOutlet(id, outlet);
      },
      child: Container(
          // height: screenHeight * 0.085,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(outlet,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(
                alamat,
                style: TextStyle(color: Colors.grey[700], fontSize: 13.0),
              ),
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
                    color: Color.fromARGB(255, 254, 185, 3),
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