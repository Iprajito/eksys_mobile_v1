import 'package:eahmindonesia/controllers/auth_controller.dart';
import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class ReportPembelian extends StatefulWidget {
  const ReportPembelian({super.key});

  @override
  State<ReportPembelian> createState() => _ReportPembelianState();
}

class _ReportPembelianState extends State<ReportPembelian> {
  final authController = AuthController(ApiServive(), StorageService());
  final storageService = StorageService();
  final userController = UserController(StorageService());

  String userId = "", userToken = "";

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
      print('Valid Token');
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
        userId = user!.uid.toString();
        userToken = user.token.toString();
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text("Pembelian",
                style: TextStyle(
                    color: Color.fromARGB(255, 17, 19, 21),
                    fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}